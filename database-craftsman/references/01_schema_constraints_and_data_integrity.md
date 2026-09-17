# Schema Constraints & Data Integrity

> **Operational Rule**: The database schema is the authoritative contract. Constraints enforce domain invariants at the storage layer where they cannot be bypassed by application bugs or race conditions.

---

## 1. Declarative Invariant Enforcement in PostgreSQL

Never rely exclusively on application `if (x < y)` pre-checks. Always declare database constraints:

```sql
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_number VARCHAR(32) NOT NULL,
    currency CHAR(3) NOT NULL,
    balance_cents BIGINT NOT NULL DEFAULT 0,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    version BIGINT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Invariants enforced declaratively
    CONSTRAINT chk_account_balance_positive CHECK (balance_cents >= 0),
    CONSTRAINT chk_account_status_valid CHECK (status IN ('ACTIVE', 'SUSPENDED', 'CLOSED')),
    CONSTRAINT chk_account_currency_iso CHECK (length(currency) = 3),
    CONSTRAINT uq_account_number UNIQUE (account_number)
);
```

---

## 2. Foreign Keys & Referential Integrity

Always specify explicit cascading behaviors on foreign key constraints:
- `ON DELETE RESTRICT` / `NO ACTION` (Default): Prevents accidental deletion of parent records while child records exist.
- `ON DELETE CASCADE`: Deletes child rows automatically only when child rows represent strictly owned sub-entities (e.g. order line items).
- Avoid dangling reference columns without foreign key constraints.
