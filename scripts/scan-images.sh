#!/usr/bin/env bash
# Scan Docker images for HIGH/CRITICAL CVEs using Trivy.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_NAME="ecommerce-platform"

echo "=== Docker Image Vulnerability Scan (Trivy) ==="
echo ""

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is required to run Trivy." >&2
  exit 1
fi

IMAGES=(
  "${PROJECT_NAME}-backend:latest"
  "${PROJECT_NAME}-frontend:latest"
)

FAILED=0
for IMAGE in "${IMAGES[@]}"; do
  echo "--- Scanning: $IMAGE ---"
  if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "SKIP: Image $IMAGE not found locally (run docker compose build first)."
    continue
  fi

  docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy:latest \
    image \
    --exit-code 1 \
    --severity HIGH,CRITICAL \
    --ignore-unfixed \
    --scanners vuln \
    --no-progress \
    "$IMAGE" || FAILED=$((FAILED + 1))

  echo ""
done

if [ "$FAILED" -gt 0 ]; then
  echo "FAIL: $FAILED image(s) contain HIGH/CRITICAL vulnerabilities."
  exit 1
fi

echo "PASS: No HIGH/CRITICAL vulnerabilities found."
