# Backup & Restore

Procedures for backing up and restoring the PostgreSQL database using the provided shell scripts.

---

## Overview

| Script                  | Purpose                                                  |
| ----------------------- | -------------------------------------------------------- |
| `scripts/backup-db.sh`  | Creates a compressed, timestamped SQL dump in `backups/` |
| `scripts/restore-db.sh` | Restores the database from a backup file (destructive)   |

Both scripts read database credentials from `.env` and the password from `secrets/postgres_password.txt`. The `ecommerce-postgres` container must be running.

---

## Backup

### Usage

```bash
./scripts/backup-db.sh
```

### What it does

1. Reads `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PORT` from `.env`
2. Reads the database password from `secrets/postgres_password.txt`
3. Runs `pg_dump` inside the `ecommerce-postgres` container
4. Pipes the output through `gzip`
5. Writes the result to `backups/ecommerce_YYYYMMDD_HHMMSS.sql.gz`

### Example output

```
Backing up database 'ecommerce' → backups/ecommerce_20260505_143022.sql.gz
Backup complete: backups/ecommerce_20260505_143022.sql.gz (312K)
```

### Backup file format

| Property          | Value                              |
| ----------------- | ---------------------------------- |
| Location          | `./backups/`                       |
| Filename          | `ecommerce_YYYYMMDD_HHMMSS.sql.gz` |
| Compression       | gzip                               |
| PostgreSQL format | `--format plain` (standard SQL)    |
| Ownership         | Stripped (`--no-owner --no-acl`)   |

### Automating backups with cron

```bash
# Daily backup at 02:00
0 2 * * * /path/to/ecommerce-platform/scripts/backup-db.sh >> /var/log/ecommerce-backup.log 2>&1
```

### Inspecting a backup

```bash
# View uncompressed size
gunzip -c backups/ecommerce_20260505_143022.sql.gz | wc -c

# Preview first 50 lines
gunzip -c backups/ecommerce_20260505_143022.sql.gz | head -50

# List tables in the backup
gunzip -c backups/ecommerce_20260505_143022.sql.gz | grep "^CREATE TABLE"
```

---

## Restore

> **Warning:** Restore is a **destructive operation**. It drops and recreates the entire `public` schema, permanently deleting all current data. Always take a fresh backup before restoring.

### Usage

```bash
./scripts/restore-db.sh <backup-file.sql.gz>
```

If called without an argument, the script lists available backups in `backups/`:

```bash
./scripts/restore-db.sh
# Usage: ./scripts/restore-db.sh <backup-file.sql.gz>
#
# Available backups:
# -rw-r--r-- 1 user group 312K May  5 14:30 backups/ecommerce_20260505_143022.sql.gz
```

### What it does

1. Validates that the specified backup file exists
2. Asks for explicit confirmation — you must type `yes` to proceed
3. Connects to `ecommerce-postgres` and runs:
   ```sql
   DROP SCHEMA public CASCADE;
   CREATE SCHEMA public;
   ```
4. Decompresses the backup and pipes it into `psql`

### Example session

```
WARNING: This will DROP and recreate all tables in database 'ecommerce'.
Type 'yes' to continue: yes
Restoring 'backups/ecommerce_20260505_143022.sql.gz' → database 'ecommerce'...
Restore complete.
```

### After restore

Flyway tracks applied migrations in the `flyway_schema_history` table, which is included in the backup. No re-migration is needed after a successful restore.

If you restore to a different database instance (e.g., a fresh container), restart the backend so Flyway validates the schema:

```bash
docker compose restart backend
```

---

## Retention Policy (Recommendation)

The scripts do not implement automatic retention. For production, add a cleanup step:

```bash
# Keep last 7 daily backups, delete older ones
find backups/ -name "ecommerce_*.sql.gz" -mtime +7 -delete
```

---

## Error Reference

| Error                                                  | Cause                                                 | Fix                                              |
| ------------------------------------------------------ | ----------------------------------------------------- | ------------------------------------------------ |
| `ERROR: Container 'ecommerce-postgres' is not running` | PostgreSQL container is not up                        | Run `docker compose up -d postgres`              |
| `ERROR: Backup file not found`                         | Wrong path passed to restore script                   | Check `ls backups/` for available files          |
| `Aborted.`                                             | User typed something other than `yes` at confirmation | Re-run the script and type `yes`                 |
| `pg_dump: error: connection to server failed`          | Wrong credentials or host                             | Check `secrets/postgres_password.txt` and `.env` |

---

## Manual Backup (Without Script)

If the script is unavailable, you can run `pg_dump` directly:

```bash
docker exec -e PGPASSWORD="$(cat secrets/postgres_password.txt)" ecommerce-postgres \
  pg_dump \
    --username ecommerce_user \
    --dbname ecommerce \
    --no-owner \
    --no-acl \
  | gzip > backups/manual_$(date +%Y%m%d_%H%M%S).sql.gz
```

---

## Manual Restore (Without Script)

```bash
# 1. Drop and recreate schema
docker exec -e PGPASSWORD="$(cat secrets/postgres_password.txt)" ecommerce-postgres \
  psql --username ecommerce_user --dbname ecommerce \
  -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# 2. Restore
gunzip -c backups/ecommerce_20260505_143022.sql.gz | \
  docker exec -i \
    -e PGPASSWORD="$(cat secrets/postgres_password.txt)" ecommerce-postgres \
    psql --username ecommerce_user --dbname ecommerce --quiet
```
