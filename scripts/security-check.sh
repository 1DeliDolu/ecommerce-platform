#!/usr/bin/env bash
# scripts/security-check.sh
# Master security-check script that orchestrates all security scans.
# Runs: secret scan, dependency check (OWASP), Docker image scan.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"
cd "$ROOT_DIR"

OVERALL=0
REPORT_DIR="${ROOT_DIR}/security-reports"
mkdir -p "$REPORT_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "╔══════════════════════════════════════════════════════╗"
echo "║         Ecommerce Platform – Security Check          ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

run_step() {
    local name="$1"
    local cmd="$2"
    echo "┌── $name"
    if eval "$cmd"; then
        echo "└── ✓ $name passed"
    else
        echo "└── ✗ $name FAILED" >&2
        OVERALL=1
    fi
    echo ""
}

# ── 1. Secret scan ────────────────────────────────────────────────────────────
run_step "Secret Scan" "bash $SCRIPTS_DIR/scan-secrets.sh"

# ── 2. OWASP Dependency Check ─────────────────────────────────────────────────
echo "┌── OWASP Dependency Check"
if command -v mvn >/dev/null 2>&1; then
    if mvn --batch-mode -f "$ROOT_DIR/backend/pom.xml" \
        org.owasp:dependency-check-maven:check \
        -DfailBuildOnCVSS=7 \
        -Dformat=JSON \
        "-DoutputDirectory=$REPORT_DIR/dependency-check-$TIMESTAMP" \
        -DsuppressionFile="$ROOT_DIR/owasp-suppressions.xml" 2>&1 | tail -20; then
        echo "└── ✓ OWASP Dependency Check passed"
    else
        echo "└── ✗ OWASP Dependency Check FAILED (CVSS >= 7 vulnerabilities found)" >&2
        OVERALL=1
    fi
elif docker info >/dev/null 2>&1; then
    echo "   (running via Docker – this may take several minutes)"
    if docker run --rm \
        -v "$ROOT_DIR/backend:/src:ro" \
        -v "$REPORT_DIR:/report" \
        owasp/dependency-check:latest \
        --scan /src \
        --format JSON \
        --out /report \
        --failOnCVSS 7 2>&1 | tail -20; then
        echo "└── ✓ OWASP Dependency Check passed"
    else
        echo "└── ✗ OWASP Dependency Check FAILED" >&2
        OVERALL=1
    fi
else
    echo "   WARNING: Neither mvn nor docker available – skipping OWASP check."
    echo "└── ⚠ OWASP Dependency Check skipped"
fi
echo ""

# ── 3. Docker image scan ──────────────────────────────────────────────────────
if command -v trivy >/dev/null 2>&1; then
    run_step "Docker Image Scan" "bash $SCRIPTS_DIR/scan-images.sh"
else
    echo "┌── Docker Image Scan"
    echo "   WARNING: trivy not installed – skipping image scan."
    echo "   Install: https://aquasecurity.github.io/trivy/latest/getting-started/installation/"
    echo "└── ⚠ Docker Image Scan skipped"
    echo ""
fi

# ── 4. npm audit (frontend) ───────────────────────────────────────────────────
echo "┌── npm audit (frontend)"
if [ -f "$ROOT_DIR/frontend/package.json" ]; then
    if npm audit --prefix "$ROOT_DIR/frontend" --audit-level=high 2>&1; then
        echo "└── ✓ npm audit passed"
    else
        echo "└── ✗ npm audit found HIGH/CRITICAL vulnerabilities" >&2
        OVERALL=1
    fi
else
    echo "   frontend/package.json not found – skipping"
    echo "└── ⚠ npm audit skipped"
fi
echo ""

# ── Summary ───────────────────────────────────────────────────────────────────
echo "══════════════════════════════════════════════════════"
if [ "$OVERALL" -eq 0 ]; then
    echo "✓ All security checks passed."
else
    echo "✗ One or more security checks failed. Review output above." >&2
fi
echo "  Reports saved to: $REPORT_DIR"
echo "══════════════════════════════════════════════════════"

exit "$OVERALL"
