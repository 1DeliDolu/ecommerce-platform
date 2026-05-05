# Data Flow

Key request-response flows through the system.

---

## 1. User Registration

```
Client
  │  POST /api/auth/register
  │  { fullName, email, password }
  │
  ▼
RateLimitingFilter
  │  Check: ≤ 20 req/min from this IP (Bucket4j)
  │  429 Too Many Requests if exceeded
  ▼
Spring Security Filter Chain
  │  Public endpoint — no JWT required
  ▼
AuthController.register()
  │  1. Validate input (@Valid):
  │     - email format, fullName ≤ 200 chars
  │     - password: min 8 chars, uppercase + lowercase + digit + special char
  │  2. Check email uniqueness (AppUserRepository.existsByEmailIgnoreCase)
  │     → 409 Conflict if duplicate
  │  3. BCrypt.encode(password) → password_hash
  │  4. Save AppUser (role=CUSTOMER, permissions=PRODUCT_READ,ORDER_READ_OWN)
  │  5. AuditService.record(USER_REGISTERED, ...)
  │  6. JwtService.createToken() → RS256 signed access token (30 min)
  │  7. RefreshTokenService.rotateForUser() → 48-byte token, SHA-256 stored (7 days)
  │  8. KafkaEventPublisher → user.registered topic
  │
  ▼
Response 201 Created
  { accessToken, refreshToken, user: { email, fullName, role, permissions } }
```

---

## 2. User Login

```
Client
  │  POST /api/auth/login
  │  { email, password }
  │
  ▼
RateLimitingFilter  (same as above)
  ▼
AuthController.login()
  │  1. AppUserRepository.findByEmailIgnoreCase(email)
  │     → 401 Unauthorized if not found (generic message)
  │  2. AccountLockoutService.isLocked(user)?
  │     → 423 Locked if active lockout
  │     → Lazy-clear lock if expired
  │  3. BCrypt.matches(password, user.passwordHash)?
  │     If NO:
  │       - Increment user.failedLoginAttempts
  │       - If attempts ≥ 5 → set user.lockedUntil = now + 15 min
  │       - LoginAttemptAuditService.record(email, false, INVALID_CREDENTIALS)
  │       - Kafka: audit.security-event
  │       → 401 Unauthorized
  │     If YES:
  │       - Reset failedLoginAttempts = 0, lockedUntil = null
  │       - LoginAttemptAuditService.record(email, true, null)
  │       - Kafka: audit.security-event
  │       - Generate access token + rotate refresh token
  │
  ▼
Response 200 OK
  { accessToken, refreshToken, user: { ... } }
```

---

## 3. Authenticated Request

```
Client
  │  GET /api/orders/my
  │  Authorization: Bearer <accessToken>
  │
  ▼
JwtAuthenticationFilter
  │  1. Extract Bearer token from Authorization header
  │  2. JwtService.parseToken(token) — verify RS256 signature + expiry
  │     → On failure: clear SecurityContext, continue chain (request will hit 401 later)
  │  3. Build UsernamePasswordAuthenticationToken:
  │     - principal = email (from sub claim)
  │     - authorities = [ROLE_CUSTOMER, PRODUCT_READ, ORDER_READ_OWN]
  │  4. Set in SecurityContextHolder
  │  5. MDC.put("userId", email) for structured logging
  ▼
SecurityConfig.authorizeHttpRequests
  │  /api/orders/my requires authenticated → OK
  │  (Admin-only paths require ROLE_ADMIN — 403 if missing)
  ▼
CheckoutController.getMyOrders()
  │  Authentication.getName() → email
  │  CustomerOrderRepository.findByUserEmail(email)
  ▼
Response 200 OK
  [ { orderId, orderNumber, status, items, total, ... } ]
```

---

## 4. Order Checkout

```
Client
  │  POST /api/orders/checkout
  │  Authorization: Bearer <accessToken>
  │  { shippingAddress, paymentMethod, paymentReference }
  │
  ▼
[Auth filter — same as above]
  ▼
CheckoutController.checkout()
  │  1. Load cart items for email
  │  2. Validate: cart not empty, stock available
  │  3. Calculate: subtotal + shipping + tax = total
  │  4. Create CustomerOrder (status=CREATED)
  │  5. Create CustomerOrderItems (snapshot product name + price)
  │  6. Deduct stock quantities
  │  7. Clear cart (delete CartItems for user)
  │  8. Update order status → PAID / PAYMENT_FAILED
  │  9. AuditService.record(ORDER_CREATED / PAYMENT_FAILED)
  │  10. Kafka:
  │      - order.created
  │      - payment.completed OR payment.failed
  │      - inventory.updated
  │  11. Spring Event → MailNotificationEvent
  │      → RabbitMQ mail.send → MailTaskConsumer → MailHog
  │
  ▼
Response 200 OK
  { orderId, orderNumber, status, total, items: [...] }
```

---

## 5. Token Refresh

```
Client
  │  POST /api/auth/refresh
  │  { refreshToken: "<opaque 48-byte token>" }
  │
  ▼
AuthController.refresh()
  │  1. SHA-256 hash the incoming token
  │  2. Query: SELECT user_id FROM refresh_tokens
  │            WHERE token_hash = ? AND revoked_at IS NULL AND expires_at > NOW()
  │     → 401 if not found / expired
  │  3. Revoke old token (UPDATE revoked_at = NOW())
  │  4. Load AppUser, check enabled = true
  │  5. Generate new access token + new refresh token
  │  6. AuditService.record(TOKEN_REFRESHED)
  │
  ▼
Response 200 OK
  { accessToken, refreshToken, user: { ... } }
```

---

## 6. Airflow ETL (nightly)

```
[Airflow Scheduler — @daily at midnight]
  │
  ▼
Task 1: create_warehouse_schema
  │  CREATE SCHEMA IF NOT EXISTS staging, dw, reports
  │  CREATE TABLE IF NOT EXISTS: dim_customer, dim_product, dim_date,
  │                               fact_orders, fact_payments, fact_inventory
  │                               staging.orders, staging.order_items, etc.
  ▼
Task 2: refresh_warehouse
  │  TRUNCATE staging.*
  │  INSERT INTO staging.orders    SELECT * FROM public.customer_orders
  │  INSERT INTO staging.products  SELECT * FROM public.products
  │  INSERT INTO staging.order_items ...
  │  UPSERT dim_customer (from staging.orders.user_email)
  │  UPSERT dim_product  (from staging.products)
  │  UPSERT dim_date     (from staging.orders.created_at)
  │  UPSERT fact_orders  (JOIN staging.orders + dim_customer)
  │  UPSERT fact_payments
  │  UPSERT fact_inventory
  ▼
Task 3: build_<report_name>
  │  CREATE OR REPLACE VIEW reports.<report_name> AS
  │  SELECT ... FROM dw.fact_orders JOIN dw.dim_*
  ▼
Done — views are queryable until next run
```
