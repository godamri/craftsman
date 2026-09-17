-- ==============================================================================
-- DATABASE CONCURRENCY CONTROL PATTERNS (PostgreSQL)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PATTERN 1: ATOMIC IN-DATABASE CAS UPDATE (No locking required)
-- Best for high-concurrency balance or inventory mutations.
-- ------------------------------------------------------------------------------
UPDATE accounts
SET balance_cents = balance_cents - 2500,
    version = version + 1,
    updated_at = NOW()
WHERE id = 'acc_123'
  AND balance_cents >= 2500;
-- Check rows affected: If 0, balance was insufficient or account not found!


-- ------------------------------------------------------------------------------
-- PATTERN 2: OPTIMISTIC VERSION FENCING (Conflict detection)
-- Best for complex document or entity updates where state is modified in memory.
-- ------------------------------------------------------------------------------
UPDATE documents
SET title = 'Updated Title',
    content = '{"body": "new content"}',
    version = version + 1,
    updated_at = NOW()
WHERE id = 'doc_456'
  AND version = 3; -- Must match version read earlier!
-- Check rows affected: If 0, someone else updated the document concurrently. Abort or reload.


-- ------------------------------------------------------------------------------
-- PATTERN 3: PESSIMISTIC ROW LOCKING (Strict transaction boundary)
-- Best when multi-table business validation is required before update.
-- ------------------------------------------------------------------------------
BEGIN;
  SET LOCAL lock_timeout = '2s';

  -- Select and lock the row
  SELECT id, balance_cents, status
  FROM accounts
  WHERE id = 'acc_789'
  FOR UPDATE;

  -- Perform business checks in application code...

  UPDATE accounts
  SET balance_cents = balance_cents - 1000,
      updated_at = NOW()
  WHERE id = 'acc_789';

COMMIT;
