# API Endpoints

All REST endpoints exposed by the Spring Boot backend. Base URL: `http://localhost:8080`

RabbitMQ Management UI (dev): `http://localhost:15672`  
Credentials (dev default): `ecommerce / ecommerce`

---

## Authentication

Endpoints that require authentication expect a JWT access token in the `Authorization` header:

```
Authorization: Bearer <access_token>
```

Tokens are obtained from `POST /api/auth/login` or `POST /api/auth/register`.

---

## Rate Limiting

The following endpoints are rate-limited to **20 requests/minute per IP**:

- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/auth/refresh`

Exceeding the limit returns `HTTP 429` with a `Retry-After` header.

---

## Auth — `/api/auth`

### POST /api/auth/register

Register a new user account. Publishes a `user.registered` event to Kafka.

**Auth required:** No

**Request body:**

```json
{
  "email": "user@example.com",
  "password": "Str0ng!Pass",
  "fullName": "Jane Doe"
}
```

Password policy: minimum 8 characters, must include uppercase, lowercase, digit, and special character (`@$!%*#?&^_-`).

**Response `201 Created`:**

```json
{
  "accessToken": "eyJ...",
  "refreshToken": "Abc123...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "fullName": "Jane Doe",
    "role": "CUSTOMER",
    "permissions": ["PRODUCT_READ", "ORDER_READ_OWN"]
  }
}
```

**Error responses:**

| Status | Cause                                             |
| ------ | ------------------------------------------------- |
| `400`  | Validation failure (weak password, invalid email) |
| `409`  | Email already registered                          |
| `429`  | Rate limit exceeded                               |

---

### POST /api/auth/login

Authenticate with email and password.

**Auth required:** No

**Request body:**

```json
{
  "email": "user@example.com",
  "password": "Str0ng!Pass"
}
```

**Response `200 OK`:** Same structure as `/register`.

**Account lockout:** After 5 consecutive failures the account is locked for 15 minutes. Attempts against a locked account return `HTTP 423`.

**Error responses:**

| Status | Cause                                            |
| ------ | ------------------------------------------------ |
| `400`  | Missing/invalid fields                           |
| `401`  | Wrong password                                   |
| `423`  | Account locked (includes `retryAfter` timestamp) |
| `429`  | Rate limit exceeded                              |

---

### POST /api/auth/refresh

Exchange a refresh token for a new access token + refresh token pair (rotation).

**Auth required:** No

**Request body:**

```json
{
  "refreshToken": "Abc123..."
}
```

**Response `200 OK`:** Same structure as `/login`.

**Error responses:**

| Status | Cause                                     |
| ------ | ----------------------------------------- |
| `401`  | Token not found, expired, or already used |
| `429`  | Rate limit exceeded                       |

---

### GET /api/auth/me

Return the currently authenticated user's profile.

**Auth required:** Yes (any role)

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:**

```json
{
  "id": 1,
  "email": "user@example.com",
  "fullName": "Jane Doe",
  "role": "CUSTOMER",
  "permissions": ["PRODUCT_READ", "ORDER_READ_OWN"]
}
```

**Error responses:**

| Status | Cause                    |
| ------ | ------------------------ |
| `401`  | Missing or invalid token |

---

## Store Products — `/api/products`

Public product catalog. Only returns products with `status = ACTIVE`.

### GET /api/products

List all active products.

**Auth required:** No

**Response `200 OK`:**

```json
[
  {
    "id": 1,
    "name": "Laptop Pro",
    "slug": "laptop-pro",
    "price": 1299.99,
    "stockQuantity": 42,
    "status": "ACTIVE",
    "categoryId": 2,
    "images": [...]
  }
]
```

---

### GET /api/products/search

Paginated product search with filters.

**Auth required:** No

**Query parameters:**

