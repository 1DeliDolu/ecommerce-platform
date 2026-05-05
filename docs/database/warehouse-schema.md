# Data Warehouse Schema

The warehouse lives inside the **same PostgreSQL 17 instance** as the OLTP database, isolated in three separate schemas: `staging`, `dw`, and `reports`. Nightly Airflow DAGs refresh the data.

---

## Schema Layout

```
public (OLTP)
    │  nightly ETL (Airflow @daily)
    ▼
staging          — raw copies of OLTP tables (truncate-and-insert)
    │  transform + load
    ▼
dw               — star schema (dimensions + facts)
    │  views
    ▼
reports          — analytics-ready views for dashboards / queries
```

---

## Staging Schema

Full snapshot of relevant OLTP tables. Truncated and reloaded on every ETL run — no history kept here.

### `staging.orders`

| Column              | Type          |
| ------------------- | ------------- |
| `id`                | BIGINT PK     |
| `order_number`      | VARCHAR(255)  |
| `user_email`        | VARCHAR(255)  |
| `status`            | VARCHAR(20)   |
| `subtotal`          | NUMERIC(12,2) |
| `shipping_cost`     | NUMERIC(12,2) |
| `tax`               | NUMERIC(12,2) |
| `total_amount`      | NUMERIC(12,2) |
| `payment_method`    | VARCHAR(255)  |
| `payment_reference` | VARCHAR(255)  |
| `created_at`        | TIMESTAMP     |

### `staging.order_items`

| Column         | Type          |
| -------------- | ------------- |
| `id`           | BIGINT PK     |
| `order_id`     | BIGINT        |
| `product_id`   | BIGINT        |
| `product_name` | VARCHAR(255)  |
| `product_slug` | VARCHAR(255)  |
| `unit_price`   | NUMERIC(12,2) |
| `quantity`     | INT           |
| `line_total`   | NUMERIC(12,2) |

### `staging.products`

| Column           | Type          |
| ---------------- | ------------- |
| `id`             | BIGINT PK     |
| `category_id`    | BIGINT        |
| `name`           | VARCHAR(160)  |
| `slug`           | VARCHAR(180)  |
| `price`          | NUMERIC(12,2) |
| `stock_quantity` | INT           |
| `status`         | VARCHAR(20)   |
| `created_at`     | TIMESTAMP     |
| `updated_at`     | TIMESTAMP     |

### `staging.audit_logs`

| Column          | Type         |
| --------------- | ------------ |
| `id`            | BIGINT PK    |
| `actor_email`   | VARCHAR(255) |
| `action`        | VARCHAR(120) |
| `resource_type` | VARCHAR(120) |
| `resource_id`   | VARCHAR(120) |
| `details`       | TEXT         |
| `created_at`    | TIMESTAMPTZ  |

---

## Data Warehouse Schema (Star Schema)

### Dimension Tables

#### `dw.dim_customer`

| Column         | Type                         | Notes         |
| -------------- | ---------------------------- | ------------- |
| `customer_key` | BIGSERIAL PK                 | Surrogate key |
| `email`        | VARCHAR(255) NOT NULL UNIQUE | Natural key   |

Populated from distinct `user_email` values in `staging.orders`. `ON CONFLICT DO NOTHING` — customers are never deleted.

#### `dw.dim_product`

| Column          | Type                   | Notes                     |
| --------------- | ---------------------- | ------------------------- |
| `product_key`   | BIGSERIAL PK           | Surrogate key             |
| `product_id`    | BIGINT NOT NULL UNIQUE | Natural key               |
| `name`          | VARCHAR(160)           |                           |
| `slug`          | VARCHAR(180)           |                           |
| `category_id`   | BIGINT                 |                           |
| `current_price` | NUMERIC(12,2)          | Latest price from staging |
| `status`        | VARCHAR(20)            |                           |

Upserted on each ETL run — reflects current product state.

#### `dw.dim_date`

| Column     | Type    | Notes |
| ---------- | ------- | ----- |
| `date_key` | DATE PK |       |
| `year`     | INT     |       |
| `month`    | INT     |       |
| `day`      | INT     |       |

Populated from order dates. Simple calendar dimension — extend with `quarter`, `day_of_week` as needed.

---

### Fact Tables

#### `dw.fact_orders`

Central fact table. One row per order.

