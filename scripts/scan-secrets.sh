#!/usr/bin/env bash
# scripts/scan-secrets.sh
# Scans the repository for accidentally committed secrets.
# Uses gitleaks if available; falls back to a basic pattern grep.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FAILED=0

echo "=== Secret Scanning ==="

# ── gitleaks ──────────────────────────────────────────────────────────────────
if command -v gitleaks >/dev/null 2>&1; then
    echo "[gitleaks] Running scan..."
    if gitleaks detect --source . --no-git --redact --exit-code 1; then
        echo "[gitleaks] No secrets detected."
    else
        echo "[gitleaks] ALERT: Secrets detected!" >&2
        FAILED=1
    fi
else
    echo "[gitleaks] Not installed – skipping gitleaks scan."
    echo "           Install: https://github.com/gitleaks/gitleaks#installing"
fi

# ── Pattern grep fallback ─────────────────────────────────────────────────────
echo ""
echo "[grep] Scanning for common secret patterns..."

PATTERNS=(
    "password\s*=\s*['\"][^'\"]{6,}"
    "secret\s*=\s*['\"][^'\"]{6,}"
    "api[_-]?key\s*=\s*['\"][^'\"]{6,}"
    "private[_-]?key\s*=\s*['\"][^'\"]{6,}"
    "AWS_SECRET"
    "-----BEGIN (RSA |EC )?PRIVATE KEY-----"
)

EXCLUDE_DIRS=".git node_modules target dist .env.example"
EXCLUDE_ARGS=()
for d in $EXCLUDE_DIRS; do
    EXCLUDE_ARGS+=(--exclude-dir="$d")
done
EXCLUDE_ARGS+=(--exclude="*.example" --exclude="*.md")

GREP_FOUND=0
for pattern in "${PATTERNS[@]}"; do
    if grep -rniE "${EXCLUDE_ARGS[@]}" "$pattern" . 2>/dev/null; then
        GREP_FOUND=1
    fi
done

if [ "$GREP_FOUND" -eq 1 ]; then
    echo "[grep] WARNING: Potential secrets found. Review matches above." >&2
    FAILED=1
else
    echo "[grep] No obvious secret patterns detected."
fi

# ── .env check ────────────────────────────────────────────────────────────────
if [ -f .env ]; then
    echo ""
    echo "[env] WARNING: .env file found in working directory."
    echo "      Ensure it is listed in .gitignore and never committed." >&2
fi

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "✓ Secret scan passed."
    exit 0
else
    echo "✗ Secret scan found potential issues. Review output above." >&2
    exit 1
fi