| Parameter    | Type    | Default  | Description                          |
| ------------ | ------- | -------- | ------------------------------------ |
| `search`     | string  | —        | Full-text search on name/description |
| `categoryId` | long    | —        | Filter by category                   |
| `minPrice`   | decimal | —        | Minimum price                        |
| `maxPrice`   | decimal | —        | Maximum price                        |
| `status`     | string  | `ACTIVE` | Product status filter                |
| `page`       | int     | `0`      | Zero-based page number               |
| `size`       | int     | `20`     | Page size                            |
| `sort`       | string  | `id`     | Sort field                           |
| `direction`  | string  | `desc`   | `asc` or `desc`                      |

**Response `200 OK`:**

```json
{
  "content": [...],
  "totalElements": 150,
  "totalPages": 8,
  "page": 0,
  "size": 20
}
```

---

### GET /api/products/{id}

Get a single product by ID.

**Auth required:** No

**Response `200 OK`:** Single product object.

**Error responses:**

| Status | Cause             |
| ------ | ----------------- |
| `404`  | Product not found |

---

## Cart — `/api/cart`

All cart endpoints require authentication. The cart is scoped to the authenticated user's email.

### GET /api/cart

Retrieve the current user's cart.

**Auth required:** Yes

**Response `200 OK`:**

```json
{
  "items": [
    {
      "productId": 1,
      "productName": "Laptop Pro",
      "unitPrice": 1299.99,
      "quantity": 2,
      "lineTotal": 2599.98
    }
  ],
  "total": 2599.98
}
```

---

### POST /api/cart/items

Add a product to the cart (or increment quantity if already present).

**Auth required:** Yes

**Request body:**

```json
{
  "productId": 1,
  "quantity": 2
}
```

**Response `200 OK`:** Updated cart object.

---

### PATCH /api/cart/items/{productId}

Update the quantity of an item already in the cart.

**Auth required:** Yes

**Request body:**

```json
{
  "quantity": 5
}
```

**Response `200 OK`:** Updated cart object.

**Error responses:**

| Status | Cause            |
| ------ | ---------------- |
| `404`  | Item not in cart |

---

### DELETE /api/cart/items/{productId}

Remove an item from the cart.

**Auth required:** Yes

**Response `200 OK`:** Updated cart object (item removed).

---

## Orders — `/api/orders`

### POST /api/orders/checkout

Place an order from the current cart. Publishes `order.created` and `payment.completed`/`payment.failed` events to Kafka. Sends order confirmation email via RabbitMQ.

**Auth required:** Yes

**Request body:**

```json
{
  "shippingAddress": "123 Main St, Istanbul",
  "paymentMethod": "CREDIT_CARD",
  "paymentReference": "PAY-ABC-12345"
}
```

**Response `200 OK`:**

```json
{
  "id": 42,
  "orderNumber": "ORD-20260505-0042",
  "status": "PAID",
  "subtotal": 2599.98,
  "shippingCost": 9.99,
  "tax": 468.00,
  "totalAmount": 3077.97,
  "items": [...],
  "createdAt": "2026-05-05T14:30:00Z"
}
```

**Error responses:**

| Status | Cause                            |
| ------ | -------------------------------- |
| `400`  | Empty cart or validation failure |
| `402`  | Payment failed                   |
| `409`  | Insufficient stock               |

---

### GET /api/orders/my

List all orders for the authenticated user.

**Auth required:** Yes

**Response `200 OK`:** Array of order objects.

---

## Admin — Products `/api/admin/products`

Requires `ROLE_ADMIN` or `ROLE_EMPLOYEE` (enforced by Spring Security filter chain).

### GET /api/admin/products

List all products (all statuses).

**Response `200 OK`:** Array of product objects.

---

### GET /api/admin/products/search

Same parameters as `GET /api/products/search` but includes all statuses (ACTIVE, INACTIVE, DRAFT).

---

### GET /api/admin/products/{id}

Get any product by ID regardless of status.

---

### POST /api/admin/products

Create a product.

**Request body:**

