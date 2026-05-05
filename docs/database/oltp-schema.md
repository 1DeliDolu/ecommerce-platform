# OLTP Schema

The operational database runs on **PostgreSQL 17** with **Flyway** versioned migrations.
Schema validation at startup: `hibernate.ddl-auto=validate`.

---

## Entity-Relationship Summary

```
app_user ──< user_roles >── roles ──< role_permissions >── permissions
app_user ──< refresh_tokens
app_user ──< audit_logs

category ──< products ──< product_images
products ──< cart_items
products ──< customer_order_items >── customer_orders ──< payments

login_attempts  (standalone, no FK)
```

---

## Tables

### `app_user`

Primary user record. Role and permissions are stored as denormalised strings for fast JWT claim population.

| Column                  | Type                                       | Notes                                               |
| ----------------------- | ------------------------------------------ | --------------------------------------------------- |
| `id`                    | BIGSERIAL PK                               |                                                     |
| `email`                 | VARCHAR(255) NOT NULL UNIQUE               |                                                     |
| `password_hash`         | VARCHAR(255) NOT NULL                      | BCrypt                                              |
| `role`                  | VARCHAR(255) NOT NULL DEFAULT `'CUSTOMER'` | `ADMIN`, `EMPLOYEE`, `CUSTOMER`, `SECURITY_AUDITOR` |
| `full_name`             | VARCHAR(200)                               |                                                     |
| `permissions`           | VARCHAR(2000)                              | Comma-separated permission names                    |
| `enabled`               | BOOLEAN NOT NULL DEFAULT TRUE              |                                                     |
| `failed_login_attempts` | INTEGER NOT NULL DEFAULT 0                 | Brute force counter                                 |
| `locked_until`          | TIMESTAMPTZ                                | NULL = not locked                                   |
| `created_at`            | TIMESTAMPTZ NOT NULL DEFAULT NOW()         |                                                     |

**Indexes:** `idx_app_user_email`, `idx_app_user_role`

---

### `roles`

Canonical role definitions.

| Column        | Type                               | Notes                                               |
| ------------- | ---------------------------------- | --------------------------------------------------- |
| `id`          | BIGSERIAL PK                       |                                                     |
| `name`        | VARCHAR(100) NOT NULL UNIQUE       | `ADMIN`, `EMPLOYEE`, `CUSTOMER`, `SECURITY_AUDITOR` |
| `description` | VARCHAR(500)                       |                                                     |
| `created_at`  | TIMESTAMPTZ NOT NULL DEFAULT NOW() |                                                     |

---

### `permissions`

Granular permission definitions.

| Column        | Type                               | Notes          |
| ------------- | ---------------------------------- | -------------- |
| `id`          | BIGSERIAL PK                       |                |
| `name`        | VARCHAR(120) NOT NULL UNIQUE       | See list below |
| `description` | VARCHAR(500)                       |                |
| `created_at`  | TIMESTAMPTZ NOT NULL DEFAULT NOW() |                |

**Seeded permissions:** `ADMIN_PANEL_ACCESS`, `PRODUCT_READ`, `PRODUCT_CREATE`, `PRODUCT_UPDATE`, `PRODUCT_DELETE`, `PRODUCT_IMAGE_UPLOAD`, `PRODUCT_IMAGE_DELETE`, `PRODUCT_IMAGE_SET_PRIMARY`, `CATEGORY_READ`, `CATEGORY_CREATE`, `CATEGORY_UPDATE`, `CATEGORY_DELETE`, `ORDER_READ_OWN`, `ORDER_READ_ALL`, `USER_MANAGE`, `ROLE_MANAGE`, `AUDIT_READ`

---

### `user_roles`

Junction table — user ↔ role.

| Column    | Type                                           | Notes |
| --------- | ---------------------------------------------- | ----- |
| `user_id` | BIGINT NOT NULL → `app_user.id` CASCADE DELETE |       |
| `role_id` | BIGINT NOT NULL → `roles.id` CASCADE DELETE    |       |

