#!/usr/bin/env bash
# Restore PostgreSQL database from a backup file produced by backup-db.sh.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <backup-file.sql.gz>"
  echo ""
  echo "Available backups:"
  ls -lh "$ROOT_DIR/backups/"*.sql.gz 2>/dev/null || echo "  (none found in backups/)"
  exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "ERROR: Backup file not found: $BACKUP_FILE" >&2
  exit 1
fi

# Load env vars
if [ -f "$ROOT_DIR/.env" ]; then
  set -a; source "$ROOT_DIR/.env"; set +a
fi

DB="${POSTGRES_DB:-ecommerce}"
USER="${POSTGRES_USER:-ecommerce_user}"
CONTAINER="ecommerce-postgres"

echo "WARNING: This will DROP and recreate all tables in database '$DB'."
read -r -p "Type 'yes' to continue: " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted."
  exit 0
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "ERROR: Container '$CONTAINER' is not running." >&2
  exit 1
fi

PG_PASS=""
if [ -f "$ROOT_DIR/secrets/postgres_password.txt" ]; then
  PG_PASS=$(cat "$ROOT_DIR/secrets/postgres_password.txt")
fi

echo "Restoring '$BACKUP_FILE' → database '$DB'..."

# Drop and recreate public schema, then restore
docker exec -i \
  -e PGPASSWORD="$PG_PASS" \
  "$CONTAINER" \
  psql --username "$USER" --dbname "$DB" \
  -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" >/dev/null

gunzip -c "$BACKUP_FILE" | docker exec -i \
  -e PGPASSWORD="$PG_PASS" \
  "$CONTAINER" \
  psql --username "$USER" --dbname "$DB" --quiet

echo "Restore complete."
