# Runbook

Day-to-day operations guide for starting, stopping, rebuilding, and switching profiles.

---

## Prerequisites

| Requirement    | Minimum Version         |
| -------------- | ----------------------- |
| Docker Engine  | 26+                     |
| Docker Compose | v2.24+                  |
| OpenSSL        | 1.1.1+ (key generation) |
| Bash           | 4+                      |

All commands are run from the **project root** directory (`ecommerce-platform/`).

---

## First-Time Setup

```bash
./scripts/dev-up.sh
```

The script handles all initialization automatically:

1. Copies `.env.example` → `.env` if `.env` is absent
2. Generates `secrets/postgres_password.txt` (random 48-byte base64, mode 644)
3. Generates `secrets/jwt_private_key.pem` (RSA 2048, PKCS8, mode 644 in local dev)
4. Generates `secrets/jwt_public_key.pem` (mode 644)
5. Runs `docker compose up --build -d`

After the script completes, wait ~30 seconds for the backend to apply Flyway migrations.

---

## Starting Services

### Default stack (backend + frontend + databases + messaging)

```bash
docker compose up -d
```

Services started: `postgres`, `backend`, `frontend`, `mailhog`, `kafka`, `kafka-init`, `kafka-ui`, `rabbitmq`

### With monitoring

```bash
docker compose --profile monitoring up -d
```

Additional services: `prometheus`, `grafana`, `postgres-exporter`, `kafka-exporter`, `rabbitmq-exporter`

### With ETL services

```bash
docker compose --profile etl up -d
```

Additional services: `airflow-init`, `airflow-webserver`, `airflow-scheduler`

### With database tooling

```bash
docker compose --profile tools up -d
```

Additional service: `pgadmin`

### All profiles combined

```bash
docker compose --profile monitoring --profile etl --profile tools up -d
```

---

## Stopping Services

### Stop all containers (preserve volumes)

```bash
docker compose down
```

Or use the helper script:

```bash
./scripts/dev-down.sh
```

### Stop and remove volumes (full reset — destroys data)

```bash
docker compose down -v
```

> **Warning:** `-v` permanently deletes PostgreSQL data, Kafka data, and all other named volumes.

### Stop a single service

```bash
docker compose stop backend
docker compose start backend
```

---

## Rebuilding

Use when you change Java/React source code or `Dockerfile`:

```bash
./scripts/rebuild.sh
```

The rebuild script:

1. Runs `docker compose build --no-cache`
2. Syncs the PostgreSQL user password from `secrets/postgres_password.txt` (avoids auth failures after rebuild)
3. Brings all services back up with `docker compose up -d`

To rebuild a single service only:

```bash
docker compose build --no-cache backend
docker compose up -d backend
```

---

## Checking Service Health

```bash
docker compose ps
```

### Backend health endpoint

```bash
curl http://localhost:8080/actuator/health
```

Expected response: `{"status":"UP",...}`

### Database readiness

```bash
docker compose exec postgres pg_isready -U ecommerce_user -d ecommerce
```

Expected: `localhost:5432 - accepting connections`

### Service logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend

