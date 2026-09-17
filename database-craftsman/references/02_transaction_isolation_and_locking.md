# Transaction Isolation & Locking Strategies

---

## 1. Concurrency Anomalies vs Isolation Levels

| Isolation Level | Dirty Read | Non-Repeatable Read | Phantom Read | Serialization Anomaly / Write Skew |
| :--- | :--- | :--- | :--- | :--- |
| **Read Committed** (PostgreSQL default) | ❌ Prevented | ⚠️ Allowed | ⚠️ Allowed | ⚠️ Allowed (Lost updates possible) |
| **Repeatable Read** | ❌ Prevented | ❌ Prevented | ❌ Prevented | ⚠️ Allowed (Write skew possible) |
| **Serializable** | ❌ Prevented | ❌ Prevented | ❌ Prevented | ❌ Prevented |

---

## 2. Row Locking Primitives

1. **`FOR UPDATE`**: Locks selected rows against concurrent reads that also request locks, and all concurrent updates/deletes.
   ```sql
   SELECT balance_cents FROM accounts WHERE id = $1 FOR UPDATE;
   ```
2. **`FOR UPDATE SKIP LOCKED`**: Perfect for queue workers claiming work items concurrently without lock contention or deadlocks:
   ```sql
   SELECT id, payload FROM outbox_events
   WHERE status = 'PENDING'
   ORDER BY created_at ASC
   LIMIT 10
   FOR UPDATE SKIP LOCKED;
   ```
3. **`pg_advisory_xact_lock(key)`**: Acquires an application-level mutex in PostgreSQL tied to the transaction lifecycle:
   ```sql
   SELECT pg_advisory_xact_lock(hashtext('user_registration_' || $email));
   ```
