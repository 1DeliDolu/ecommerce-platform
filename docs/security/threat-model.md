# Threat Model

STRIDE-based threat analysis for the ecommerce platform.

---

## Assets

| Asset                   | Sensitivity |
| ----------------------- | ----------- |
| User passwords          | Critical    |
| JWT private key         | Critical    |
| PostgreSQL credentials  | Critical    |
| Access tokens (JWT)     | High        |
| Refresh tokens          | High        |
| Order / payment data    | High        |
| Audit logs              | Medium      |
| Product / category data | Low         |

---

## STRIDE Analysis

### Spoofing (Identity)

| Threat                                        | Mitigation                                                                                                                       |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Attacker impersonates a user by forging a JWT | RS256 asymmetric signing — forgery requires the private key. `jjwt` verifies signature on every request.                         |
| Stolen access token used after user logs out  | Tokens expire in 30 minutes. No server-side session to invalidate — acceptable for demo; production would use a token blocklist. |
| Attacker replays a captured refresh token     | Refresh token rotation: each token is single-use. Using a consumed token returns 401, signalling potential theft.                |
| Credential stuffing / brute force login       | Account lockout after 5 failures (15 min). IP-based rate limiting (20 req/min) via Bucket4j.                                     |

### Tampering (Integrity)

| Threat                                               | Mitigation                                                                                                                                           |
| ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| JWT payload modified (e.g., elevate role to ADMIN)   | RS256 signature invalidated by any payload change. `SecurityInputTest.tamperedJwtPayloadIsRejected` verifies this.                                   |
| SQL injection in login / search fields               | Spring Data JPA uses parameterized queries exclusively — raw SQL concatenation is not used. `SecurityInputTest` tests common SQL injection payloads. |
| XSS via stored input (fullName, product description) | Content-Security-Policy (`script-src 'self'`) prevents inline script execution. Output encoding handled by React's DOM rendering.                    |
| Password stored in plaintext                         | BCrypt with default strength (10 rounds). `password_hash` column — plaintext never persisted.                                                        |
| PostgreSQL connection MITM                           | TLS 1.2+ enforced (`sslmode=verify-full`). Backend verifies server certificate against CA. Non-SSL TCP connections rejected in `pg_hba.conf`.        |

### Repudiation (Non-repudiation)

| Threat                           | Mitigation                                                                                                      |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| User denies performing an action | Every mutating operation writes to `audit_logs` (actor, action, resource, IP, user-agent, correlation ID).      |
| Login attempts not tracked       | Dedicated `login_attempts` table records every attempt (success/failure, IP, failure code).                     |
| Audit log tampering              | Audit records are append-only; no delete/update endpoint exposed. `SECURITY_AUDITOR` role has read access only. |
| Distributed tracing gaps         | `X-Correlation-Id` header propagated through all requests; stored in MDC for log correlation.                   |

### Information Disclosure

| Threat                                  | Mitigation                                                                                                                  |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Error messages leak internal details    | `GlobalExceptionHandler` returns generic messages (`"An unexpected error occurred"`). Stack traces logged server-side only. |
| Email addresses visible in logs         | `LoginAttemptAuditService` masks emails as `a***@example.com` before logging.                                               |
| Sensitive fields in JWT                 | JWT does not contain password, payment info, or PII beyond email + role.                                                    |
| Database credentials in version control | Passwords loaded from Docker secrets (`/run/secrets/`), never in `.env` or code. `.gitignore` covers `secrets/`.            |
| JWT private key exposure                | Key in `secrets/jwt_private_key.pem` (permissions 600), excluded from Git, mounted read-only in container.                  |
| Swagger UI in production                | Currently `permitAll()` — should be restricted or disabled in production environments.                                      |

### Denial of Service

| Threat                                                     | Mitigation                                                                                                                               |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Login endpoint flooded                                     | Rate limit: 20 req/min per IP on `/api/auth/*`. HTTP 429 + `Retry-After` header returned.                                                |
| Account lockout abuse (lock any account by flooding login) | Lockout is user-side, not IP-side — an attacker can lock a known account. Mitigation: CAPTCHA or progressive delay (future improvement). |
| Large file upload                                          | Multipart limit: 5 MB per file, 25 MB per request (`spring.servlet.multipart`).                                                          |
| Slow-loris / connection exhaustion                         | Handled at the container/load-balancer layer (not in-scope for this demo).                                                               |

### Elevation of Privilege

| Threat                                                       | Mitigation                                                                                                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| CUSTOMER accesses `/api/admin/**`                            | `hasRole("ADMIN")` in `SecurityConfig`; returns 403. `AuditService` records `PERMISSION_DENIED`.                                            |
| EMPLOYEE accesses user management                            | `USER_MANAGE` permission required; not granted to EMPLOYEE role.                                                                            |
| Horizontal privilege escalation (access other user's orders) | `GET /api/orders/my` filters by `Authentication.getName()` (email from JWT). Users cannot access other users' orders.                       |
| CSRF attack                                                  | CSRF disabled (stateless JWT — no cookies). Tokens are in the `Authorization` header, inaccessible to cross-site scripts due to CORS + CSP. |

---

## Known Gaps (Production Recommendations)

| Gap                                       | Recommendation                                                                    |
| ----------------------------------------- | --------------------------------------------------------------------------------- |
| No HTTPS enforcement at the backend       | Add a reverse proxy (nginx, Traefik) with TLS termination; redirect HTTP → HTTPS. |
| Rate limiting is in-process               | Use API Gateway or Redis-backed Bucket4j for multi-instance deployments.          |
| Swagger UI is public                      | Restrict to `ROLE_ADMIN` or disable via Spring profile in production.             |
| No token revocation on logout             | Add a Redis-backed token blocklist for immediate invalidation.                    |
| Account lockout can lock legitimate users | Add progressive delay / CAPTCHA instead of hard lockout.                          |
| No DAST / SAST in CI                      | Integrate OWASP ZAP (DAST) and SpotBugs / SonarQube (SAST) into the pipeline.     |
