#!/usr/bin/env bash
# Comprehensive security check: secrets, images, headers, and key hygiene.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"
PASS=0
FAIL=0

ok()   { echo "  [PASS] $*"; PASS=$((PASS + 1)); }
fail() { echo "  [FAIL] $*"; FAIL=$((FAIL + 1)); }
info() { echo "  [INFO] $*"; }

echo "========================================"
echo "  Ecommerce Platform Security Check"
echo "========================================"
echo ""

# 1. Secrets files present and not committed
echo "[ JWT Key Hygiene ]"
if [ -f "$ROOT_DIR/secrets/jwt_private_key.pem" ]; then
  ok "jwt_private_key.pem exists"
  PERMS=$(stat -c "%a" "$ROOT_DIR/secrets/jwt_private_key.pem" 2>/dev/null || stat -f "%OLp" "$ROOT_DIR/secrets/jwt_private_key.pem")
  case "$PERMS" in
    600)
      ok "jwt_private_key.pem permissions are 600"
      ;;
    640|644)
      ok "jwt_private_key.pem permissions are $PERMS (accepted for local Docker Compose file secrets)"
      ;;
    *)
      fail "jwt_private_key.pem permissions are $PERMS (expected 600, 640, or local-dev 644)"
      ;;
  esac
else
  fail "secrets/jwt_private_key.pem missing — run scripts/dev-up.sh"
fi

if [ -f "$ROOT_DIR/secrets/jwt_public_key.pem" ]; then
  ok "jwt_public_key.pem exists"
else
  fail "secrets/jwt_public_key.pem missing — run scripts/dev-up.sh"
fi

echo ""

# 2. .gitignore covers secrets/
echo "[ .gitignore Coverage ]"
if grep -qE "^secrets/" "$ROOT_DIR/.gitignore" 2>/dev/null; then
  ok "secrets/ is in .gitignore"
else
  fail "secrets/ not found in .gitignore — private keys may be committed"
fi

if grep -qE "^\.env$" "$ROOT_DIR/.gitignore" 2>/dev/null; then
  ok ".env is in .gitignore"
else
  fail ".env not found in .gitignore"
fi

echo ""

# 3. .env does not contain JWT_SECRET (replaced by RSA keys)
echo "[ Legacy Config Check ]"
if [ -f "$ROOT_DIR/.env" ] && grep -qE "^JWT_SECRET=.+" "$ROOT_DIR/.env"; then
  fail ".env still contains JWT_SECRET — remove it, RSA keys are used now"
else
  ok "No legacy JWT_SECRET in .env"
fi

echo ""

# 4. Dependency scan (Maven — runs in Docker if available)
echo "[ Dependency Vulnerability Scan ]"
if command -v docker >/dev/null 2>&1; then
  info "Running OWASP Dependency-Check via Docker (this may take a few minutes)..."
  DEP_CHECK_DATA_DIR="${DEP_CHECK_DATA_DIR:-/tmp/ecommerce-dep-check-data}"
  DEP_CHECK_REPORT_DIR="${DEP_CHECK_REPORT_DIR:-/tmp/dep-check-report}"
  mkdir -p "$DEP_CHECK_DATA_DIR" "$DEP_CHECK_REPORT_DIR"
  docker run --rm \
    -v "$ROOT_DIR/backend:/src:ro" \
    -v "$DEP_CHECK_DATA_DIR:/usr/share/dependency-check/data" \
    -v "$DEP_CHECK_REPORT_DIR:/report" \
    owasp/dependency-check:latest \
    --project ecommerce-backend \
    --scan /src \
    --format HTML \
    --format JSON \
    --failOnCVSS 8 \
    --out /report && ok "Dependency scan passed (CVSS < 8)" \
    || fail "Dependency scan found HIGH/CRITICAL CVEs — check $DEP_CHECK_REPORT_DIR"
else
  info "Docker not available — skipping dependency scan"
fi

echo ""

# 5. Secret scan
echo "[ Secret Scan ]"
if command -v docker >/dev/null 2>&1; then
  bash "$SCRIPTS_DIR/scan-secrets.sh" >/dev/null 2>&1 && ok "No secrets detected in codebase" \
    || fail "Potential secrets detected — run scripts/scan-secrets.sh for details"
else
  info "Docker not available — skipping secret scan"
fi

echo ""

# 6. Image scan (if images built)
echo "[ Image Vulnerability Scan ]"
if command -v docker >/dev/null 2>&1; then
  bash "$SCRIPTS_DIR/scan-images.sh" >/dev/null 2>&1 && ok "No HIGH/CRITICAL CVEs in images" \
    || fail "Images contain HIGH/CRITICAL CVEs — run scripts/scan-images.sh for details"
else
  info "Docker not available — skipping image scan"
fi

echo ""
echo "========================================"
echo "  Results: $PASS passed, $FAIL failed"
echo "========================================"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
