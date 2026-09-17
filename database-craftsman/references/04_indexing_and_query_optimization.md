# Indexing & Query Optimization

---

## 1. Indexing Strategy in PostgreSQL

1. **Composite Indexes & Column Ordering**: Place equality filters (`=`) first, followed by range filters (`>`, `<`, `BETWEEN`) or sort columns (`ORDER BY`).
2. **Partial Indexes**: Index only active or non-terminal rows to keep index size small and fast:
   ```sql
   CREATE INDEX idx_orders_unprocessed
   ON orders (created_at)
   WHERE status = 'PENDING';
   ```
3. **Covering Indexes (`INCLUDE`)**: Include non-key payload columns to enable index-only scans without heap fetches:
   ```sql
   CREATE INDEX idx_users_email_covering
   ON users (email)
   INCLUDE (id, is_active);
   ```

---

## 2. Keyset / Cursor Pagination ($O(1)$)

Avoid `OFFSET` pagination for large datasets. Use Keyset pagination:

```sql
-- Fast and deterministic regardless of page depth
SELECT id, title, created_at
FROM articles
WHERE (created_at, id) < ($last_seen_created_at, $last_seen_id)
ORDER BY created_at DESC, id DESC
LIMIT 50;
```
