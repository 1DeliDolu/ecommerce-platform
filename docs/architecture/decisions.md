# Architecture Decision Records

Short decision log explaining the key choices in this project.

---

## ADR-001 — Spring Boot over Node.js / Python

**Decision:** Java 25 + Spring Boot 4 for the backend.

**Reasons:**

- Spring Security provides battle-tested JWT, RBAC, filter chain, and CORS out of the box.
- Spring Data JPA + Flyway give type-safe queries and versioned migrations without boilerplate.
- Spring Boot's actuator + Micrometer integrates with Prometheus in ~3 lines of config.
- Java's strong typing makes the API contract explicit; compiler catches contract violations at build time.

**Trade-off:** Heavier than Express or FastAPI; slower cold start. Acceptable for a portfolio that demonstrates enterprise Java patterns.

---

## ADR-002 — RS256 JWT over HS256

**Decision:** Asymmetric RSA-2048 signing instead of a shared HMAC secret.

**Reasons:**

- A shared secret (HS256) must be distributed to every service that validates tokens. Leaking it compromises the entire system.
- With RS256, only the backend holds the private key. Any future microservice can verify tokens using the public key without ever knowing the signing secret.
- Aligns with OAuth 2.0 / OIDC best practices.

**Trade-off:** RSA signing is slower than HMAC (~3–5× on commodity hardware). At 30-minute token lifetimes with light traffic, this is immeasurable.

---

## ADR-003 — Kafka for Domain Events, RabbitMQ for Task Queue

**Decision:** Both messaging systems coexist deliberately.

**Kafka is used for domain events** (`user.registered`, `order.created`, etc.) because:

- Events need to be replayed, audited, or consumed by multiple future services.
- Kafka's log-based retention makes it suitable as an event store.
- Consumer groups allow independent consumption rates.

**RabbitMQ is used for the mail task queue** because:

- Mail delivery is a one-time task, not an event to replay.
- RabbitMQ's DLQ + retry policy handles transient SMTP failures cleanly.
- The routing key model (direct exchange) is simpler than Kafka consumer groups for single-consumer task queues.

**Trade-off:** Operating two brokers adds complexity. Justified here for demonstrating knowledge of both patterns.

---

## ADR-004 — Flyway over Hibernate DDL Auto

**Decision:** All schema changes via Flyway migration files; Hibernate runs in `validate` mode.

**Reasons:**

- `ddl-auto: create-drop` or `update` causes silent data loss in production.
- Flyway provides a versioned, reproducible, reviewable history of schema changes.
- Enables rollback scripts and pre-deployment verification in CI.

---

## ADR-005 — In-Process Data Warehouse (same PostgreSQL, separate schemas)

**Decision:** ETL writes to `staging`, `dw`, and `reports` schemas inside the same PostgreSQL instance.

**Reasons:**

- A separate warehouse (Redshift, BigQuery) would require networking, credentials, and cost.
- PostgreSQL schemas provide sufficient isolation for a demo: `SET search_path` scopes queries.
- The star schema demonstrates dimensional modeling without infrastructure overhead.

**Trade-off:** In production, heavy analytical queries on the same instance would compete with OLTP. The correct solution is a read replica or a separate OLAP store.

---

## ADR-006 — Bucket4j for Rate Limiting (in-process)

**Decision:** Bucket4j token-bucket in JVM memory, keyed by client IP.

**Reasons:**

- No external dependency (Redis, nginx) required for a single-instance demo.
- Bucket4j is the standard Java library for in-process rate limiting.

**Trade-off:** State is not shared across multiple backend instances. For horizontal scaling, a distributed bucket (Bucket4j + Redis) or API gateway rate limiting is needed.

---

## ADR-007 — Airflow for ETL Orchestration

**Decision:** Apache Airflow 2.10 with LocalExecutor for nightly warehouse refresh.

**Reasons:**

- DAG-based scheduling with dependency ordering (`create_schema` → `refresh_warehouse` → `build_report`).
- Retry, alerting, and run history built in.
- The Postgres connection abstraction keeps SQL files separate from orchestration code.

**Trade-off:** Airflow is heavyweight for 5 simple SQL jobs. `pg_cron` would work equally well in production at lower cost. Airflow is chosen here to demonstrate familiarity with the tool.

---

## ADR-008 — PostgreSQL TLS with Self-Signed Certificates

**Decision:** Enforce TLS 1.2+ on all PostgreSQL connections; certificates generated at container startup.

**Reasons:**

- Demonstrates production-grade database connection security.
- `sslmode=verify-full` prevents man-in-the-middle on the DB connection.
- Certificate generation is automated (`postgres-certs` container) — no manual step.

**Trade-off:** Self-signed certs require distributing the CA cert to clients. In production, use a private CA or a managed certificate service.
