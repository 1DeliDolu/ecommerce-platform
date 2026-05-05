#!/usr/bin/env bash
# scripts/generate-jwt-keys.sh
# Generates an RSA 2048-bit key pair for JWT RS256 signing.
# The base64-encoded keys are written to .env (or printed to stdout).
# Usage: ./scripts/generate-jwt-keys.sh [--print]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PRINT_ONLY=false
if [ "${1:-}" = "--print" ]; then
    PRINT_ONLY=true
fi

if ! command -v openssl >/dev/null 2>&1; then
    echo "ERROR: openssl is required." >&2
    exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Generating RSA 2048-bit key pair..."

openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
    -out "$TMP_DIR/private.pem" 2>/dev/null

openssl rsa -in "$TMP_DIR/private.pem" \
    -pubout -out "$TMP_DIR/public.pem" 2>/dev/null

# Export as single-line base64 (PKCS8 private, X509 public)
PRIVATE_KEY_B64=$(openssl pkcs8 -topk8 -nocrypt \
    -in "$TMP_DIR/private.pem" -outform DER 2>/dev/null | base64 | tr -d '\n')

PUBLIC_KEY_B64=$(openssl rsa -in "$TMP_DIR/private.pem" \
    -pubout -outform DER 2>/dev/null | base64 | tr -d '\n')

if [ "$PRINT_ONLY" = true ]; then
    echo ""
    echo "JWT_PRIVATE_KEY=$PRIVATE_KEY_B64"
    echo "JWT_PUBLIC_KEY=$PUBLIC_KEY_B64"
    exit 0
fi

ENV_FILE="$ROOT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: .env not found. Run ./scripts/dev-up.sh first to create it." >&2
    exit 1
fi

# Remove old RSA entries if present, then append new values
sed -i '/^JWT_PRIVATE_KEY=/d; /^JWT_PUBLIC_KEY=/d' "$ENV_FILE"
{
    echo "JWT_PRIVATE_KEY=$PRIVATE_KEY_B64"
    echo "JWT_PUBLIC_KEY=$PUBLIC_KEY_B64"
} >> "$ENV_FILE"

echo ""
echo "✓ RSA key pair written to .env"
echo "  JWT_PRIVATE_KEY and JWT_PUBLIC_KEY have been set."
echo "  Restart the backend for the changes to take effect."
echo ""
echo "  NOTE: Keep .env out of version control (.gitignore)."
