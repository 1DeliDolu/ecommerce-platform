#!/usr/bin/env bash
# Scan git history and working directory for leaked secrets using gitleaks (Docker).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Secret Scan (gitleaks) ==="
echo "Directory: $ROOT_DIR"
echo ""

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is required to run gitleaks." >&2
  exit 1
fi

# Run gitleaks against the repo
docker run --rm \
  -v "$ROOT_DIR:/repo:ro" \
  zricethezav/gitleaks:latest \
  detect \
  --source /repo \
  --config /repo/.gitleaks.toml \
  --no-git \
  --exit-code 1 \
  --redact \
  --verbose 2>&1 || {
    echo ""
    echo "FAIL: Potential secrets detected. Review gitleaks output above."
    exit 1
  }

echo ""
echo "PASS: No secrets detected."
