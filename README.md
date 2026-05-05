# Ecommerce Platform

A full-stack ecommerce platform built as a portfolio project demonstrating production-grade architecture: event-driven microservice patterns, security hardening, observability, and data warehouse ETL — all wired together with Docker Compose.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Tech Stack](#3-tech-stack)
4. [Features](#4-features)
5. [How to Run](#5-how-to-run)
6. [Service URLs](#6-service-urls)
7. [Authentication](#7-authentication)
8. [Database Design](#8-database-design)
9. [Kafka & RabbitMQ Flow](#9-kafka--rabbitmq-flow)
10. [Airflow ETL](#10-airflow-etl)
11. [Monitoring](#11-monitoring)
12. [Security](#12-security)
13. [Screenshots](#13-screenshots)
14. [Roadmap](#14-roadmap)

---

## 1. Project Overview

The platform simulates a real-world ecommerce backend with:

- Customer-facing REST API (product catalog, cart, checkout)
- Admin panel API (product/category/order management)
- JWT-based authentication with role-based access control (RBAC)
- Asynchronous event publishing via Kafka and RabbitMQ
- Nightly data warehouse ETL via Apache Airflow
- Prometheus metrics and Grafana dashboards
- PostgreSQL with TLS, Flyway migrations, and a star-schema data warehouse

The project is designed to be runnable on a developer laptop with a single command and reviewable by a technical interviewer at a glance.

---

## 2. Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Docker Compose                                                              │
│                                                                              │
│  ┌──────────┐   REST    ┌────────────────────────────────────────────────┐   │
│  │ React    │ ◀─────▶  │  Spring Boot Backend (Java 25)                 │   │
│  │ Frontend │           │                                                │   │
│  │ (nginx)  │           │  Controllers → Services → JPA Repositories     │   │
│  └──────────┘           │                                                │   │
│                         │  ┌─────────────────────────────────────────┐   │   │
│                         │  │  Spring Security                        │   │   │
│                         │  │  JWT RS256 • RBAC • Rate Limiting       │   │   │
│                         │  │  Account Lockout • Security Headers     │   │   │
│                         │  └─────────────────────────────────────────┘   │   │
│                         └───────────────┬────────────┬───────────────────┘   │
│                                         │            │                       │
│                          ┌──────────────▼───┐  ┌─────▼──────────┐            │
│                          │  PostgreSQL 17    │  │  Kafka (KRaft) │           │
│                          │  (TLS 1.2+)       │  │  6 topics      │           │
│                          │  Flyway V001–V010 │  └─────┬──────────┘           │
│                          └──────────────────┘        │                       │
│                                                       │ async events         │
│                          ┌────────────────┐    ┌──────▼──────────┐           │
│                          │  RabbitMQ      │    │  Email Worker   │           │
│                          │  mail.send     │◀──│  (Spring AMQP)  │           │
│                          │  mail.send.dlq │    └─────────────────┘           │
│                          └───────┬────────┘                                  │
│                                  │                                           │
│                          ┌───────▼────────┐                                  │
│                          │  MailHog       │                                  │
│                          │  (SMTP sink)   │                                  │
│                          └────────────────┘                                  │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────┐            │
│  │  Monitoring (--profile monitoring)                           │            │
│  │  Prometheus ← backend + postgres-exporter + kafka-exporter   │            │
│  │              + rabbitmq-exporter → Grafana                   │            │
│  └──────────────────────────────────────────────────────────────┘            │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────┐              │
│  │  ETL (--profile etl)                                       │              │
│  │  Airflow 2.10 → 5 daily DAGs → staging → dw → reports      │              │
│  └────────────────────────────────────────────────────────────┘              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Docker Compose Profiles

| Profile | Services added |
| ------- | -------------- |
| *(default)* | postgres, backend, frontend, mailhog, kafka, kafka-init, kafka-ui, rabbitmq, airflow-init, airflow-webserver, airflow-scheduler |
| `monitoring` | prometheus, grafana, postgres-exporter, kafka-exporter, rabbitmq-exporter |
| `tools` | pgadmin |

---

## 3. Tech Stack

| Layer | Technology | Version |
| ----- | ---------- | ------- |
| Backend | Spring Boot | 4.0.6 |
| Language | Java | 25 |
| Frontend | React + Vite | 19 / 6 |
| Frontend server | Nginx | Alpine |
| Database | PostgreSQL | 17 |
| DB migrations | Flyway | embedded |
| ORM | Spring Data JPA / Hibernate | — |
| Message broker (events) | Apache Kafka (KRaft) | 7.9 |
| Message broker (tasks) | RabbitMQ | 4-management |
| JWT | jjwt | 0.12.6 |
| Rate limiting | Bucket4j | 8.10.1 |
| Password hashing | BCrypt | Spring Security |
| API docs | SpringDoc OpenAPI | — |
| Metrics | Micrometer + Prometheus | — |
| Dashboards | Grafana | latest |
| ETL orchestration | Apache Airflow | 2.10.5 |
| Mail sink (dev) | MailHog | latest |
| Container runtime | Docker Compose | v2.24+ |

---

## 4. Features

### Customer

- Register / login / refresh token
- Browse product catalog (search, filter by category/price)
- Add to cart, update quantities, remove items
- Place orders (checkout) with payment reference
- View order history

### Admin / Employee

- Manage products (CRUD, status toggle, image upload)
- Manage categories (CRUD)
- View all orders
- Change user roles

### Security Auditor

- Read-only access to audit logs

### Platform

- RS256 JWT with 30-minute access tokens
- Refresh token rotation (single-use, 7-day TTL)
- Account lockout after 5 failed login attempts (15 min)
- IP-based rate limiting on auth endpoints (20 req/min)
- Correlation ID propagated across all log lines
- Asynchronous email delivery via RabbitMQ → MailHog
- Nightly ETL to star-schema data warehouse
- Prometheus metrics + Grafana dashboards

---

## 5. How to Run

### Prerequisites

- Docker Engine 26+
- Docker Compose v2.24+
- OpenSSL (for JWT key generation — usually pre-installed)

### Quick start

```bash
git clone <repo-url>
cd ecommerce-platform
chmod +x scripts/*.sh
./scripts/dev-up.sh
```

`dev-up.sh` performs first-time initialization automatically:

- Copies `.env.example` → `.env`
- Generates `secrets/postgres_password.txt` (random 48-byte base64)
- Generates `secrets/jwt_private_key.pem` / `secrets/jwt_public_key.pem` (RSA 2048)
- Runs `docker compose up --build -d`

Wait ~30 seconds for the backend to complete Flyway migrations, then open http://localhost:3000.

### With monitoring

```bash
docker compose --profile monitoring up -d
```

### With database admin tools

```bash
docker compose --profile tools up -d
```

### Stopping

```bash
./scripts/dev-down.sh          # stop containers, keep volumes
docker compose down -v          # stop containers and delete all data
```

### Rebuilding after code changes

```bash
./scripts/rebuild.sh
```

---

## 6. Service URLs

| Service | URL | Credentials |
| ------- | --- | ----------- |
| Frontend | http://localhost:3000 | — |
| Backend API | http://localhost:8080 | Bearer token |
| Swagger UI | http://localhost:8080/swagger-ui.html | — |
| Backend Health | http://localhost:8080/actuator/health | — |
| MailHog | http://localhost:8025 | — |
| Kafka UI | http://localhost:8085 | — |
| RabbitMQ UI | http://localhost:15672 | guest / guest |
| Prometheus | http://localhost:9090 | — |
| Grafana | http://localhost:3001 | admin / admin |
| pgAdmin | http://localhost:5050 | admin@local.dev / admin123 |
| Airflow | http://localhost:8088 | admin / admin |

### Quick API test

```bash
# Health check
curl http://localhost:8080/api/health

# List products
curl http://localhost:8080/api/products

# Register
curl -s -X POST http://localhost:8080/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"Test@1234","fullName":"Test User"}' | jq .

# Login and capture token
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"Test@1234"}' | jq -r .accessToken)

# Access protected endpoint
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/auth/me
```

---

## 7. Authentication

### Flow

```
POST /api/auth/login  →  access token (JWT RS256, 30 min)
                     →  refresh token (48-byte random, SHA-256 stored, 7 days)

Subsequent requests  →  Authorization: Bearer <access_token>

POST /api/auth/refresh  →  new access token + new refresh token (rotation)
```

### JWT Claims

```json
{
  "sub": "user@example.com",
  "fullName": "John Doe",
  "role": "CUSTOMER",
  "permissions": ["PRODUCT_READ", "ORDER_READ_OWN"],
  "iat": 1746441600,
  "exp": 1746443400
}
```

### Roles & Permissions

| Role | Permissions |
| ---- | ----------- |
| `ADMIN` | All permissions |
| `EMPLOYEE` | Product/category CRUD, own orders, admin panel |
| `CUSTOMER` | Read products, own cart, own orders |
| `SECURITY_AUDITOR` | Read audit logs only |

### Brute Force Protection

| Mechanism | Configuration |
| --------- | ------------- |
| Account lockout | 5 failures → 15-minute lock on the account |
| Rate limiting | 20 requests/minute per IP on `/api/auth/*` |

---

## 8. Database Design

### OLTP Schema (15 tables)

```
app_user            — users with RBAC columns and lockout tracking
roles               — role definitions
permissions         — granular permission definitions
user_roles          — user ↔ role join
role_permissions    — role ↔ permission join
refresh_tokens      — SHA-256 hashed tokens with expiry and revocation
category            — product categories
products            — product catalog
product_images      — product image gallery
cart_items          — shopping cart (per user email)
customer_orders     — placed orders
customer_order_items — line items per order
payments            — payment records per order
audit_logs          — immutable audit trail
login_attempts      — high-volume login event log (separate from audit_logs)
```

Migrations are managed by Flyway (`V001` through `V010`). See `docs/database/oltp-schema.md` for full column-level detail.

### Data Warehouse (nightly ETL)

Three PostgreSQL schemas on the same instance:

```
public (OLTP)  →  staging (raw copy)  →  dw (star schema)  →  reports (views)
```

**Star schema:**

- `dw.dim_customer`, `dw.dim_product`, `dw.dim_date`
- `dw.fact_orders`, `dw.fact_payments`, `dw.fact_inventory`

**Report views:** `daily_sales_report`, `customer_order_summary`, `product_performance_report`, `failed_payment_report`, `security_audit_report`

See `docs/database/warehouse-schema.md` for full detail.

---

## 9. Kafka & RabbitMQ Flow

### Kafka Topics (6)

| Topic | Published by | Payload summary |
| ----- | ------------ | --------------- |
| `user.registered` | `AuthController` on registration | email, fullName, role |
| `order.created` | `CheckoutService` on checkout | orderId, orderNumber, totalAmount |
| `payment.completed` | `CheckoutService` on payment success | orderId, paymentReference, amount |
| `payment.failed` | `CheckoutService` on payment failure | orderId, reason |
| `inventory.updated` | `CheckoutService` after stock deduction | productId, newStockQuantity |
| `audit.security-event` | `LoginAttemptAuditService` on every login | email (masked), success, failureCode, IP |

All events use a standard `EventEnvelope`:

```json
{
  "eventId": "uuid",
  "eventType": "order.created",
  "occurredAt": "2026-05-05T14:30:00Z",
  "source": "auth-service",
  "correlationId": "uuid",
  "payload": { ... }
}
```

Kafka runs in **KRaft mode** (no ZooKeeper). Each topic has 3 partitions and a 7-day retention.

### RabbitMQ — Mail Task Queue

```
Backend  →  exchange: ecommerce.tasks (direct)
         →  queue: mail.send
         →  consumer: EmailConsumer
         →  MailHog (SMTP :1025)

On failure (3 retries):
         →  queue: mail.send.dlq
```

The mail queue is used for order confirmation and welcome emails. MailHog captures all outgoing email in development — browse sent messages at http://localhost:8025.

See `docs/architecture/event-driven-architecture.md` for message schemas and retry policy.

---

## 10. Airflow ETL

5 DAGs run on a `@daily` schedule. Each DAG follows the same 3-task pattern:

```
create_warehouse_schema  →  refresh_warehouse  →  build_<report>
```

| DAG | Final Report View |
| --- | ----------------- |
| `daily_sales_report` | `reports.daily_sales_report` |
| `product_performance_report` | `reports.product_performance_report` |
| `failed_payment_report` | `reports.failed_payment_report` |
| `customer_order_summary` | `reports.customer_order_summary` |
| `security_audit_report` | `reports.security_audit_report` |

Access the Airflow UI at http://localhost:8088 after starting the `etl` profile. Use `admin` / `admin`.

See `docs/database/warehouse-schema.md` for full schema and SQL.

---

## 11. Monitoring

Start the monitoring stack:

```bash
docker compose --profile monitoring up -d
```

### Prometheus Scrape Targets

| Job | Target | What it collects |
| --- | ------ | ---------------- |
| `ecommerce-backend` | `backend:8080/actuator/prometheus` | JVM, HTTP metrics, custom counters |
| `postgres` | `postgres-exporter:9187` | Connection count, table stats, lock count |
| `kafka` | `kafka-exporter:9308` | Consumer lag, partition offsets |
| `rabbitmq` | `rabbitmq-exporter:9419` | Queue depth, DLQ accumulation |

Scrape interval: 15 seconds.

### Grafana Dashboard

The `backend-overview` dashboard is auto-provisioned from `monitoring/grafana/dashboards/`. It includes HTTP request rate, P99 latency, JVM memory, and login success/failure counters.

Open Grafana at http://localhost:3001 (admin / admin).

See `docs/operations/monitoring.md` for recommended alert rules.

---

## 12. Security

### Security Checklist

#### Authentication & Authorization

| # | Control | Status | File |
|---|---------|--------|------|
| 1 | JWT RS256 (RSA 2048-bit private/public key) | ✅ | `JwtService.java` |
| 2 | Refresh token rotation (single-use) | ✅ | `RefreshTokenService.java` |
| 3 | Refresh token SHA-256 stored (plaintext never persisted) | ✅ | `RefreshTokenService.java` |
| 4 | BCrypt password hashing | ✅ | `SecurityConfig.java` |
| 5 | RBAC — ADMIN, EMPLOYEE, CUSTOMER, SECURITY_AUDITOR | ✅ | `SecurityConfig.java` |
| 6 | Admin-only endpoints (`/api/admin/**`) | ✅ | `SecurityConfig.java` |

#### Brute Force & Rate Limiting

| # | Control | Status | File |
|---|---------|--------|------|
| 7 | IP-based rate limiting on auth endpoints (20 req/min) | ✅ | `RateLimitingFilter.java` |
| 8 | Account lockout (5 failures → 15 min lock) | ✅ | `AccountLockoutService.java` |
| 9 | Lock auto-clears after timeout | ✅ | `AccountLockoutService.java` |
| 10 | Counter reset on successful login | ✅ | `AccountLockoutService.java` |

#### Password Policy

| # | Control | Status | File |
|---|---------|--------|------|
| 11 | Minimum 8 characters | ✅ | `RegisterRequest.java` |
| 12 | Requires uppercase letter | ✅ | `RegisterRequest.java` |
| 13 | Requires lowercase letter | ✅ | `RegisterRequest.java` |
| 14 | Requires digit | ✅ | `RegisterRequest.java` |
| 15 | Requires special character (`@$!%*#?&^_-`) | ✅ | `RegisterRequest.java` |

#### HTTP Security Headers

| # | Header | Value | Status |
|---|--------|-------|--------|
| 16 | `Strict-Transport-Security` | max-age=31536000; includeSubDomains; preload | ✅ |
| 17 | `Content-Security-Policy` | default-src 'self'; script-src 'self'; ... | ✅ |
| 18 | `X-Frame-Options` | DENY | ✅ |
| 19 | `X-Content-Type-Options` | nosniff | ✅ |
| 20 | `Referrer-Policy` | strict-origin-when-cross-origin | ✅ |
| 21 | `Permissions-Policy` | geolocation=(), microphone=(), camera=(), payment=() | ✅ |
| 22 | Frontend Nginx headers | X-Frame-Options, Referrer-Policy, Permissions-Policy | ✅ |

#### CORS

| # | Control | Status |
|---|---------|--------|
| 23 | CORS whitelist (`CORS_ALLOWED_ORIGINS` env var) | ✅ |
| 24 | Allowed HTTP methods restricted | ✅ |
| 25 | `allowCredentials: false` | ✅ |

#### Database Security

| # | Control | Status |
|---|---------|--------|
| 26 | PostgreSQL TLS 1.2+ required | ✅ |
| 27 | SCRAM-SHA-256 authentication | ✅ |
| 28 | Non-SSL TCP connections rejected | ✅ |
| 29 | Parameterized queries only (no raw SQL concatenation) | ✅ |

#### Secret Management

| # | Control | Status |
|---|---------|--------|
| 30 | JWT private key in `secrets/` (not committed to Git) | ✅ |
| 31 | PostgreSQL password mounted as Docker secret | ✅ |
| 32 | `secrets/` and `.env` in `.gitignore` | ✅ |

#### Audit & Logging

| # | Control | Status |
|---|---------|--------|
| 33 | Login success/failure logged to `login_attempts` table | ✅ |
| 34 | Emails masked in all logs (`a***@example.com`) | ✅ |
| 35 | `PERMISSION_DENIED` written to `audit_logs` | ✅ |
| 36 | Correlation ID on every request (MDC + response header) | ✅ |
| 37 | No sensitive data in error responses | ✅ |

#### Container Security

| # | Control | Status |
|---|---------|--------|
| 38 | Non-root user in backend and postgres containers | ✅ |
| 39 | Minimal base image (Alpine / Temurin JRE) | ✅ |
| 40 | Backend/frontend network segmentation | ✅ |

### Security Scripts

```bash
# Scan for leaked secrets in Git history (gitleaks via Docker)
./scripts/scan-secrets.sh

# Scan Docker images for HIGH/CRITICAL CVEs (Trivy via Docker)
./scripts/scan-images.sh

# Run all security checks
./scripts/security-check.sh

# Database backup
./scripts/backup-db.sh

# Database restore
./scripts/restore-db.sh backups/ecommerce_20260505_143022.sql.gz
```

### Security Tests

```bash
docker run --rm -v "$PWD/backend:/app" -w /app maven:3.9-eclipse-temurin-25 \
  mvn test -Dtest=SecurityInputTest,JwtServiceTest
```

`SecurityInputTest` covers: SQL injection payloads (5), XSS payloads (5), weak password rejection (5), strong password acceptance (4), account lockout state, JWT payload tampering.

### Threat Model

A full STRIDE analysis is in `docs/security/threat-model.md`.

**Known gaps (production recommendations):**

| Gap | Recommendation |
| --- | -------------- |
| No HTTPS at backend | Add nginx/Traefik reverse proxy with TLS termination |
| Rate limiting is in-process | Use Redis-backed Bucket4j for multi-instance deployments |
| Swagger UI is public | Restrict to `ROLE_ADMIN` or disable via Spring profile |
| No token revocation on logout | Add Redis-backed token blocklist |
| Account lockout can be abused | Add CAPTCHA or progressive delay |
| No DAST/SAST in CI | Integrate OWASP ZAP and SonarQube |

---

## 13. Screenshots

*Screenshots will be added after the UI is finalized.*

Endpoints to verify manually:

- http://localhost:3000 — React frontend (product catalog, cart, checkout)
- http://localhost:8080/swagger-ui.html — Interactive API documentation
- http://localhost:8025 — MailHog (order confirmation emails)
- http://localhost:8085 — Kafka UI (topic / consumer group inspector)
- http://localhost:15672 — RabbitMQ management (queue depth)
- http://localhost:3001 — Grafana backend overview dashboard
- http://localhost:9090 — Prometheus query explorer
- http://localhost:8088 — Airflow DAG list (profile: etl)

---

## 14. Roadmap

| Item | Status |
| ---- | ------ |
| Core REST API (auth, products, cart, checkout) | ✅ Done |
| JWT RS256 + RBAC + refresh token rotation | ✅ Done |
| Rate limiting + account lockout | ✅ Done |
| Security headers + CORS | ✅ Done |
| Kafka event publishing (6 topics) | ✅ Done |
| RabbitMQ mail queue + DLQ | ✅ Done |
| PostgreSQL TLS + Flyway migrations | ✅ Done |
| Prometheus + Grafana monitoring | ✅ Done |
| Airflow ETL + data warehouse | ✅ Done |
| Audit logging + login attempt tracking | ✅ Done |
| Security test suite (SQL injection, XSS, JWT tampering) | ✅ Done |
| Full documentation (docs/) | ✅ Done |
| Redis-backed token blocklist (logout invalidation) | Planned |
| CAPTCHA / progressive delay on account lockout | Planned |
| CI pipeline (GitHub Actions + Trivy + OWASP ZAP) | Planned |
| HTTPS termination via nginx reverse proxy | Planned |
| Kubernetes / Helm chart | Future |

---

## Documentation Index

| Doc | Description |
| --- | ----------- |
| `docs/architecture/system-overview.md` | Service map, tech stack, design decisions |
| `docs/architecture/event-driven-architecture.md` | Kafka topics, RabbitMQ topology, event schemas |
| `docs/architecture/data-flow.md` | Request flows: login, checkout, token refresh, ETL |
| `docs/architecture/decisions.md` | Architecture Decision Records (ADRs) |
| `docs/database/oltp-schema.md` | All 15 OLTP tables with columns and constraints |
| `docs/database/warehouse-schema.md` | Star schema, Airflow DAGs, report views |
| `docs/database/indexing-strategy.md` | Every index, the query it serves, and the reasoning |
| `docs/security/jwt-rbac.md` | Auth flow, JWT claims, RBAC matrix, security headers |
| `docs/security/threat-model.md` | STRIDE analysis, mitigations, known gaps |
| `docs/security/audit-logging.md` | AuditAction enum, table schemas, Kafka payload |
| `docs/operations/runbook.md` | Start, stop, rebuild, profile switching, troubleshooting |
| `docs/operations/backup-restore.md` | backup-db.sh / restore-db.sh usage guide |
| `docs/operations/monitoring.md` | Prometheus targets, Grafana panels, alert rules |
| `docs/api/endpoints.md` | All 9 controllers, every endpoint with request/response |