# Last 100 lines
docker compose logs --tail=100 backend
```

---

## Restarting a Single Service

```bash
docker compose restart backend
```

For a clean restart after code change:

```bash
docker compose build --no-cache backend && docker compose up -d backend
```

---

## Profile Switching

Profiles can be combined freely. To add monitoring to a running default stack:

```bash
docker compose --profile monitoring up -d
```

Docker Compose only starts the new services; the running default services are not affected.

To stop only monitoring services:

```bash
docker compose --profile monitoring stop
docker compose --profile monitoring rm -f
```

---

## Applying Database Migrations

Flyway runs automatically on backend startup. To trigger manually (e.g., after a restore):

```bash
docker compose restart backend
```

Check migration status in backend logs:

```bash
docker compose logs backend | grep -i flyway
```

---

## Environment Variables

Key variables in `.env` (never commit this file):

| Variable                   | Default                            | Description                                   |
| -------------------------- | ---------------------------------- | --------------------------------------------- |
| `FRONTEND_PORT`            | `3000`                             | Host port for React frontend                  |
| `BACKEND_PORT`             | `8080`                             | Host port for Spring Boot API                 |
| `POSTGRES_PORT`            | `5432`                             | Host port for PostgreSQL                      |
| `POSTGRES_DB`              | `ecommerce`                        | Database name                                 |
| `POSTGRES_USER`            | `ecommerce_user`                   | Database user                                 |
| `KAFKA_PORT`               | `9094`                             | External Kafka listener port                  |
| `KAFKA_UI_PORT`            | `8085`                             | Kafka UI port                                 |
| `RABBITMQ_PORT`            | `5672`                             | AMQP port                                     |
| `RABBITMQ_MANAGEMENT_PORT` | `15672`                            | RabbitMQ management UI port                   |
| `PROMETHEUS_PORT`          | `9090`                             | Prometheus port                               |
| `GRAFANA_PORT`             | `3001`                             | Grafana port                                  |
| `PGADMIN_PORT`             | `5050`                             | pgAdmin port                                  |
| `AIRFLOW_PORT`             | `8088`                             | Airflow webserver port                        |
| `JWT_PRIVATE_KEY_PATH`     | `/app/secrets/jwt_private_key.pem` | RSA private key (mounted into container)      |
| `JWT_PUBLIC_KEY_PATH`      | `/app/secrets/jwt_public_key.pem`  | RSA public key                                |
| `JWT_EXPIRATION_MINUTES`   | `30`                               | Access token lifetime                         |
| `RATE_LIMIT_AUTH_RPM`      | `20`                               | Auth endpoint rate limit (requests/minute/IP) |

---

## Service URLs (Default Ports)

| Service        | URL                                   | Credentials                |
| -------------- | ------------------------------------- | -------------------------- |
| Frontend       | http://localhost:3000                 | —                          |
| Backend API    | http://localhost:8080                 | JWT Bearer token           |
| Backend Health | http://localhost:8080/actuator/health | —                          |
| Swagger UI     | http://localhost:8080/swagger-ui.html | —                          |
| MailHog UI     | http://localhost:8025                 | —                          |
| Kafka UI       | http://localhost:8085                 | —                          |
| RabbitMQ UI    | http://localhost:15672                | ecommerce / ecommerce (or env) |
| Prometheus     | http://localhost:9090                 | —                          |
| Grafana        | http://localhost:3001                 | admin / admin              |
| pgAdmin        | http://localhost:5050                 | admin@local.dev / admin123 |
| Airflow        | http://localhost:8088                 | admin / admin (requires `etl` profile) |

---

## Secrets Directory

```
secrets/
├── postgres_password.txt     — PostgreSQL user password (mode 644)
├── jwt_private_key.pem       — RSA private key for JWT signing (mode 644 in local dev)
└── jwt_public_key.pem        — RSA public key for JWT verification (mode 644)
```

These files are generated by `dev-up.sh` and are excluded from Git via `.gitignore`. Never commit them.

If you need to rotate the JWT keypair:

```bash
rm secrets/jwt_private_key.pem secrets/jwt_public_key.pem
./scripts/dev-up.sh   # regenerates keys; all existing tokens become invalid
```

---

## Troubleshooting

### Backend fails to start

Check logs:

```bash
docker compose logs backend | tail -50
```

Common causes:

- PostgreSQL not ready yet — wait and run `docker compose restart backend`
- Kafka not available — wait for `kafka-init` to complete
- JWT key files missing from `secrets/` — run `./scripts/dev-up.sh`

### Port conflict

If a port is already in use, override it in `.env`:

```bash
BACKEND_PORT=8081
FRONTEND_PORT=3001
```

Then `docker compose up -d`.

### Database connection refused

```bash
docker compose ps postgres       # check status
docker compose logs postgres     # check for TLS cert errors
```

PostgreSQL requires SSL. The `postgres-certs` init container generates self-signed certs on first run. If the certs volume is corrupted, recreate it:

```bash
docker compose down
docker volume rm ecommerce-platform_postgres_certs
docker compose up -d
```

### Reset everything

```bash
docker compose down -v           # destroys all volumes and data
./scripts/dev-up.sh              # clean first-time setup
```
