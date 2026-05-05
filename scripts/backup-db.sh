#!/usr/bin/env bash
# scripts/backup-db.sh
# Creates a compressed PostgreSQL dump from the running Docker container.
# Usage: ./scripts/backup-db.sh [output-directory]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BACKUP_DIR="${1:-$ROOT_DIR/backups}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/ecommerce-$TIMESTAMP.pgdump"

CONTAINER="${POSTGRES_CONTAINER:-ecommerce-postgres}"
DB_NAME="${POSTGRES_DB:-ecommerce}"
DB_USER="${POSTGRES_USER:-ecommerce_user}"

# Load .env if present (for override values)
if [ -f "$ROOT_DIR/.env" ]; then
    # shellcheck disable=SC1091
    set -o allexport
    source "$ROOT_DIR/.env"
    set +o allexport
fi

mkdir -p "$BACKUP_DIR"

echo "=== PostgreSQL Backup ==="
echo "Container : $CONTAINER"
echo "Database  : $DB_NAME"
echo "User      : $DB_USER"
echo "Output    : $BACKUP_FILE"
echo ""

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "ERROR: Container '$CONTAINER' is not running." >&2
    echo "       Start the stack first: ./scripts/dev-up.sh" >&2
    exit 1
fi

echo "Running pg_dump..."
docker exec "$CONTAINER" \
    env PGSSLMODE=require \
    pg_dump \
    --username="$DB_USER" \
    --dbname="$DB_NAME" \
    --format=custom \
    --compress=9 \
    --no-password \
    > "$BACKUP_FILE"

BACKUP_SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
echo ""
echo "✓ Backup created: $BACKUP_FILE ($BACKUP_SIZE)"
echo ""

# Retain only the latest 7 daily backups
KEEP="${BACKUP_KEEP:-7}"
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "ecommerce-*.pgdump" | wc -l)
if [ "$BACKUP_COUNT" -gt "$KEEP" ]; then
    echo "Pruning old backups (keeping $KEEP most recent)..."
    find "$BACKUP_DIR" -name "ecommerce-*.pgdump" \
        | sort \
        | head -n "$(( BACKUP_COUNT - KEEP ))" \
        | xargs rm -f
    echo "✓ Old backups pruned."
fi