| Column          | Type                                    | Notes                       |
| --------------- | --------------------------------------- | --------------------------- |
| `order_id`      | BIGINT PK → `public.customer_orders.id` |                             |
| `order_number`  | VARCHAR(255)                            |                             |
| `customer_key`  | BIGINT → `dw.dim_customer`              |                             |
| `date_key`      | DATE → `dw.dim_date`                    | Order date                  |
| `status`        | VARCHAR(20)                             |                             |
| `subtotal`      | NUMERIC(12,2)                           |                             |
| `shipping_cost` | NUMERIC(12,2)                           |                             |
| `tax`           | NUMERIC(12,2)                           |                             |
| `total_amount`  | NUMERIC(12,2)                           |                             |
| `item_count`    | INT                                     | Aggregated from order_items |

#### `dw.fact_payments`

One row per payment attempt.

| Column              | Type                      | Notes                   |
| ------------------- | ------------------------- | ----------------------- |
| `payment_reference` | VARCHAR(255) PK           |                         |
| `order_id`          | BIGINT → `dw.fact_orders` |                         |
| `date_key`          | DATE → `dw.dim_date`      |                         |
| `payment_method`    | VARCHAR(255)              |                         |
| `status`            | VARCHAR(50)               | `COMPLETED` \| `FAILED` |
| `amount`            | NUMERIC(12,2)             |                         |

#### `dw.fact_inventory`

Point-in-time stock snapshot. Upserted on each ETL run.

| Column           | Type                      | Notes                |
| ---------------- | ------------------------- | -------------------- |
| `product_id`     | BIGINT PK                 |                      |
| `product_key`    | BIGINT → `dw.dim_product` |                      |
| `stock_quantity` | INT                       |                      |
| `snapshot_date`  | DATE                      | Date of last ETL run |

---

## Reports Schema (Views)

All views are rebuilt on each ETL run via `CREATE OR REPLACE VIEW`.

### `reports.daily_sales_report`

```sql
SELECT date_key,
       COUNT(*)             AS order_count,
       SUM(item_count)      AS item_count,
       SUM(total_amount)    AS gross_sales
FROM dw.fact_orders
GROUP BY date_key
ORDER BY date_key DESC;
```

### `reports.customer_order_summary`

```sql
SELECT c.email,
       COUNT(o.order_id)    AS order_count,
       SUM(o.total_amount)  AS total_spend,
       MAX(o.date_key)      AS last_order_date
FROM dw.dim_customer c
LEFT JOIN dw.fact_orders o ON o.customer_key = c.customer_key
GROUP BY c.email;
```

### `reports.product_performance_report`

```sql
SELECT p.product_id, p.name, p.status,
       i.stock_quantity, i.snapshot_date
FROM dw.dim_product p
LEFT JOIN dw.fact_inventory i ON i.product_key = p.product_key;
```

### `reports.failed_payment_report`

```sql
SELECT payment_reference, order_id, date_key,
       payment_method, amount
FROM dw.fact_payments
WHERE status = 'PAYMENT_FAILED';
```

### `reports.security_audit_report`

```sql
SELECT actor_email, action, resource_type,
       COUNT(*)      AS event_count,
       MAX(created_at) AS last_seen_at
FROM staging.audit_logs
GROUP BY actor_email, action, resource_type;
```

---

## Airflow ETL

5 DAGs, all scheduled `@daily`. Each follows the same 3-task pattern:

```
create_warehouse_schema → refresh_warehouse → build_<report>
```

| DAG                          | Final task                         |
| ---------------------------- | ---------------------------------- |
| `daily_sales_report`         | `build_daily_sales_report`         |
| `product_performance_report` | `build_product_performance_report` |
| `failed_payment_report`      | `build_failed_payment_report`      |
| `customer_order_summary`     | `build_customer_order_summary`     |
| `security_audit_report`      | `build_security_audit_report`      |

**Task 1 — `create_warehouse_schema`**
Idempotent DDL: `CREATE SCHEMA IF NOT EXISTS` + `CREATE TABLE IF NOT EXISTS` for all staging, dw, and reports objects.

**Task 2 — `refresh_warehouse`**
`TRUNCATE staging.*` then bulk-insert from OLTP. Upsert dimensions and facts.

**Task 3 — `build_<report>`**
`CREATE OR REPLACE VIEW reports.<name> AS SELECT ...`

Access Airflow UI at **http://localhost:8088** (profile: `etl`).
