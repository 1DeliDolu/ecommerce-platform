# Monitoring

Prometheus metrics collection and Grafana dashboards for the ecommerce platform.

---

## Overview

Monitoring runs as an optional Docker Compose profile. The stack consists of:

| Component             | Role                                          |
| --------------------- | --------------------------------------------- |
| **Prometheus**        | Time-series metrics storage and scrape engine |
| **Grafana**           | Dashboards and visualization                  |
| **postgres-exporter** | PostgreSQL metrics adapter                    |
| **kafka-exporter**    | Kafka broker metrics adapter                  |
| **rabbitmq-exporter** | RabbitMQ metrics adapter                      |

---

## Starting the Monitoring Stack

```bash
docker compose --profile monitoring up -d
```

| Service    | URL                   |
| ---------- | --------------------- |
| Prometheus | http://localhost:9090 |
| Grafana    | http://localhost:3001 |

Grafana default credentials: `admin` / `admin`

---

## Prometheus Configuration

Located at `monitoring/prometheus/prometheus.yml`.

### Scrape Targets

| Job Name            | Target                   | Port | Metrics Path           | Scrapes                               |
| ------------------- | ------------------------ | ---- | ---------------------- | ------------------------------------- |
| `prometheus`        | `prometheus:9090`        | 9090 | `/metrics`             | Prometheus self-monitoring            |
| `ecommerce-backend` | `backend:8080`           | 8080 | `/actuator/prometheus` | Spring Boot (JVM, HTTP, custom)       |
| `postgres`          | `postgres-exporter:9187` | 9187 | `/metrics`             | PostgreSQL server metrics             |
| `kafka`             | `kafka-exporter:9308`    | 9308 | `/metrics`             | Kafka broker + consumer group metrics |
| `rabbitmq`          | `rabbitmq-exporter:9419` | 9419 | `/metrics`             | RabbitMQ queue/connection metrics     |

**Global settings:**

```yaml
scrape_interval: 15s
evaluation_interval: 15s
```

All targets are internal container names on the `backend-net` Docker network.

---

## Spring Boot Metrics (`ecommerce-backend` job)

The backend exposes metrics via Spring Boot Actuator at `/actuator/prometheus`. Key metric groups:

### JVM

| Metric                         | Description                    |
| ------------------------------ | ------------------------------ |
| `jvm_memory_used_bytes`        | Heap and non-heap memory usage |
| `jvm_gc_pause_seconds`         | GC pause duration              |
| `jvm_threads_live_threads`     | Active thread count            |
| `jvm_buffer_memory_used_bytes` | Direct/mapped buffer pool      |

### HTTP

| Metric                               | Description                          |
| ------------------------------------ | ------------------------------------ |
| `http_server_requests_seconds_count` | Request count by URI, method, status |
| `http_server_requests_seconds_sum`   | Total latency accumulator            |
| `http_server_requests_seconds_max`   | Max latency in scrape window         |

Useful PromQL — P99 latency for the last 5 minutes:

```promql
histogram_quantile(0.99,
  rate(http_server_requests_seconds_bucket[5m])
)
```

### Custom Application Metrics

| Metric                      | Labels                     | Description           |
| --------------------------- | -------------------------- | --------------------- |
| `auth_login_attempts_total` | `result` (success/failure) | Login attempt counter |
| `auth_register_total`       | `result` (success/failure) | Registration counter  |

### Spring Security Rate Limiting

HTTP 429 responses appear in the standard `http_server_requests_seconds_count` metric with `status="429"`.

---

## PostgreSQL Metrics (`postgres` job)

Key metrics from `postgres-exporter`:

| Metric                           | Description                                |
| -------------------------------- | ------------------------------------------ |
| `pg_up`                          | 1 if PostgreSQL is reachable               |
| `pg_stat_user_tables_seq_scan`   | Sequential scans (missing index indicator) |
| `pg_stat_user_tables_n_live_tup` | Live row count per table                   |
| `pg_database_size_bytes`         | Total database size                        |
| `pg_stat_activity_count`         | Active connections                         |
| `pg_locks_count`                 | Lock count by mode                         |

Useful PromQL — active connections:

```promql
pg_stat_activity_count{datname="ecommerce"}
```