**PK:** `(user_id, role_id)`

---

### `role_permissions`

Junction table — role ↔ permission.

| Column          | Type                                              | Notes |
| --------------- | ------------------------------------------------- | ----- |
| `role_id`       | BIGINT NOT NULL → `roles.id` CASCADE DELETE       |       |
| `permission_id` | BIGINT NOT NULL → `permissions.id` CASCADE DELETE |       |

**PK:** `(role_id, permission_id)`

**Seeded assignments:**

- `ADMIN` → all 17 permissions
- `EMPLOYEE` → 8 permissions (no user/role management, no audit read initially)
- `CUSTOMER` → `PRODUCT_READ`, `ORDER_READ_OWN`

---

### `refresh_tokens`

| Column       | Type                                           | Notes                   |
| ------------ | ---------------------------------------------- | ----------------------- |
| `id`         | BIGSERIAL PK                                   |                         |
| `user_id`    | BIGINT NOT NULL → `app_user.id` CASCADE DELETE |                         |
| `token_hash` | VARCHAR(255) NOT NULL UNIQUE                   | SHA-256 of actual token |
| `expires_at` | TIMESTAMPTZ NOT NULL                           | 7 days from creation    |
| `revoked_at` | TIMESTAMPTZ                                    | NULL = active           |
| `created_at` | TIMESTAMPTZ NOT NULL DEFAULT NOW()             |                         |

**Indexes:** `idx_refresh_tokens_user_id`, `idx_refresh_tokens_expires_at`

---

### `category`

| Column          | Type                                    | Notes                  |
| --------------- | --------------------------------------- | ---------------------- |
| `id`            | BIGSERIAL PK                            |                        |
| `name`          | VARCHAR(120) NOT NULL UNIQUE            |                        |
| `slug`          | VARCHAR(140) NOT NULL UNIQUE            | URL-safe identifier    |
| `description`   | VARCHAR(1000)                           |                        |
| `product_count` | INT NOT NULL DEFAULT 0                  | Denormalised counter   |
| `status`        | VARCHAR(20) NOT NULL DEFAULT `'ACTIVE'` | `ACTIVE` \| `INACTIVE` |
| `created_at`    | DATE NOT NULL DEFAULT CURRENT_DATE      |                        |

**Constraint:** `CHK_category_status`

**Seeded:** Electronics, Clothing, Home & Garden, Sports

---

### `products`

| Column           | Type                                    | Notes                  |
| ---------------- | --------------------------------------- | ---------------------- |
| `id`             | BIGSERIAL PK                            |                        |
| `category_id`    | BIGINT NOT NULL → `category.id`         |                        |
| `name`           | VARCHAR(160) NOT NULL                   |                        |
| `slug`           | VARCHAR(180) NOT NULL                   |                        |
| `description`    | VARCHAR(2000)                           |                        |
| `price`          | NUMERIC(12,2) NOT NULL                  | ≥ 0                    |
| `stock_quantity` | INT NOT NULL DEFAULT 0                  | ≥ 0                    |
| `status`         | VARCHAR(20) NOT NULL DEFAULT `'ACTIVE'` | `ACTIVE` \| `INACTIVE` |
| `created_at`     | TIMESTAMP NOT NULL DEFAULT NOW()        |                        |
| `updated_at`     | TIMESTAMP                               |                        |

**Constraints:** `UK_product_category_slug (category_id, slug)`, `CHK_product_status`, `CHK_product_price`, `CHK_product_stock`

**Indexes:** `idx_products_category_id`, `idx_products_status`

---

### `product_images`

