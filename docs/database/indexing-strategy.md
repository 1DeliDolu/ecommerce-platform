# Indexing Strategy

All indexes defined in Flyway migrations V001–V007. Summary of every index, the queries it serves, and the reasoning.

---

## `app_user`

| Index                | Columns | Type   | Purpose                                                              |
| -------------------- | ------- | ------ | -------------------------------------------------------------------- |
| `idx_app_user_email` | `email` | B-tree | Login lookup: `findByEmailIgnoreCase` — every authentication request |
| `idx_app_user_role`  | `role`  | B-tree | Admin queries filtering users by role                                |

`email` has a `UNIQUE` constraint (implicit unique index). The explicit `idx_app_user_email` ensures case-insensitive queries via `LOWER(email)` can leverage the index with a functional index if needed in the future.

---

## `refresh_tokens`

| Index                           | Columns      | Type   | Purpose                                      |
| ------------------------------- | ------------ | ------ | -------------------------------------------- |
| `idx_refresh_tokens_user_id`    | `user_id`    | B-tree | Revoke all tokens for a user on login/logout |
| `idx_refresh_tokens_expires_at` | `expires_at` | B-tree | Periodic cleanup of expired tokens           |

`token_hash` has a `UNIQUE` constraint — the primary lookup path for token validation.

---

## `products`

| Index                      | Columns       | Type   | Purpose                                                       |
| -------------------------- | ------------- | ------ | ------------------------------------------------------------- |
| `idx_products_category_id` | `category_id` | B-tree | Filter products by category (public store + admin)            |
| `idx_products_status`      | `status`      | B-tree | Filter `WHERE status = 'ACTIVE'` — all public listing queries |

The composite unique constraint `UK_product_category_slug (category_id, slug)` also acts as a covering index for slug-based lookups within a category.

---

## `product_images`

| Index                           | Columns      | Type   | Purpose                                        |
| ------------------------------- | ------------ | ------ | ---------------------------------------------- |
| `idx_product_images_product_id` | `product_id` | B-tree | Fetch all images for a product; cascade delete |

---

## `cart_items`

| Index                       | Columns      | Type   | Purpose                                                                 |
| --------------------------- | ------------ | ------ | ----------------------------------------------------------------------- |
| `idx_cart_items_user_email` | `user_email` | B-tree | Load cart for authenticated user on every cart page visit               |
| `idx_cart_items_product_id` | `product_id` | B-tree | Find carts containing a specific product (e.g., after product deletion) |

The unique constraint `UK_cart_user_product (user_email, product_id)` prevents duplicate cart entries and doubles as an index for upsert operations.

---

## `customer_orders`

| Index                            | Columns      | Type   | Purpose                                                           |
| -------------------------------- | ------------ | ------ | ----------------------------------------------------------------- |
| `idx_customer_orders_user_email` | `user_email` | B-tree | `GET /api/orders/my` — load all orders for the authenticated user |
| `idx_customer_orders_status`     | `status`     | B-tree | Admin dashboard: filter by `PAID`, `SHIPPED`, etc.                |
| `idx_customer_orders_created_at` | `created_at` | B-tree | Time-range queries; ETL incremental loads (future)                |

---

## `customer_order_items`

| Index                                 | Columns      | Type   | Purpose                                                              |
| ------------------------------------- | ------------ | ------ | -------------------------------------------------------------------- |
| `idx_customer_order_items_order_id`   | `order_id`   | B-tree | Load all items for an order (always queried together with the order) |
| `idx_customer_order_items_product_id` | `product_id` | B-tree | Find all orders containing a product (reporting, admin)              |

---

## `payments`

| Index                   | Columns    | Type   | Purpose                                   |
| ----------------------- | ---------- | ------ | ----------------------------------------- |
| `idx_payments_order_id` | `order_id` | B-tree | Load payment record for a given order     |
| `idx_payments_status`   | `status`   | B-tree | Failed payment report; monitoring queries |

`payment_reference` has a `UNIQUE` constraint — idempotency check on payment gateway callbacks.

---

## `audit_logs`

| Index                          | Columns         | Type   | Purpose                                                 |
| ------------------------------ | --------------- | ------ | ------------------------------------------------------- |
| `idx_audit_logs_actor_user_id` | `actor_user_id` | B-tree | Audit history for a specific user                       |
| `idx_audit_logs_action`        | `action`        | B-tree | Filter by action type (e.g., all `LOGIN_FAILED` events) |
| `idx_audit_logs_created_at`    | `created_at`    | B-tree | Time-range queries; ETL; UI pagination sorted by time   |

---

## `login_attempts`

| Index                           | Columns      | Type   | Purpose                                                         |
| ------------------------------- | ------------ | ------ | --------------------------------------------------------------- |
| `idx_login_attempts_email`      | `email`      | B-tree | Brute-force analysis: count failures per email in a time window |
| `idx_login_attempts_created_at` | `created_at` | B-tree | Time-range queries; retention cleanup                           |
| `idx_login_attempts_success`    | `success`    | B-tree | Filter failed attempts for security dashboards                  |

---

## Missing Indexes (Known Gaps)

| Table             | Column                     | Why Not Added                           | Recommendation                                                     |
| ----------------- | -------------------------- | --------------------------------------- | ------------------------------------------------------------------ |
| `app_user`        | `LOWER(email)`             | Low traffic for demo                    | Add functional index if case-insensitive search becomes a hot path |
| `customer_orders` | `(user_email, created_at)` | Single-column indexes sufficient now    | Add composite index if pagination on user orders becomes slow      |
| `audit_logs`      | `(actor_user_id, action)`  | Current queries filter on one dimension | Add if security dashboard queries compound filters                 |
| `login_attempts`  | `(email, created_at)`      | Low volume                              | Add for lockout queries scanning recent attempts per user          |

---

## Index Maintenance Notes

- All indexes are B-tree (PostgreSQL default) — appropriate for equality and range queries on the columns used.
- No partial indexes currently — consider `WHERE status = 'ACTIVE'` partial index on `products` if the product catalogue grows large.
- `BIGSERIAL` primary keys use implicit B-tree indexes — not listed above.
- Foreign key columns that are also used as filter/join predicates have explicit indexes; pure FK columns without query use do not (avoids write overhead).
