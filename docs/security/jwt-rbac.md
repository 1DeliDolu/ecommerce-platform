# JWT & RBAC

## Authentication Flow

```
Client                       Backend
  │                             │
  │  POST /api/auth/login        │
  │  { email, password }        │
  │ ─────────────────────────▶  │
  │                             │  1. Rate limit check (Bucket4j, 20 req/min per IP)
  │                             │  2. Account lockout check (≥5 failures → 15 min lock)
  │                             │  3. BCrypt.matches(password, hash)
  │                             │  4. Generate access token  (RS256, 30 min)
  │                             │  5. Generate refresh token (48 bytes, SHA-256 stored, 7 days)
  │  ◀─────────────────────────  │
  │  { accessToken,             │
  │    refreshToken,            │
  │    user: {email,role,...} } │
  │                             │
  │  GET /api/orders/my         │
  │  Authorization: Bearer <AT> │
  │ ─────────────────────────▶  │
  │                             │  JwtAuthenticationFilter:
  │                             │  6. Parse + verify RS256 signature
  │                             │  7. Check expiry
  │                             │  8. Build SecurityContext (ROLE_CUSTOMER + permissions)
  │                             │  9. Route authorization check
  │  ◀─────────────────────────  │
  │  200 OK [ orders... ]       │
```

---

## JWT

### Algorithm: RS256

| Property              | Value                                                                                |
| --------------------- | ------------------------------------------------------------------------------------ |
| Algorithm             | RS256 (RSA 2048-bit)                                                                 |
| Key pair location     | `secrets/jwt_private_key.pem` (signing), `secrets/jwt_public_key.pem` (verification) |
| Access token lifetime | 30 minutes (configurable via `JWT_EXPIRATION_MINUTES`)                               |
| Library               | `io.jsonwebtoken:jjwt` 0.12.6                                                        |

### Token Claims

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

### Why RS256 over HS256

With a shared HMAC secret (HS256), every service that validates tokens must know the secret — a leaked secret compromises the whole system. With RS256, only the backend holds the private key. Future microservices can verify tokens using the public key alone.

---

## Refresh Token

| Property   | Value                                                              |
| ---------- | ------------------------------------------------------------------ |
| Generation | `SecureRandom` → 48 bytes → Base64 URL-encoded                     |
| Storage    | SHA-256 hash in `refresh_tokens` table (plaintext never persisted) |
| Lifetime   | 7 days                                                             |
| Rotation   | Every use: old token revoked, new token issued                     |
| Revocation | `revoked_at` timestamp set; expired or revoked tokens rejected     |

**Rotation guarantees:** A stolen refresh token can only be used once. If an attacker uses it after the legitimate client does, the legitimate client's next refresh will fail (token already revoked), signalling a potential compromise.

---

## RBAC

### Roles

| Role               | Description                                  |
| ------------------ | -------------------------------------------- |
| `ADMIN`            | Full access to all endpoints and admin panel |
| `EMPLOYEE`         | Product/category management, own orders      |
| `CUSTOMER`         | Browse products, own cart, own orders        |
| `SECURITY_AUDITOR` | Read-only access to audit logs               |

### Permissions

| Permission                  | Granted to                |
| --------------------------- | ------------------------- |
| `ADMIN_PANEL_ACCESS`        | ADMIN, EMPLOYEE           |
| `PRODUCT_READ`              | ADMIN, EMPLOYEE, CUSTOMER |
| `PRODUCT_CREATE`            | ADMIN, EMPLOYEE           |
| `PRODUCT_UPDATE`            | ADMIN, EMPLOYEE           |
| `PRODUCT_DELETE`            | ADMIN                     |
| `PRODUCT_IMAGE_UPLOAD`      | ADMIN, EMPLOYEE           |
| `PRODUCT_IMAGE_DELETE`      | ADMIN                     |
| `PRODUCT_IMAGE_SET_PRIMARY` | ADMIN, EMPLOYEE           |
| `CATEGORY_READ`             | ADMIN, EMPLOYEE           |
| `CATEGORY_CREATE`           | ADMIN, EMPLOYEE           |
| `CATEGORY_UPDATE`           | ADMIN, EMPLOYEE           |
| `CATEGORY_DELETE`           | ADMIN                     |
| `ORDER_READ_OWN`            | ADMIN, EMPLOYEE, CUSTOMER |
| `ORDER_READ_ALL`            | ADMIN                     |
| `USER_MANAGE`               | ADMIN                     |
| `ROLE_MANAGE`               | ADMIN                     |
| `AUDIT_READ`                | ADMIN, SECURITY_AUDITOR   |

### Endpoint Authorization Matrix

| Endpoint pattern            | Auth required | Role / Permission                       |
| --------------------------- | ------------- | --------------------------------------- |
| `POST /api/auth/login`      | No            | —                                       |
| `POST /api/auth/register`   | No            | —                                       |
| `POST /api/auth/refresh`    | No            | —                                       |
| `GET /api/auth/me`          | Yes           | Any authenticated                       |
| `GET /api/products/**`      | No            | —                                       |
| `GET/POST /api/cart/**`     | Yes           | Any authenticated                       |
| `GET /api/orders/my`        | Yes           | Any authenticated                       |
| `POST /api/orders/checkout` | Yes           | Any authenticated                       |
| `GET /api/admin/**`         | Yes           | `ROLE_ADMIN`                            |
| `GET /api/audit/**`         | Yes           | `ROLE_ADMIN` or `ROLE_SECURITY_AUDITOR` |

### Implementation

Roles are stored in the JWT `role` claim. On each request, `JwtAuthenticationFilter` extracts the token and builds a `UsernamePasswordAuthenticationToken` with:

- `ROLE_<role>` authority (e.g., `ROLE_ADMIN`)
- One `SimpleGrantedAuthority` per permission

`SecurityConfig` uses `hasRole()` and `hasAnyAuthority()` checks in the filter chain. Method-level `@PreAuthorize` annotations are also available via `@EnableMethodSecurity`.

---

## Security Headers

Configured in `SecurityConfig.java`, applied to every response:

| Header                      | Value                                                                                                                                                        |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains; preload`                                                                                                               |
| `Content-Security-Policy`   | `default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'` |
| `X-Frame-Options`           | `DENY`                                                                                                                                                       |
| `X-Content-Type-Options`    | `nosniff`                                                                                                                                                    |
| `Referrer-Policy`           | `strict-origin-when-cross-origin`                                                                                                                            |
| `Permissions-Policy`        | `geolocation=(), microphone=(), camera=(), payment=()`                                                                                                       |
