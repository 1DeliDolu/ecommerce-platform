#!/usr/bin/env bash
# scripts/scan-images.sh
# Scans Docker images defined in docker-compose.yml for CVEs using Trivy.
# Requires: trivy (https://aquasecurity.github.io/trivy/)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SEVERITY="${TRIVY_SEVERITY:-CRITICAL,HIGH}"
EXIT_CODE=0

echo "=== Docker Image Vulnerability Scan (Trivy) ==="
echo "Severity filter: $SEVERITY"
echo ""

if ! command -v trivy >/dev/null 2>&1; then
    echo "ERROR: trivy is not installed." >&2
    echo "Install: https://aquasecurity.github.io/trivy/latest/getting-started/installation/" >&2
    exit 1
fi

# Collect unique image names from docker-compose.yml
IMAGES=()
while IFS= read -r line; do
    img=$(echo "$line" | sed 's/.*image:\s*//' | tr -d '"'"'" | xargs)
    [[ -n "$img" && "$img" != *"{"* ]] && IMAGES+=("$img")
done < <(grep -E '^\s+image:' docker-compose.yml 2>/dev/null || true)

# Also scan locally built images
BUILT_IMAGES=("ecommerce-platform-backend:latest" "ecommerce-platform-frontend:latest")

ALL_IMAGES=("${IMAGES[@]}" "${BUILT_IMAGES[@]}")

if [ "${#ALL_IMAGES[@]}" -eq 0 ]; then
    echo "No images found to scan."
    exit 0
fi

for image in "${ALL_IMAGES[@]}"; do
    echo "── Scanning: $image ──"
    if trivy image \
        --severity "$SEVERITY" \
        --exit-code 1 \
        --no-progress \
        "$image" 2>&1; then
        echo "✓ No $SEVERITY vulnerabilities in $image"
    else
        echo "✗ Vulnerabilities found in $image" >&2
        EXIT_CODE=1
    fi
    echo ""
done

echo "=== Scan complete ==="
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "✓ All images passed the vulnerability scan."
else
    echo "✗ Vulnerabilities detected. Review output above." >&2
fi

exit "$EXIT_CODE"