| Column               | Type                                           | Notes             |
| -------------------- | ---------------------------------------------- | ----------------- |
| `id`                 | BIGSERIAL PK                                   |                   |
| `product_id`         | BIGINT NOT NULL → `products.id` CASCADE DELETE |                   |
| `original_file_name` | VARCHAR(255) NOT NULL                          |                   |
| `stored_file_name`   | VARCHAR(255) NOT NULL                          | UUID-based        |
| `relative_path`      | VARCHAR(600) NOT NULL                          | Under `/uploads/` |
| `content_type`       | VARCHAR(100) NOT NULL                          | MIME type         |
| `file_size`          | BIGINT NOT NULL                                | Bytes             |
| `image_order`        | INT NOT NULL DEFAULT 0                         | Display sort      |
| `primary_image`      | BOOLEAN NOT NULL DEFAULT FALSE                 |                   |
| `created_at`         | TIMESTAMP NOT NULL DEFAULT NOW()               |                   |

**Index:** `idx_product_images_product_id`

---

### `cart_items`

| Column       | Type                             | Notes                                   |
| ------------ | -------------------------------- | --------------------------------------- |
| `id`         | BIGSERIAL PK                     |                                         |
| `user_email` | VARCHAR(255) NOT NULL            | Cart owner (no FK — allows guest carts) |
| `product_id` | BIGINT NOT NULL → `products.id`  |                                         |
| `quantity`   | INT NOT NULL                     | > 0                                     |
| `created_at` | TIMESTAMP NOT NULL DEFAULT NOW() |                                         |
| `updated_at` | TIMESTAMP                        |                                         |

**Constraints:** `UK_cart_user_product (user_email, product_id)`, `CHK_cart_items_quantity`

**Indexes:** `idx_cart_items_user_email`, `idx_cart_items_product_id`

---

### `customer_orders`

| Column                 | Type                             | Notes                    |
| ---------------------- | -------------------------------- | ------------------------ |
| `id`                   | BIGSERIAL PK                     |                          |
| `order_number`         | VARCHAR(255) NOT NULL UNIQUE     | Human-readable reference |
| `user_email`           | VARCHAR(255) NOT NULL            |                          |
| `status`               | VARCHAR(20) NOT NULL             | See below                |
| `subtotal`             | NUMERIC(12,2) NOT NULL           |                          |
| `shipping_cost`        | NUMERIC(12,2) NOT NULL           |                          |
| `tax`                  | NUMERIC(12,2) NOT NULL           |                          |
| `total_amount`         | NUMERIC(12,2) NOT NULL           |                          |
| `shipping_full_name`   | VARCHAR(255) NOT NULL            |                          |
| `shipping_email`       | VARCHAR(255) NOT NULL            |                          |
| `shipping_phone`       | VARCHAR(255) NOT NULL            |                          |
| `shipping_street`      | VARCHAR(255) NOT NULL            |                          |
| `shipping_city`        | VARCHAR(255) NOT NULL            |                          |
| `shipping_postal_code` | VARCHAR(255) NOT NULL            |                          |
| `shipping_country`     | VARCHAR(255) NOT NULL            |                          |
| `payment_method`       | VARCHAR(255) NOT NULL            |                          |
| `payment_reference`    | VARCHAR(255) NOT NULL            |                          |
| `created_at`           | TIMESTAMP NOT NULL DEFAULT NOW() |                          |

**Status lifecycle:** `CREATED` → `PAID` → `SHIPPED` → `DELIVERED` (or `PAYMENT_FAILED` / `CANCELLED`)

**Indexes:** `idx_customer_orders_user_email`, `idx_customer_orders_status`, `idx_customer_orders_created_at`

---

### `customer_order_items`

Price snapshot — preserves the price at the time of purchase even if the product changes later.

| Column         | Type                                                  | Notes                 |
| -------------- | ----------------------------------------------------- | --------------------- |
| `id`           | BIGSERIAL PK                                          |                       |
| `order_id`     | BIGINT NOT NULL → `customer_orders.id` CASCADE DELETE |                       |
| `product_id`   | BIGINT NOT NULL → `products.id`                       |                       |
| `product_name` | VARCHAR(255) NOT NULL                                 | Snapshot              |
| `product_slug` | VARCHAR(255) NOT NULL                                 | Snapshot              |
| `unit_price`   | NUMERIC(12,2) NOT NULL                                | Price at order time   |
| `quantity`     | INT NOT NULL                                          | > 0                   |
| `line_total`   | NUMERIC(12,2) NOT NULL                                | unit_price × quantity |