```json
{
  "name": "Laptop Pro",
  "slug": "laptop-pro",
  "description": "High-performance laptop",
  "price": 1299.99,
  "stockQuantity": 50,
  "categoryId": 2,
  "status": "ACTIVE"
}
```

**Response `201 Created`:** Created product object.

---

### PUT /api/admin/products/{id}

Full update of a product. Same request body as POST.

**Response `200 OK`:** Updated product object.

---

### DELETE /api/admin/products/{id}

Delete a product.

**Response `204 No Content`**

---

### PATCH /api/admin/products/{id}/status

Toggle product status.

**Query parameter:** `status` — `ACTIVE`, `INACTIVE`, or `DRAFT`

**Response `200 OK`:** Updated product object.

---

### POST /api/admin/products/{id}/images

Upload product images (multipart).

**Request:** `multipart/form-data` with field `files` (array of image files).

**Limits:** 5 MB per file, 25 MB per request.

**Response `200 OK`:**

```json
[
  { "id": 1, "url": "/uploads/products/1/img_001.jpg", "isPrimary": true },
  { "id": 2, "url": "/uploads/products/1/img_002.jpg", "isPrimary": false }
]
```

---

### DELETE /api/admin/products/{productId}/images/{imageId}

Delete a product image.

**Response `204 No Content`**

---

### PATCH /api/admin/products/{productId}/images/{imageId}/primary

Set an image as the primary image for a product.

**Response `200 OK`:** Updated image object.

---

## Admin — Categories `/api/admin/categories`

Requires `ROLE_ADMIN` or `ROLE_EMPLOYEE`.

### GET /api/admin/categories

List all categories.

**Response `200 OK`:**

```json
[{ "id": 1, "name": "Electronics", "slug": "electronics" }]
```

---

### GET /api/admin/categories/{id}

Get a single category.

**Response `200 OK`:** Category object.

---

### POST /api/admin/categories

Create a category.

**Request body:**

```json
{
  "name": "Electronics",
  "slug": "electronics"
}
```

**Response `201 Created`:** Created category object.

---

### PUT /api/admin/categories/{id}

Update a category.

**Response `200 OK`:** Updated category object.

---

### DELETE /api/admin/categories/{id}

Delete a category.

**Response `204 No Content`**

---

## Admin — Orders `/api/admin/orders`

Requires `ROLE_ADMIN`.

### GET /api/admin/orders

List all orders across all customers.

**Response `200 OK`:** Array of order objects.

---

## Audit Logs — `/api/audit/logs`

Requires `ROLE_ADMIN` or `ROLE_SECURITY_AUDITOR`.

### GET /api/audit/logs

Return the 100 most recent audit log entries.

**Response `200 OK`:**

```json
[
  {
    "id": 99,
    "actorEmail": "a***@example.com",
    "action": "LOGIN_FAILED",
    "resourceType": "http",
    "resourceId": "/api/auth/login",
    "ipAddress": "192.168.1.1",
    "userAgent": "Mozilla/5.0 ...",
    "details": "email=u***@example.com; reason=INVALID_CREDENTIALS",
    "createdAt": "2026-05-05T14:25:00Z"
  }
]
```

---

## Health — `/api/health`

### GET /api/health

Custom application health check. No authentication required.

**Response `200 OK`:**

```json
{
  "status": "UP",
  "service": "ecommerce-backend",
  "time": "2026-05-05T14:30:00Z"
}
```

---

## Common Error Response Format

All errors return a consistent JSON envelope from `GlobalExceptionHandler`:

```json
{
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "timestamp": "2026-05-05T14:30:00Z",
  "path": "/api/auth/register"
}
```

Stack traces are never exposed in responses — they are logged server-side only.

---

## Swagger / OpenAPI

Interactive API documentation is available at:

```
http://localhost:8080/swagger-ui.html
http://localhost:8080/v3/api-docs
```

> Note: Swagger UI is currently `permitAll()`. For production deployments, restrict it to `ROLE_ADMIN` or disable it entirely via Spring profile.
