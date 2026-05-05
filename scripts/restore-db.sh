#!/usr/bin/env bash
# scripts/restore-db.sh
# Restores a PostgreSQL dump into the running Docker container.
# Usage: ./scripts/restore-db.sh <backup-file>
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BACKUP_FILE="${1:-}"
if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file>" >&2
    echo ""
    echo "Available backups:"
    ls -lh "$ROOT_DIR/backups/"*.pgdump 2>/dev/null || echo "  (none found in $ROOT_DIR/backups/)"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found: $BACKUP_FILE" >&2
    exit 1
fi

CONTAINER="${POSTGRES_CONTAINER:-ecommerce-postgres}"
DB_NAME="${POSTGRES_DB:-ecommerce}"
DB_USER="${POSTGRES_USER:-ecommerce_user}"

# Load .env if present
if [ -f "$ROOT_DIR/.env" ]; then
    # shellcheck disable=SC1091
    set -o allexport
    source "$ROOT_DIR/.env"
    set +o allexport
fi

echo "=== PostgreSQL Restore ==="
echo "Container : $CONTAINER"
echo "Database  : $DB_NAME"
echo "User      : $DB_USER"
echo "Source    : $BACKUP_FILE"
echo ""
echo "WARNING: This will DROP and recreate the database '$DB_NAME'."
echo "         All existing data will be lost."
echo ""
read -r -p "Type 'yes' to confirm: " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "ERROR: Container '$CONTAINER' is not running." >&2
    exit 1
fi

echo ""
echo "Stopping backend to prevent writes during restore..."
docker stop ecommerce-backend 2>/dev/null || true

echo "Dropping and recreating database..."
docker exec "$CONTAINER" \
    env PGSSLMODE=require \
    psql \
    --username="$DB_USER" \
    --dbname=postgres \
    --no-password \
    --command="DROP DATABASE IF EXISTS \"$DB_NAME\"; CREATE DATABASE \"$DB_NAME\" OWNER \"$DB_USER\";"

echo "Restoring dump..."
docker exec -i "$CONTAINER" \
    env PGSSLMODE=require \
    pg_restore \
    --username="$DB_USER" \
    --dbname="$DB_NAME" \
    --no-password \
    --clean \
    --if-exists \
    --exit-on-error \
    < "$BACKUP_FILE"

echo ""
echo "✓ Restore complete."
echo ""
echo "Restarting backend..."
docker start ecommerce-backend 2>/dev/null || echo "  (backend not managed here – start manually)"
