#!/usr/bin/env bash
# Backup PostgreSQL database to a timestamped file in backups/.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$ROOT_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/ecommerce_${TIMESTAMP}.sql.gz"

# Load env vars
if [ -f "$ROOT_DIR/.env" ]; then
  set -a; source "$ROOT_DIR/.env"; set +a
fi

DB="${POSTGRES_DB:-ecommerce}"
USER="${POSTGRES_USER:-ecommerce_user}"
HOST="localhost"
PORT="${POSTGRES_PORT:-5432}"
CONTAINER="ecommerce-postgres"

mkdir -p "$BACKUP_DIR"

echo "Backing up database '$DB' → $BACKUP_FILE"

if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  # Read password from secrets file if available
  PG_PASS=""
  if [ -f "$ROOT_DIR/secrets/postgres_password.txt" ]; then
    PG_PASS=$(cat "$ROOT_DIR/secrets/postgres_password.txt")
  fi

  docker exec \
    -e PGPASSWORD="$PG_PASS" \
    "$CONTAINER" \
    pg_dump \
      --username "$USER" \
      --dbname "$DB" \
      --no-password \
      --format plain \
      --no-owner \
      --no-acl \
    | gzip > "$BACKUP_FILE"
else
  echo "ERROR: Container '$CONTAINER' is not running." >&2
  exit 1
fi

SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
echo "Backup complete: $BACKUP_FILE ($SIZE)"
