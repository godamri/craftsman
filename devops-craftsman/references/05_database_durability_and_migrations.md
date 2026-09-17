# Database Durability & Safe Migrations

> **Rule**: Database mutations must protect data durability, avoid unconstrained table locks on live workloads, and provide verifiable rollback paths.

---

## 1. Safe Manual DML Invariants (PostgreSQL / MySQL)

> [!NOTE]
> PostgreSQL does not support `UPDATE ... LIMIT` or `DELETE ... LIMIT` syntax natively. Do not rely on non-existent syntax.

### The Safe DML Execution Protocol:
1. **Preview Affected Rows First**:
   ```sql
   SELECT count(*), min(id), max(id) FROM orders
   WHERE status = 'PENDING' AND created_at < NOW() - INTERVAL '30 days';
   ```
2. **Execute Inside an Explicit Transaction**:
   ```sql
   BEGIN;
   -- Set safety timeout to avoid blocking concurrent transactions
   SET LOCAL lock_timeout = '2s';
   SET LOCAL statement_timeout = '10s';

   DELETE FROM orders
   WHERE status = 'PENDING' AND created_at < NOW() - INTERVAL '30 days';

   -- 3. Verify exact affected row count before committing
   -- (e.g. check client rowcount or query state)
   -- If rowcount matches expectation:
   COMMIT;
   -- Otherwise:
   -- ROLLBACK;
   ```

---

## 2. Online & Non-Blocking Schema Migrations

### Index Creation on Live Workloads
- Standard `CREATE INDEX` acquires an `ACCESS EXCLUSIVE` lock on PostgreSQL, blocking all concurrent reads and writes for the duration of index creation.
- Live production workloads should evaluate online/non-blocking index creation (`CREATE INDEX CONCURRENTLY` in PostgreSQL) when necessary to avoid table locks.
- *Tradeoffs*: `CREATE INDEX CONCURRENTLY` requires two table scans, cannot run inside a multi-statement transaction block, and if interrupted may leave an `INVALID` index that must be dropped and recreated.

### Column Additions & Expand/Contract
- Prefer migration patterns that avoid prolonged locks, full table rewrites, and incompatible intermediate states:
  - Add new columns as `NULL` or with constant defaults (supported without table rewrites in modern PostgreSQL 11+).
  - Use the 3-phase **Expand $\to$ Migrate $\to$ Contract** pattern for breaking column renames or type conversions.
- Always set an explicit `lock_timeout` before executing DDL:
  ```sql
  SET lock_timeout = '2s';
  ALTER TABLE orders ADD COLUMN tracking_number VARCHAR(100);
  ```
