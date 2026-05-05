# Audit Logging

The platform records two types of security-relevant events: general audit actions and login attempts. Both are stored in PostgreSQL and selected events are also published to Kafka.

---

## Audit Actions

Defined in `AuditAction.java` (enum):

| Action              | Trigger                                                 |
| ------------------- | ------------------------------------------------------- |
| `USER_REGISTERED`   | New user registers via `POST /api/auth/register`        |
| `LOGIN_SUCCESS`     | Successful login via `POST /api/auth/login`             |
| `LOGIN_FAILED`      | Failed login attempt (wrong password or account locked) |
| `TOKEN_REFRESHED`   | Access token refreshed via `POST /api/auth/refresh`     |
| `PRODUCT_CREATED`   | Admin creates a product                                 |
| `ORDER_CREATED`     | Customer places an order                                |
| `PAYMENT_FAILED`    | Payment processing fails at checkout                    |
| `ROLE_CHANGED`      | Admin changes a user's role                             |
| `PERMISSION_DENIED` | Request rejected by Spring Security (403)               |

---

## `audit_logs` Table

Written by `AuditService.record()`. Every call captures:

```
actor_user_id  — FK to app_user (SET NULL if user deleted)
actor_email    — denormalised copy for log retention
action         — AuditAction enum value
resource_type  — e.g. "user", "product", "order", "http"
resource_id    — entity ID or URI
ip_address     — from HttpServletRequest (X-Forwarded-For aware)
user_agent     — from HttpServletRequest
details        — freeform text (e.g. "email=a***@example.com; role=CUSTOMER")
created_at     — TIMESTAMPTZ DEFAULT NOW()
```

**Read access:** `GET /api/audit/logs` returns the last 100 records. Requires `ROLE_ADMIN` or `ROLE_SECURITY_AUDITOR`.

---

## `login_attempts` Table

Written by `LoginAttemptAuditService.record()` on every login attempt (success and failure):

```
email          — masked (e.g. "a***@example.com")
success        — true / false
ip_address
user_agent
failure_code   — INVALID_CREDENTIALS | ACCOUNT_LOCKED | null (on success)
created_at
```

This table is separate from `audit_logs` to allow high-volume brute-force analysis without polluting the general audit feed.

---

## Kafka Integration

`LoginAttemptAuditService` publishes every login attempt to the **`audit.security-event`** Kafka topic:

```json
{
  "eventId": "uuid",
  "eventType": "audit.security-event",
  "occurredAt": "2026-05-05T10:00:00Z",
  "source": "auth-service",
  "correlationId": "uuid",
  "payload": {
    "email": "a***@example.com",
    "success": false,
    "failureCode": "INVALID_CREDENTIALS",
    "ipAddress": "192.168.1.1"
  }
}
```

This enables downstream consumers (SIEM, alerting, analytics) to process security events in real time without polling the database.

---

## Correlation ID

`CorrelationIdFilter` runs on every request:

1. Reads `X-Correlation-Id` header from the request.
2. Generates a UUID if the header is absent.
3. Stores it in MDC (`correlationId`) for inclusion in all log lines.
4. Writes it back in the response `X-Correlation-Id` header.

This allows tracing a single request across all log lines, even across async operations.

---

## Email Masking

All logging of email addresses goes through the masking function in `AuthController` and `LoginAttemptAuditService`:

```
"admin@example.com"  →  "a***@example.com"
"ab@example.com"     →  "a***@example.com"
"a@example.com"      →  "***@example.com"
```

Rule: first character retained, then `***`, then `@domain`.

---

## Querying Audit Logs

```sql
-- Last 20 failed logins
SELECT email, ip_address, failure_code, created_at
FROM login_attempts
WHERE success = false
ORDER BY created_at DESC
LIMIT 20;

-- All PERMISSION_DENIED events in the last 24 hours
SELECT actor_email, resource_type, resource_id, ip_address, created_at
FROM audit_logs
WHERE action = 'PERMISSION_DENIED'
  AND created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;

-- Actions by a specific user
SELECT action, resource_type, resource_id, details, created_at
FROM audit_logs
WHERE actor_email = 'admin@example.com'
ORDER BY created_at DESC;
```
