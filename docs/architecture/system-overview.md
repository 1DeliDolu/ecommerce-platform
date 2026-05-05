# System Overview

## What This Project Is

A production-style e-commerce platform built as a portfolio project demonstrating full-stack engineering, distributed systems, observability, and security hardening. It is intentionally over-engineered for a demo store — the goal is to showcase architectural decisions rather than ship a minimal viable product.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        frontend-net                              │
│  ┌──────────────┐      ┌─────────────────────────────────────┐  │
│  │   Frontend   │─────▶│             Backend                 │  │
│  │ React + Vite │      │   Spring Boot 4 · Java 25 · JRE    │  │
│  │  nginx:1.27  │      │          Port 8080                  │  │
│  └──────────────┘      └───────────────┬─────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                                         │  backend-net
        ┌────────────────┬───────────────┼───────────────┐
        ▼                ▼               ▼               ▼
 ┌────────────┐  ┌──────────────┐ ┌──────────┐  ┌──────────────┐
 │ PostgreSQL │  │    Kafka     │ │ RabbitMQ │  │   MailHog    │
 │  17 + TLS  │  │  4.0 KRaft  │ │   3.13   │  │  (dev SMTP)  │
 └────────────┘  └──────────────┘ └──────────┘  └──────────────┘
        │
 ┌──────┴──────────────────┐   (profile: etl)
 │  Airflow 2.10           │──────────────────────────────▶ 5 daily DAGs
 │  Webserver + Scheduler  │   ETL: OLTP → Staging → DW → Reports
 └─────────────────────────┘

 (profile: monitoring)
 ┌───────────────────────────────────────────────────────┐
 │  Prometheus → Grafana   postgres/kafka/rabbitmq       │
 │  exporters scrape every 15s, dashboard on port 3001   │
 └───────────────────────────────────────────────────────┘
```

## Services

| Service                            | Image                                 | Port(s)    | Purpose                                  |
| ---------------------------------- | ------------------------------------- | ---------- | ---------------------------------------- |
| `frontend`                         | nginx:1.27-alpine                     | 3000       | React SPA served by Nginx                |
| `backend`                          | eclipse-temurin:25-jre-alpine         | 8080       | Spring Boot REST API                     |
| `postgres`                         | postgres:17-bookworm                  | 5432       | Primary OLTP database (TLS enforced)     |
| `postgres-certs`                   | alpine:3                              | —          | One-time: generates RSA-4096 TLS certs   |
| `kafka`                            | bitnami/kafka:4.0                     | 9092/9094  | Event streaming (KRaft, no Zookeeper)    |
| `kafka-init`                       | bitnami/kafka:4.0                     | —          | One-time: creates 6 Kafka topics         |
| `kafka-ui`                         | provectuslabs/kafka-ui                | 8085       | Kafka cluster management UI              |
| `rabbitmq`                         | rabbitmq:3.13-management              | 5672/15672 | Task queue for async mail delivery       |
| `mailhog`                          | mailhog:v1.0.1                        | 1025/8025  | Dev SMTP — captures all outgoing email   |
| `pgadmin` _(tools)_                | dpage/pgadmin4                        | 5050       | PostgreSQL management UI                 |
| `prometheus` _(monitoring)_        | prom/prometheus                       | 9090       | Metrics collection (15s scrape)          |
| `grafana` _(monitoring)_           | grafana/grafana-oss                   | 3001       | Dashboards: backend, DB, Kafka, RabbitMQ |
| `postgres-exporter` _(monitoring)_ | prometheuscommunity/postgres-exporter | 9187       | PostgreSQL → Prometheus                  |
| `kafka-exporter` _(monitoring)_    | danielqsj/kafka-exporter              | 9308       | Kafka → Prometheus                       |
| `rabbitmq-exporter` _(monitoring)_ | kbudde/rabbitmq-exporter              | 9419       | RabbitMQ → Prometheus                    |
| `airflow-webserver` _(etl)_        | apache/airflow:2.10.5                 | 8088       | Airflow UI                               |
| `airflow-scheduler` _(etl)_        | apache/airflow:2.10.5                 | —          | DAG scheduler                            |
| `airflow-init` _(etl)_             | apache/airflow:2.10.5                 | —          | One-time: DB init + admin user           |

## Docker Compose Profiles

```bash
# Core only (default)
docker compose up -d

# + pgAdmin
docker compose --profile tools up -d

# + Prometheus + Grafana + exporters
docker compose --profile monitoring up -d

# + Airflow ETL
docker compose --profile etl up -d

# Everything
docker compose --profile tools --profile monitoring --profile etl up -d
```

## Docker Networks

```
backend-net  — postgres, kafka, rabbitmq, backend, monitoring exporters, airflow
frontend-net — backend, frontend
```

Backend sits in both networks, acting as the bridge. Frontend cannot reach the database or message brokers directly.

## Tech Stack

| Layer             | Technology                  | Version |
| ----------------- | --------------------------- | ------- |
| Language          | Java                        | 25      |
| Framework         | Spring Boot                 | 4.0.6   |
| Security          | Spring Security             | 7.x     |
| ORM               | Spring Data JPA / Hibernate | —       |
| Migrations        | Flyway                      | —       |
| JWT               | jjwt                        | 0.12.6  |
| Rate Limiting     | Bucket4j                    | 8.10.1  |
| Database          | PostgreSQL                  | 17      |
| Message Broker    | Apache Kafka (KRaft)        | 4.0     |
| Task Queue        | RabbitMQ                    | 3.13    |
| ETL Orchestration | Apache Airflow              | 2.10.5  |
| Frontend          | React + TypeScript + Vite   | latest  |
| UI Library        | MUI Material + Bootstrap    | 5.x     |
| Metrics           | Micrometer + Prometheus     | —       |
| Dashboards        | Grafana                     | latest  |
| Container Runtime | Docker + Compose            | —       |

## Key Design Decisions

- **Stateless backend** — All state in PostgreSQL and JWTs; no server-side sessions.
- **Asymmetric JWT** — RS256 (RSA 2048) instead of HS256; public key can be distributed to other services without exposing the signing secret.
- **Kafka for domain events** — `user.registered`, `order.created`, `payment.*`, `inventory.updated` are published to Kafka for potential downstream consumers.
- **RabbitMQ for tasks** — Mail delivery is decoupled via a task queue with DLQ and automatic retry (×3, exponential backoff).
- **Airflow for ETL** — Nightly jobs load OLTP data into a star-schema data warehouse inside the same PostgreSQL instance (separate schemas).
- **Flyway for migrations** — Schema changes are versioned and reproducible; `ddl-auto: validate` prevents Hibernate from auto-modifying the schema.

See [decisions.md](decisions.md) for detailed ADRs.
