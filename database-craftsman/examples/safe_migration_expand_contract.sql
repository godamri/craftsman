-- ==============================================================================
-- SAFE ZERO-DOWNTIME SCHEMA MIGRATION: EXPAND -> MIGRATE -> CONTRACT
-- Target: Renaming/Transforming column 'phone' to 'e164_phone_number'
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PHASE 1: EXPAND (Additive, non-blocking, deployed with App Version N)
-- ------------------------------------------------------------------------------

SET lock_timeout = '2s';
SET statement_timeout = '30s';

-- 1. Add new column as NULLABLE (Zero table rewrite in PostgreSQL 11+)
ALTER TABLE users ADD COLUMN IF NOT EXISTS e164_phone_number VARCHAR(32);

-- 2. Create index concurrently (Must be outside multi-statement transaction in Postgres)
-- Note: In tools like Flyway/Liquibase/golang-migrate, execute concurrent index in its own migration step.
-- CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_e164_phone ON users (e164_phone_number);

-- ------------------------------------------------------------------------------
-- PHASE 2: MIGRATE (Application writes to both, backfill historical data)
-- App Version N+1 is deployed: Writes to BOTH 'phone' and 'e164_phone_number', reads from 'e164_phone_number'
-- ------------------------------------------------------------------------------

-- Run in background worker in bounded batches to avoid transaction log bloat
UPDATE users
SET e164_phone_number = phone
WHERE e164_phone_number IS NULL AND phone IS NOT NULL
  AND id IN (
      SELECT id FROM users
      WHERE e164_phone_number IS NULL AND phone IS NOT NULL
      LIMIT 1000
  );

-- ------------------------------------------------------------------------------
-- PHASE 3: CONTRACT (Cleanup old column after verifying 100% data migration)
-- Deployed only after ALL instances run Version N+1 and backfill is complete
-- ------------------------------------------------------------------------------

SET lock_timeout = '2s';

-- 1. Add NOT NULL constraint safely using NOT VALID then VALIDATE
ALTER TABLE users ADD CONSTRAINT chk_e164_phone_not_null CHECK (e164_phone_number IS NOT NULL) NOT VALID;
ALTER TABLE users VALIDATE CONSTRAINT chk_e164_phone_not_null;

-- 2. Drop old column
ALTER TABLE users DROP COLUMN IF EXISTS phone;