**Indexes:** `idx_customer_order_items_order_id`, `idx_customer_order_items_product_id`

---

### `payments`

| Column              | Type                                                  | Notes                   |
| ------------------- | ----------------------------------------------------- | ----------------------- |
| `id`                | BIGSERIAL PK                                          |                         |
| `order_id`          | BIGINT NOT NULL → `customer_orders.id` CASCADE DELETE |                         |
| `payment_reference` | VARCHAR(255) NOT NULL UNIQUE                          | Gateway reference       |
| `method`            | VARCHAR(50) NOT NULL                                  | e.g. `credit_card`      |
| `status`            | VARCHAR(50) NOT NULL                                  | `COMPLETED` \| `FAILED` |
| `amount`            | NUMERIC(12,2) NOT NULL                                | ≥ 0                     |
| `created_at`        | TIMESTAMPTZ NOT NULL DEFAULT NOW()                    |                         |

**Indexes:** `idx_payments_order_id`, `idx_payments_status`

---

### `audit_logs`

| Column          | Type                                      | Notes                                              |
| --------------- | ----------------------------------------- | -------------------------------------------------- |
| `id`            | BIGSERIAL PK                              |                                                    |
| `actor_user_id` | BIGINT → `app_user.id` SET NULL on delete |                                                    |
| `actor_email`   | VARCHAR(255)                              | Denormalised for log retention after user deletion |
| `action`        | VARCHAR(120) NOT NULL                     | See `AuditAction` enum                             |
| `resource_type` | VARCHAR(120) NOT NULL                     |                                                    |
| `resource_id`   | VARCHAR(120)                              |                                                    |
| `ip_address`    | VARCHAR(64)                               |                                                    |
| `user_agent`    | VARCHAR(500)                              |                                                    |
| `details`       | TEXT                                      |                                                    |
| `created_at`    | TIMESTAMPTZ NOT NULL DEFAULT NOW()        |                                                    |

**Indexes:** `idx_audit_logs_actor_user_id`, `idx_audit_logs_action`, `idx_audit_logs_created_at`

---

### `login_attempts`

Dedicated table for brute-force analysis. Separate from `audit_logs` for volume and query reasons.

| Column         | Type                               | Notes                                   |
| -------------- | ---------------------------------- | --------------------------------------- |
| `id`           | BIGSERIAL PK                       |                                         |
| `email`        | VARCHAR(255) NOT NULL              | Masked in application layer             |
| `success`      | BOOLEAN NOT NULL                   |                                         |
| `ip_address`   | VARCHAR(64)                        |                                         |
| `user_agent`   | VARCHAR(500)                       |                                         |
| `failure_code` | VARCHAR(120)                       | `INVALID_CREDENTIALS`, `ACCOUNT_LOCKED` |
| `created_at`   | TIMESTAMPTZ NOT NULL DEFAULT NOW() |                                         |

**Indexes:** `idx_login_attempts_email`, `idx_login_attempts_created_at`, `idx_login_attempts_success`

---

## Migration History

| Version | Description                                                                       |
| ------- | --------------------------------------------------------------------------------- |
| V001    | Create auth schema (app_user)                                                     |
| V002    | Create catalog schema (category, products, product_images)                        |
| V003    | Seed categories                                                                   |
| V004    | Add full_name and permissions columns to app_user                                 |
| V005    | Create roles, permissions, user_roles, role_permissions, refresh_tokens           |
| V006    | Create sales schema (cart_items, customer_orders, customer_order_items, payments) |
| V007    | Create security schema (audit_logs, login_attempts)                               |
| V008    | Seed demo products                                                                |
| V009    | Add AUDIT_READ permission                                                         |
| V010    | Add failed_login_attempts, locked_until to app_user                               |
