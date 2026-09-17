# Idempotency & The Inbox Deduplication Pattern

---

## 1. Idempotency Key & Payload Fingerprinting

An idempotency key must be cryptographically bound to the request payload to detect both duplicate replays and conflicting modifications:

| Condition | State in Inbox | Correct Response |
| :--- | :--- | :--- |
| **Same Key + Same Fingerprint** | Completed | Idempotent Replay: return saved response payload directly. |
| **Same Key + Different Fingerprint** | Completed | Conflict: reject with `409 Conflict` (`ErrIdempotencyConflict`). |
| **Same Key + Currently In-Flight** | Processing | In-Progress: reject with `409 Conflict` or `425 Too Early` with `Retry-After`. |

---

## 2. PostgreSQL Inbox Deduplication Table

```sql
CREATE TABLE processed_inbox (
    idempotency_key VARCHAR(128) PRIMARY KEY,
    payload_hash CHAR(64) NOT NULL, -- SHA-256 hex string
    response_body JSONB NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'COMPLETED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Atomic insert or conflict detection
INSERT INTO processed_inbox (idempotency_key, payload_hash, response_body)
VALUES ($1, $2, $3)
ON CONFLICT (idempotency_key) DO NOTHING;
```
If `rows_affected == 0`, fetch existing record and verify `payload_hash`.
