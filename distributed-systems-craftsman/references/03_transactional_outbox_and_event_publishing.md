# Transactional Outbox & Event Publishing

> **Core Principle**: Never perform network calls or broker publishing inside an uncommitted database transaction. Persist events in an outbox table within the same atomic database transaction.

---

## 1. Outbox Schema & Atomic Mutation

```sql
BEGIN TRANSACTION;
  -- 1. Mutate business state
  INSERT INTO orders (id, customer_id, total_cents, status)
  VALUES ('ord_123', 'cust_456', 5000, 'CREATED');

  -- 2. Persist outbox event atomically
  INSERT INTO outbox_events (id, aggregate_type, aggregate_id, event_type, payload, status)
  VALUES ('evt_789', 'Order', 'ord_123', 'OrderCreated', '{"total": 5000}', 'PENDING');
COMMIT;
```

---

## 2. Dispatcher Loop with `SKIP LOCKED`

```sql
SELECT id, event_type, payload
FROM outbox_events
WHERE status = 'PENDING'
ORDER BY created_at ASC
LIMIT 100
FOR UPDATE SKIP LOCKED;
```

### The Crash Window
If the dispatcher crashes after publishing to Kafka but before executing `UPDATE outbox_events SET status = 'PROCESSED'`, the event will be re-dispatched upon restart. Downstream consumers **must** implement inbox deduplication.