---

## Kafka Metrics (`kafka` job)

Key metrics from `kafka-exporter`:

| Metric                               | Description                         |
| ------------------------------------ | ----------------------------------- |
| `kafka_topic_partitions`             | Number of partitions per topic      |
| `kafka_consumergroup_current_offset` | Current consumer offset             |
| `kafka_consumergroup_lag`            | Consumer lag (offset behind latest) |

Consumer lag alert — if lag exceeds 1000 for any group:

```promql
kafka_consumergroup_lag > 1000
```

Topics in use: `user.registered`, `order.created`, `payment.completed`, `payment.failed`, `inventory.updated`, `audit.security-event`

---

## RabbitMQ Metrics (`rabbitmq` job)

Key metrics from `rabbitmq-exporter`:

| Metric                                   | Description                       |
| ---------------------------------------- | --------------------------------- |
| `rabbitmq_queue_messages`                | Total messages in queue           |
| `rabbitmq_queue_messages_ready`          | Messages ready to consume         |
| `rabbitmq_queue_messages_unacknowledged` | Unacked messages (consumer stuck) |
| `rabbitmq_connections`                   | Active AMQP connections           |

Queues to monitor: `mail.send`, `mail.send.dlq`

DLQ accumulation alert:

```promql
rabbitmq_queue_messages{queue="mail.send.dlq"} > 0
```

---

## Grafana

### Access

URL: http://localhost:3001  
Credentials: `admin` / `admin` (change on first login)

RabbitMQ Management UI (dev): `http://localhost:15672`  
Credentials (dev default): `ecommerce / ecommerce`

### Provisioned Datasource

Prometheus is auto-configured at startup: `http://prometheus:9090`

### Provisioned Dashboard

The `backend-overview.json` dashboard (in `monitoring/grafana/dashboards/`) is loaded automatically into the **Ecommerce** folder. It covers:

- HTTP request rate and error rate
- P50/P99 request latency
- JVM heap and non-heap memory
- Active thread count
- Login success/failure counters

### Adding Custom Dashboards

Place dashboard JSON files in `monitoring/grafana/dashboards/`. They are picked up on the next Grafana restart.

---

## Recommended Alerts

The following alert rules are not yet configured but are recommended for production:

### Backend Availability

```promql
# Alert: backend not reachable for 1 minute
up{job="ecommerce-backend"} == 0
```

### High Error Rate

```promql
# Alert: >5% HTTP 5xx rate over 5 minutes
rate(http_server_requests_seconds_count{status=~"5.."}[5m])
  /
rate(http_server_requests_seconds_count[5m])
> 0.05
```

### High Latency

```promql
# Alert: P99 latency > 2 seconds
histogram_quantile(0.99,
  rate(http_server_requests_seconds_bucket[5m])
) > 2
```

### Rate Limit Abuse

```promql
# Alert: more than 50 HTTP 429 responses in 5 minutes
increase(http_server_requests_seconds_count{status="429"}[5m]) > 50
```

### Database Unavailable

```promql
pg_up == 0
```

### Consumer Lag

```promql
kafka_consumergroup_lag > 1000
```

### DLQ Accumulation

```promql
rabbitmq_queue_messages{queue="mail.send.dlq"} > 0
```

---

## Health Endpoints

In addition to Prometheus metrics, the following endpoints provide quick health checks:

| Endpoint                      | Description                                    |
| ----------------------------- | ---------------------------------------------- |
| `GET /actuator/health`        | Composite health (UP/DOWN + component details) |
| `GET /actuator/health/db`     | Database connectivity                          |
| `GET /actuator/health/kafka`  | Kafka connectivity                             |
| `GET /actuator/health/rabbit` | RabbitMQ connectivity                          |
| `GET /api/health`             | Custom application health endpoint             |
| `GET /actuator/info`          | Build version and git info                     |

---

## Disabling Monitoring

To stop the monitoring stack without affecting the main application:

```bash
docker compose --profile monitoring stop prometheus grafana postgres-exporter kafka-exporter rabbitmq-exporter
```

Or remove the containers:

```bash
docker compose --profile monitoring rm -f prometheus grafana postgres-exporter kafka-exporter rabbitmq-exporter
```
