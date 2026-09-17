# Zero-Downtime Schema Migrations (Expand/Contract)

> **Operational Rule**: Never perform schema migrations that lock high-traffic tables indefinitely or cause incompatible intermediate states during rolling application deployments.

---

## 1. The 3-Phase Migration Lifecycle

```text
Phase 1: EXPAND (Additive, Backward-Compatible DDL)
  - Add new column as NULL or constant default.
  - Create new index concurrently.
  - Deploy code compatible with both old and new schema.

Phase 2: MIGRATE (Dual-Write / Backfill)
  - Application writes to both old and new columns, reads from new.
  - Run background script to backfill legacy rows in batches (1000 rows/batch).

Phase 3: CONTRACT (Deprecation & Cleanup)
  - Verify all running binary versions read only from the new structure.
  - Drop old columns, old indexes, and legacy constraints.
```

---

## 2. Setting Strict Lock Timeouts

Always wrap DDL operations with explicit lock timeouts to avoid blocking other concurrent transactions in the connection queue:

```sql
SET lock_timeout = '2s';
SET statement_timeout = '30s';

ALTER TABLE orders ADD COLUMN tracking_code VARCHAR(64);
```
