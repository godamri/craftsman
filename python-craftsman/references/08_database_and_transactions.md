# Database & Transaction Correctness

Application correctness is inextricably linked to database guarantees.

> **Principle**: If an invariant can be enforced by the database, enforce it in the database.

---

## 1. Database Constraints vs Application Pre-Checks

Never rely exclusively on application-level checks (e.g. `SELECT count(*) WHERE email = ...`) for uniqueness, ownership, or state transitions in concurrent systems.

```sql
-- Schema enforcement: guarantees correctness even under high concurrency
CREATE TABLE user_accounts (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    balance_cents BIGINT NOT NULL CHECK (balance_cents >= 0),
    version INT NOT NULL DEFAULT 1
);
```

---

## 2. Explicit Transaction Context & Concurrency Control

### Pessimistic Locking (`SELECT ... FOR UPDATE`)
Use only when high contention or strict state serialization is required within a short transaction.

```python
import sqlite3
from contextlib import contextmanager
from collections.abc import Iterator

@contextmanager
def transaction(conn: sqlite3.Connection) -> Iterator[sqlite3.Cursor]:
    cursor = conn.cursor()
    cursor.execute("BEGIN IMMEDIATE")
    try:
        yield cursor
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cursor.close()
```

---

## 3. Decoupling External Side Effects from Transactions

Never trigger external side effects (emails, webhooks, payments) while holding an uncommitted database transaction.

```python
def process_order(conn: sqlite3.Connection, order_id: str, email: str) -> None:
    # 1. Mutate database within atomic transaction
    with transaction(conn) as cursor:
        cursor.execute("UPDATE orders SET status = 'PAID' WHERE id = ?", (order_id,))

    # 2. Trigger external side effect ONLY after commit succeeds
    send_order_confirmation_email(email, order_id)
```
