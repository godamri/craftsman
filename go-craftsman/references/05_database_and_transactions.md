# Database & Transaction Correctness

> **Principle**: If an invariant can be enforced by the database, enforce it in the database.

---

## 1. Explicit Transaction Context & Rollback Pattern

Always defer `tx.Rollback()`. If `tx.Commit()` succeeds, the deferred rollback returns `sql.ErrTxDone` safely without error.

```go
package repository

import (
    "context"
    "database/sql"
    "fmt"
)

func TransferFunds(ctx context.Context, db *sql.DB, fromAccount, toAccount string, amountCents int64) error {
    tx, err := db.BeginTx(ctx, &sql.TxOptions{Isolation: sql.LevelReadCommitted})
    if err != nil {
        return fmt.Errorf("starting transaction: %w", err)
    }
    // Guaranteed rollback if any step fails or panics
    defer tx.Rollback()

    // Deduct from source with row lock
    res, err := tx.ExecContext(ctx, "UPDATE accounts SET balance = balance - $1 WHERE id = $2 AND balance >= $1", amountCents, fromAccount)
    if err != nil {
        return fmt.Errorf("deducting balance: %w", err)
    }
    rows, err := res.RowsAffected()
    if err != nil || rows == 0 {
        return fmt.Errorf("insufficient funds or account not found")
    }

    // Add to target
    if _, err := tx.ExecContext(ctx, "UPDATE accounts SET balance = balance + $1 WHERE id = $2", amountCents, toAccount); err != nil {
        return fmt.Errorf("adding balance: %w", err)
    }

    if err := tx.Commit(); err != nil {
        return fmt.Errorf("committing transfer: %w", err)
    }
    return nil
}
```

---

## 2. Decoupling External Side Effects

Never execute external HTTP requests, emails, or message queue pushes inside an active database transaction. Perform them only after `tx.Commit()` succeeds.
