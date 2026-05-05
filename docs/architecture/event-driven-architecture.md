# Event-Driven Architecture

## Overview

The platform uses two messaging systems for different purposes:

| System           | Role             | Pattern                       |
| ---------------- | ---------------- | ----------------------------- |
| **Apache Kafka** | Domain event bus | Publish / Subscribe (fan-out) |
| **RabbitMQ**     | Async task queue | Work queue with DLQ           |

---

## Kafka

### Cluster Setup

- Image: `bitnami/kafka:4.0`
- Mode: **KRaft** (no Zookeeper dependency)
- Node: single broker, `node-id=1`
- Listeners:
  - `PLAINTEXT://kafka:9092` — internal (backend, exporters)
  - `EXTERNAL://localhost:9094` — host machine access
- Topic auto-creation: **disabled** (topics created explicitly by `kafka-init`)

### Topics

| Topic                  | Partitions | Published by                     | Event Payload                              |
| ---------------------- | ---------- | -------------------------------- | ------------------------------------------ |
| `user.registered`      | 3          | `AuthController` on `/register`  | `userId`, `email`, `role`                  |
| `order.created`        | 3          | `CheckoutController` on checkout | order details                              |
| `payment.completed`    | 3          | `CheckoutController` on success  | payment reference, amount                  |
| `payment.failed`       | 3          | `CheckoutController` on failure  | order id, reason                           |
| `inventory.updated`    | 3          | `CheckoutController` post-order  | product ids, new quantities                |
| `audit.security-event` | 3          | `LoginAttemptAuditService`       | actor email (masked), action, success flag |

### Event Envelope

Every Kafka message is wrapped in an `EventEnvelope`:

```json
{
  "eventId": "uuid-v4",
  "eventType": "user.registered",
  "occurredAt": "2026-05-05T10:00:00Z",
  "source": "auth-service",
  "correlationId": "uuid-v4",
  "payload": { ... }
}
```

### Producer

`KafkaEventPublisher` — a thin wrapper that serializes the envelope with Jackson and publishes to the given topic.

### Consumer

`KafkaEventConsumer` — a single `@KafkaListener` subscribed to all 6 topics in consumer group `ecommerce-backend`. Currently logs received events; designed for extension (downstream processing, webhooks, analytics).

### Kafka UI

`provectuslabs/kafka-ui` at port **8085** — browse topics, inspect messages, monitor consumer lag.

---

## RabbitMQ

### Topology

```
Producer (MailTaskProducer)
      │
      │  routing key: mail.send
      ▼
 Exchange: ecommerce.tasks  (Direct, durable)
      │
      │  binding: mail.send
      ▼
 Queue: mail.send  (durable, x-dead-letter-exchange → ecommerce.tasks.dlx)
      │
      ▼
 Consumer (MailTaskConsumer)
      │  on failure after 3 retries
      ▼
 DLX: ecommerce.tasks.dlx  (Direct, durable)
      │
      ▼
 DLQ: mail.send.dlq  (durable — manual inspection)
```

### Retry Policy

Configured via Spring AMQP `RetryInterceptorBuilder`:

| Attempt          | Delay          |
| ---------------- | -------------- |
| 1st retry        | 1 s            |
| 2nd retry        | 2 s            |
| 3rd retry        | 4 s (max 10 s) |
| After 3 failures | Message → DLQ  |

### Mail Task Flow

1. Order confirmed → `CheckoutController` publishes `MailNotificationEvent` via Spring `ApplicationEventPublisher`.
2. `MailEventListener` receives it and calls `MailTaskProducer.enqueue(MailTask)`.
3. `MailTaskProducer` serializes to JSON and publishes to `ecommerce.tasks` exchange with `mail.send` routing key.
4. `MailTaskConsumer` consumes from `mail.send` queue and sends via JavaMail to **MailHog** (dev SMTP, port 1025).
5. Email visible at **http://localhost:8025**.

### Management UI

RabbitMQ Management Plugin at port **15672** — user: `ecommerce`, password: `ecommerce` (dev default).

---

## Event Flow Diagram

```
[Client]
   │  POST /api/auth/register
   ▼
[AuthController]
   │──── Kafka: user.registered ──────────────────▶ [KafkaEventConsumer (log)]
   │
   │  POST /api/orders/checkout
   ▼
[CheckoutController]
   │──── Kafka: order.created ───────────────────▶ [KafkaEventConsumer (log)]
   │──── Kafka: payment.completed / failed ──────▶ [KafkaEventConsumer (log)]
   │──── Kafka: inventory.updated ───────────────▶ [KafkaEventConsumer (log)]
   │──── Spring Event: MailNotificationEvent
   │         │
   │         ▼
   │    [MailEventListener]
   │         │──── RabbitMQ: mail.send ──────────▶ [MailTaskConsumer]
   │                                                      │
   │                                                      ▼
   │                                               [MailHog SMTP]
   │
[LoginAttemptAuditService]
   │──── Kafka: audit.security-event ────────────▶ [KafkaEventConsumer (log)]
```
