# 🛒 Ecommerce Platform

![Java](https://img.shields.io/badge/Java-25-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.6-brightgreen)
![React](https://img.shields.io/badge/React-19-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-blue)
![Kafka](https://img.shields.io/badge/Kafka-KRaft-black)
![RabbitMQ](https://img.shields.io/badge/RabbitMQ-4-orange)
![Airflow](https://img.shields.io/badge/Airflow-2.10.5-017CEE)
![Docker](https://img.shields.io/badge/Docker%20Compose-v2.24%2B-blue)
![Security](https://img.shields.io/badge/Security-RS256%20%7C%20RBAC%20%7C%20TLS-green)

A production-style full-stack ecommerce platform built as a portfolio project.

This project demonstrates a modern backend architecture with secure authentication, role-based authorization, event-driven messaging, observability, automated ETL pipelines, and a PostgreSQL-backed data warehouse — all runnable locally with Docker Compose.

---

## ✨ Highlights

- Customer-facing ecommerce REST API
- Admin API for product, category, order, and role management
- JWT authentication using RS256 public/private key signing
- Refresh token rotation with single-use tokens
- Role-Based Access Control: `ADMIN`, `EMPLOYEE`, `CUSTOMER`, `SECURITY_AUDITOR`
- PostgreSQL 17 with TLS, SCRAM-SHA-256, Flyway migrations, and warehouse schemas
- Kafka event publishing in KRaft mode
- RabbitMQ task queue for async email delivery
- MailHog for local email testing
- Apache Airflow DAGs for nightly warehouse/report refreshes
- Prometheus metrics and Grafana dashboards
- Security hardening: rate limiting, account lockout, audit logs, security headers
- Docker Compose profiles for monitoring, ETL, and database tooling

---

## 📚 Table of Contents

- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Service URLs](#-service-urls)
- [Authentication](#-authentication)
- [Database Design](#-database-design)
- [Event-Driven Flow](#-event-driven-flow)
- [Airflow ETL](#-airflow-etl)
- [Monitoring](#-monitoring)
- [Security](#-security)
- [Testing](#-testing)
- [Roadmap](#-roadmap)
- [Documentation](#-documentation)

---

## 🧱 Architecture

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                              Docker Compose                                  │
│                                                                              │
│  ┌─────────────┐        REST        ┌──────────────────────────────────────┐ │
│  │ React/Vite  │ ◀────────────────▶ │ Spring Boot Backend                  │ │
│  │ Frontend    │                    │                                      │ │
│  │ Nginx       │                    │ Controllers → Services → Repositories│ │
│  └─────────────┘                    │                                      │ │
│                                     │ Spring Security                      │ │
│                                     │ JWT RS256 • RBAC • Rate Limiting     │ │
│                                     │ Account Lockout • Security Headers   │ │
│                                     └───────────────┬──────────────────────┘ │
│                                                     │                        │
│               ┌─────────────────────────────────────┼─────────────────────┐  │
│               │                                     │                     │  │
│       ┌───────▼────────┐                    ┌───────▼────────┐    ┌──────▼──────┐
│       │ PostgreSQL 17  │                    │ Kafka KRaft    │    │ RabbitMQ    │
│       │ TLS 1.2+       │                    │ Domain Events  │    │ Task Queue  │
│       │ Flyway         │                    └───────┬────────┘    └──────┬──────┘
│       │ OLTP + DW      │                            │                    │
│       └───────┬────────┘                            │                    │
│               │                                     │                    │
│       ┌───────▼────────┐                    ┌───────▼────────┐    ┌──────▼──────┐
│       │ Airflow ETL    │                    │ Kafka UI       │    │ Email Worker│
│       │ Staging → DW   │                    │ Topic Viewer   │    │ MailHog SMTP│
│       │ Reports        │                    └────────────────┘    └─────────────┘
│       └────────────────┘                                                        │
│                                                                              │
│       ┌──────────────────────────────────────────────────────────────────┐   │
│       │ Observability                                                     │   │
│       │ Prometheus → backend, PostgreSQL, Kafka, RabbitMQ → Grafana       │   │
│       └──────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 🧰 Tech Stack

| Layer | Technology |
| --- | --- |
| Backend | Spring Boot 4.0.6 |
| Language | Java 25 |
| Frontend | React 19 + Vite 6 |
| Frontend Server | Nginx Alpine |
| Database | PostgreSQL 17 |
| Migrations | Flyway |
| ORM | Spring Data JPA / Hibernate |
| Authentication | JWT RS256, Refresh Token Rotation |
| Authorization | Spring Security RBAC |
| Messaging | Apache Kafka KRaft, RabbitMQ |
| Email Testing | MailHog |
| ETL | Apache Airflow 2.10.5 |
| Metrics | Micrometer + Prometheus |
| Dashboards | Grafana |
| Container Runtime | Docker Compose v2.24+ |
| Security Scanning | Gitleaks, Trivy |

---

## 🚀 Features

### Customer

- Register, login, and refresh session
- Browse product catalog
- Search and filter products
- Add, update, and remove cart items
- Checkout with payment reference
- View order history

### Admin / Employee

- Create, update, delete, and toggle products
- Manage categories
- Upload product images
- View and manage orders
- Change user roles

### Security Auditor

- Read-only access to audit logs
- Review login events and security actions

### Platform Capabilities

- RS256 JWT signing with RSA key pair
- 30-minute access tokens
- 7-day refresh tokens
- Single-use refresh token rotation
- Account lockout after repeated failed logins
- IP-based rate limiting on auth endpoints
- Correlation ID propagation across logs and responses
- Kafka domain event publishing
- RabbitMQ email task queue with DLQ
- Nightly ETL into star-schema warehouse
- Prometheus metrics and Grafana dashboards

---

## ⚡ Quick Start

### Prerequisites

- Docker Engine 26+
- Docker Compose v2.24+
- OpenSSL
- `jq` for API testing examples

### Run Locally

```bash
git clone <repo-url>
cd ecommerce-platform

chmod +x scripts/*.sh
./scripts/dev-up.sh
```

The startup script performs first-time initialization automatically:

- Copies `.env.example` to `.env`
- Generates a PostgreSQL password secret
- Generates RSA private/public keys for JWT signing
- Starts the application stack with Docker Compose
- Runs Flyway migrations on backend startup

Once the stack is ready, open:

```text
http://localhost:3000
```

### Start with Monitoring

```bash
docker compose --profile monitoring up -d
```

### Start with ETL Services

```bash
docker compose --profile etl up -d
```

### Start with Database Tools

```bash
docker compose --profile tools up -d
```

### Stop Services

```bash
./scripts/dev-down.sh
```

To remove containers and volumes:

```bash
docker compose down -v
```

### Rebuild After Code Changes

```bash
./scripts/rebuild.sh
```

---

## 🔗 Service URLs

| Service | URL | Credentials |
| --- | --- | --- |
| Frontend | http://localhost:3000 | — |
| Backend API | http://localhost:8080 | Bearer token |
| Swagger UI | http://localhost:8080/swagger-ui.html | — |
| Backend Health | http://localhost:8080/actuator/health | — |
| MailHog | http://localhost:8025 | — |
| Kafka UI | http://localhost:8085 | — |
| RabbitMQ UI | http://localhost:15672 | `guest / guest` |
| Prometheus | http://localhost:9090 | — |
| Grafana | http://localhost:3001 | `admin / admin` |
| pgAdmin | http://localhost:5050 | `admin@local.dev / admin123` |
| Airflow | http://localhost:8088 | `admin / admin` |

---

## 🧪 Quick API Test

```bash
curl http://localhost:8080/api/health
```

```bash
curl http://localhost:8080/api/products
```

Register a user:

```bash
curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@1234",
    "fullName": "Test User"
  }' | jq .
```

Login and capture an access token:

```bash
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@1234"
  }' | jq -r .accessToken)
```

Access a protected endpoint:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/auth/me
```

---

## 🔐 Authentication

### Login Flow

```text
POST /api/auth/login
        │
        ├── accessToken  → JWT RS256, 30-minute TTL
        └── refreshToken → random token, SHA-256 stored, 7-day TTL
```

Subsequent authenticated requests use:

```http
Authorization: Bearer <access_token>
```

Refresh tokens are rotated on every use:

```text
POST /api/auth/refresh
        │
        ├── returns new access token
        └── returns new single-use refresh token
```

### Example JWT Claims

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

### Roles

| Role | Access |
| --- | --- |
| `ADMIN` | Full system access |
| `EMPLOYEE` | Product, category, order, and admin-panel access |
| `CUSTOMER` | Product browsing, cart, checkout, own orders |
| `SECURITY_AUDITOR` | Read-only audit log access |

---

## 🗄️ Database Design

The platform uses PostgreSQL for both transactional data and analytical reporting.

```text
public   → OLTP application schema
staging  → raw ETL copy layer
dw       → dimensional warehouse schema
reports  → reporting views
```

### OLTP Tables

```text
app_user
roles
permissions
user_roles
role_permissions
refresh_tokens
category
products
product_images
cart_items
customer_orders
customer_order_items
payments
audit_logs
login_attempts
```

### Warehouse Model

The warehouse follows a star-schema design.

#### Dimensions

```text
dw.dim_customer
dw.dim_product
dw.dim_date
```

#### Facts

```text
dw.fact_orders
dw.fact_payments
dw.fact_inventory
```

#### Report Views

```text
reports.daily_sales_report
reports.customer_order_summary
reports.product_performance_report
reports.failed_payment_report
reports.security_audit_report
```

---

## 📬 Event-Driven Flow

The backend publishes domain events to Kafka and task messages to RabbitMQ.

### Kafka Topics

| Topic | Trigger |
| --- | --- |
| `user.registered` | New user registration |
| `order.created` | Successful checkout |
| `payment.completed` | Payment success |
| `payment.failed` | Payment failure |
| `inventory.updated` | Stock deduction after checkout |
| `audit.security-event` | Login success/failure event |

All Kafka messages use a standard event envelope:

```json
{
  "eventId": "uuid",
  "eventType": "order.created",
  "occurredAt": "2026-05-05T14:30:00Z",
  "source": "checkout-service",
  "correlationId": "uuid",
  "payload": {
    "orderId": 1001,
    "orderNumber": "ORD-20260505-0001",
    "totalAmount": 149.99
  }
}
```

Kafka runs in KRaft mode without ZooKeeper.

Default topic configuration:

```text
partitions: 3
retention: 7 days
```

### RabbitMQ Mail Queue

```text
Backend
  │
  ▼
exchange: ecommerce.tasks
  │
  ▼
queue: mail.send
  │
  ▼
EmailConsumer
  │
  ▼
MailHog SMTP
```

Failed email jobs are retried and then routed to:

```text
mail.send.dlq
```

RabbitMQ is used for:

- Welcome emails
- Order confirmation emails
- Future async background tasks

---

## 🌊 Airflow ETL

Airflow runs daily warehouse refresh jobs.

Each DAG follows the same structure:

```text
create_warehouse_schema
        │
        ▼
refresh_warehouse
        │
        ▼
build_<report>
```

### DAGs

| DAG | Output |
| --- | --- |
| `daily_sales_report` | `reports.daily_sales_report` |
| `product_performance_report` | `reports.product_performance_report` |
| `failed_payment_report` | `reports.failed_payment_report` |
| `customer_order_summary` | `reports.customer_order_summary` |
| `security_audit_report` | `reports.security_audit_report` |

Start ETL services:

```bash
docker compose --profile etl up -d
```

Open Airflow:

```text
http://localhost:8088
```

Credentials:

```text
admin / admin
```

---

## 📈 Monitoring

Start the monitoring stack:

```bash
docker compose --profile monitoring up -d
```

### Prometheus Targets

| Job | Target | Metrics |
| --- | --- | --- |
| `ecommerce-backend` | `backend:8080/actuator/prometheus` | JVM, HTTP, custom app metrics |
| `postgres` | `postgres-exporter:9187` | Connections, locks, table stats |
| `kafka` | `kafka-exporter:9308` | Consumer lag, partitions, offsets |
| `rabbitmq` | `rabbitmq-exporter:9419` | Queue depth, DLQ size, message rates |

Scrape interval:

```text
15 seconds
```

### Grafana

Grafana is available at:

```text
http://localhost:3001
```

Credentials:

```text
admin / admin
```

The auto-provisioned `backend-overview` dashboard includes:

- HTTP request rate
- P99 latency
- JVM memory usage
- Login success/failure counters
- Backend health indicators

---

## 🛡️ Security

This project includes several security controls typically expected in production-oriented backend systems.

### Authentication & Authorization

| Control | Status |
| --- | --- |
| JWT RS256 signing | ✅ |
| RSA 2048-bit key pair | ✅ |
| Refresh token rotation | ✅ |
| Single-use refresh tokens | ✅ |
| Refresh token SHA-256 hashing | ✅ |
| BCrypt password hashing | ✅ |
| Role-Based Access Control | ✅ |
| Admin endpoint protection | ✅ |

### Brute Force Protection

| Control | Configuration |
| --- | --- |
| Account lockout | 5 failed attempts → 15-minute lock |
| Rate limiting | 20 auth requests/minute/IP |
| Counter reset | On successful login |
| Login audit | Success and failure attempts logged |

### Password Policy

Passwords must contain:

- Minimum 8 characters
- Uppercase letter
- Lowercase letter
- Digit
- Special character: `@$!%*#?&^_-`

### HTTP Security Headers

| Header | Value |
| --- | --- |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains; preload` |
| `Content-Security-Policy` | Restrictive self-based policy |
| `X-Frame-Options` | `DENY` |
| `X-Content-Type-Options` | `nosniff` |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |
| `Permissions-Policy` | `geolocation=(), microphone=(), camera=(), payment=()` |

### Database Security

| Control | Status |
| --- | --- |
| PostgreSQL TLS 1.2+ | ✅ |
| SCRAM-SHA-256 authentication | ✅ |
| Non-SSL TCP rejection | ✅ |
| Parameterized repository access | ✅ |
| Flyway-managed migrations | ✅ |

### Secret Management

| Secret | Storage |
| --- | --- |
| PostgreSQL password | Docker secret |
| JWT private key | `secrets/` directory |
| JWT public key | `secrets/` directory |
| Environment values | `.env` |
| Git protection | `.gitignore` excludes secrets and `.env` |

### Audit & Logging

| Control | Status |
| --- | --- |
| Login attempts table | ✅ |
| Security audit log table | ✅ |
| Permission-denied events | ✅ |
| Masked emails in logs | ✅ |
| Correlation ID per request | ✅ |
| Sensitive error suppression | ✅ |

---

## 🧪 Testing

Run selected backend security tests:

```bash
docker run --rm \
  -v "$PWD/backend:/app" \
  -w /app \
  maven:3.9-eclipse-temurin-25 \
  mvn test -Dtest=SecurityInputTest,JwtServiceTest
```

Security tests cover:

- SQL injection payload rejection
- XSS payload rejection
- Weak password rejection
- Strong password acceptance
- Account lockout behavior
- JWT payload tampering

---

## 🔍 Security Scripts

Scan Git history for leaked secrets:

```bash
./scripts/scan-secrets.sh
```

Scan Docker images for high and critical CVEs:

```bash
./scripts/scan-images.sh
```

Run all security checks:

```bash
./scripts/security-check.sh
```

Backup database:

```bash
./scripts/backup-db.sh
```

Restore database:

```bash
./scripts/restore-db.sh backups/ecommerce_20260505_143022.sql.gz
```

---

## 🧭 Docker Compose Profiles

| Profile | Purpose | Services |
| --- | --- | --- |
| default | Core application | PostgreSQL, backend, frontend, Kafka, Kafka UI, RabbitMQ, MailHog |
| `monitoring` | Observability | Prometheus, Grafana, exporters |
| `etl` | Warehouse pipelines | Airflow webserver, scheduler, init |
| `tools` | Admin utilities | pgAdmin |

---

## 📸 Screenshots

Screenshots will be added after the UI is finalized.

Suggested screenshots:

| Area | URL |
| --- | --- |
| Product Catalog | http://localhost:3000 |
| Swagger UI | http://localhost:8080/swagger-ui.html |
| MailHog | http://localhost:8025 |
| Kafka UI | http://localhost:8085 |
| RabbitMQ UI | http://localhost:15672 |
| Grafana Dashboard | http://localhost:3001 |
| Prometheus | http://localhost:9090 |
| Airflow DAGs | http://localhost:8088 |

---

## 🗺️ Roadmap

| Item | Status |
| --- | --- |
| Core REST API | ✅ Done |
| JWT RS256 authentication | ✅ Done |
| RBAC authorization | ✅ Done |
| Refresh token rotation | ✅ Done |
| Rate limiting | ✅ Done |
| Account lockout | ✅ Done |
| Security headers | ✅ Done |
| CORS hardening | ✅ Done |
| Kafka event publishing | ✅ Done |
| RabbitMQ mail queue with DLQ | ✅ Done |
| PostgreSQL TLS | ✅ Done |
| Flyway migrations | ✅ Done |
| Prometheus metrics | ✅ Done |
| Grafana dashboards | ✅ Done |
| Airflow ETL | ✅ Done |
| Star-schema warehouse | ✅ Done |
| Audit logging | ✅ Done |
| Security test suite | ✅ Done |
| Full documentation | ✅ Done |
| Redis-backed token blocklist | Planned |
| CAPTCHA or progressive login delay | Planned |
| GitHub Actions CI pipeline | Planned |
| OWASP ZAP / SonarQube integration | Planned |
| HTTPS termination with nginx or Traefik | Planned |
| Kubernetes / Helm deployment | Future |

---

## ⚠️ Production Notes

This project is designed as a local, portfolio-grade simulation of production architecture.

For real production deployment, recommended additions include:

- TLS termination through nginx, Traefik, or a cloud load balancer
- Redis-backed distributed rate limiting
- Redis-backed JWT/token revocation
- Private Swagger UI or disabled API docs in production
- Centralized log aggregation
- SAST and DAST in CI
- Secrets manager integration
- Kubernetes deployment with health probes and resource limits
- Managed PostgreSQL, Kafka, and RabbitMQ services

---

## 📖 Documentation

| Document | Description |
| --- | --- |
| `docs/architecture/system-overview.md` | Service map, tech stack, design decisions |
| `docs/architecture/event-driven-architecture.md` | Kafka topics, RabbitMQ topology, event schemas |
| `docs/architecture/data-flow.md` | Login, checkout, refresh token, and ETL flows |
| `docs/architecture/decisions.md` | Architecture Decision Records |
| `docs/database/oltp-schema.md` | OLTP table definitions and constraints |
| `docs/database/warehouse-schema.md` | Warehouse schema, DAGs, and report views |
| `docs/database/indexing-strategy.md` | Indexes, served queries, and reasoning |
| `docs/security/jwt-rbac.md` | JWT, RBAC, claims, permissions, headers |
| `docs/security/threat-model.md` | STRIDE threat model |
| `docs/security/audit-logging.md` | Audit actions, schema, Kafka payloads |
| `docs/operations/runbook.md` | Start, stop, rebuild, troubleshoot |
| `docs/operations/backup-restore.md` | Backup and restore guide |
| `docs/operations/monitoring.md` | Prometheus, Grafana, and alert rules |
| `docs/api/endpoints.md` | Controllers, endpoints, requests, responses |

---

## 👤 Author

Built as a full-stack backend-focused portfolio project to demonstrate:

- Secure API design
- Production-style Spring Boot architecture
- Event-driven system patterns
- Database and warehouse modeling
- Local DevOps with Docker Compose
- Observability and operational readiness

---

## 📄 License

This project is available for educational and portfolio use.