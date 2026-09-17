# Distributed Systems & Failure Semantics

> **Operational Rule**: Exactly-once delivery cannot be assumed from message transport. Reason about **effectively-once business outcomes**.

---

## 1. Transactional Outbox != Exactly-Once Delivery

A Transactional Outbox guarantees that event records are persisted if and only if the business database transaction commits. However, message dispatch remains **at-least-once**:

```text
DB Transaction:
  1. INSERT INTO orders (...)
  2. INSERT INTO outbox_events (id, payload, status='PENDING')
COMMIT;

Dispatcher Loop:
  1. SELECT * FROM outbox_events WHERE status='PENDING' FOR UPDATE SKIP LOCKED LIMIT 100;
  2. Publish event to Kafka / RabbitMQ / NATS
  3. [CRASH WINDOW: If process dies HERE, the event was published, but status is not marked PROCESSED]
  4. UPDATE outbox_events SET status='PROCESSED' WHERE id = event.id;
```

Because of the crash window between publishing and updating outbox status, consumers **MUST** be idempotent.

---

## 2. Idempotency Semantics & Request Fingerprinting

An idempotency key is not merely a random UUID; it binds a specific client intent to a unique execution outcome:

| Scenario | State | Correct Behavior |
| :--- | :--- | :--- |
| **Same Key + Same Request Fingerprint** | Completed | Idempotent replay: return identical saved business response without re-executing mutation. |
| **Same Key + Different Request Fingerprint** | Completed | Deterministic conflict: reject immediately with `409 Conflict` (`ErrIdempotencyConflict`). |
| **Same Key + Request In-Progress** | Processing | In-flight conflict: reject with `409 Conflict` or `425 Too Early` with `Retry-After`. |
| **Crash after DB commit** | Recoverable | Replay from durable inbox/outbox state. Zero duplicate business deductions. |

```sql
-- Atomic Inbox deduplication in PostgreSQL
INSERT INTO processed_inbox (idempotency_key, payload_hash, response_payload, created_at)
VALUES ($1, $2, $3, NOW())
ON CONFLICT (idempotency_key) DO UPDATE
SET last_seen_at = NOW()
RETURNING (processed_inbox.payload_hash = EXCLUDED.payload_hash) AS is_matching_payload;
```
