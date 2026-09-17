# Connection Pooling & Timeout Management

---

## 1. PostgreSQL Timeout Hierarchy

Configure explicit timeouts at the server, user, or session level to prevent rogue queries from tying up database resources:

```sql
-- 1. Fail fast if unable to acquire lock (prevents blocking queue buildup)
SET lock_timeout = '2s';

-- 2. Terminate long-running slow queries
SET statement_timeout = '15s';

-- 3. Kill sessions holding open transactions idle
SET idle_in_transaction_session_timeout = '10s';
```

---

## 2. Connection Pool Sizing & PgBouncer

1. **Do not create unbounded connections**: PostgreSQL forks a separate backend OS process per connection. Hundreds of active connections cause CPU cache trashing.
2. **Transaction Pooling with PgBouncer**: Pool thousands of client connections into tens of server database connections.
   - *Constraint in Transaction Pooling*: Do not use session-level state (e.g. `SET`, temporary tables, `LISTEN/NOTIFY`, `PREPARE` without named statements).
