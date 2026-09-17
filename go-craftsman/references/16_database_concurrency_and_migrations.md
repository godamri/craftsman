# Database Concurrency & Migrations

Database operations must be engineered for concurrency anomalies and safe zero-downtime schema evolution.

---

## 1. Concurrency Anomalies & Fixes

### The Lost Update Anomaly
```text
Client A: Read Balance ($100) ──────────────> Write ($100 - $40 = $60)
Client B:      Read Balance ($100) ──> Write ($100 - $30 = $70) [OVERWRITES A!]
```

### Solutions:
1. **Atomic In-Database Mutation**:
   ```sql
   UPDATE accounts SET balance = balance - 40 WHERE id = 'acc_1' AND balance >= 40;
   ```
2. **Optimistic Version Check**:
   ```sql
   UPDATE accounts SET balance = $newBalance, version = version + 1
   WHERE id = 'acc_1' AND version = $currentVersion;
   ```
3. **Pessimistic Row Locking**:
   ```sql
   SELECT balance FROM accounts WHERE id = 'acc_1' FOR UPDATE;
   ```

---

## 2. Zero-Downtime Schema Migrations (Expand/Contract)

Never rename or drop an active column in a single migration step while running binaries still reference it.

```text
Phase 1 (Expand):   Add new column as NULLABLE (e.g. email_address).
Phase 2 (Deploy):   Deploy application code writing to BOTH old and new columns, reading from new.
Phase 3 (Backfill): Run background worker migrating historical data in bounded batches (1000 rows/batch).
Phase 4 (Contract): Remove old column after verifying all instances only use the new column.
```
