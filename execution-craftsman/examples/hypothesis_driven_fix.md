# Example: Hypothesis-Driven Fix in Action

This example demonstrates how an agent applies the 8-step causal debugging protocol to resolve an unexpected failure during milestone verification without blind patching.

---

## Scenario: Ledger Balance Underflow Under High Concurrency

During Milestone 2 verification of a billing service, the concurrency falsification test fails.

### Step 1: Failure Occurrence
The automated concurrency test reported an invariant violation:
```text
FAIL: TestConcurrentDeductions (0.42s)
    ledger_test.go:88: invariant violation: account balance is negative (-25.00), expected >= 0
```

### Step 2: Reproduce
The failure is reproduced deterministically with a minimal test spawning 10 parallel deduction requests of $25 against an account with $50 balance:
```go
func TestConcurrentDeductionsMinimal(t *testing.T) {
    db := setupTestDB(t)
    accountID := createAccountWithBalance(db, 50.00)

    var wg sync.WaitGroup
    for i := 0; i < 10; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            _ = DeductBalance(db, accountID, 25.00)
        }()
    }
    wg.Wait()

    bal := getBalance(db, accountID)
    if bal < 0 {
        t.Fatalf("Balance invariant broken: %.2f", bal)
    }
}
```

### Step 3: Observe State
Inspecting database query logs during the test run:
```text
[Worker 1] SELECT balance FROM accounts WHERE id = 'acc-123'; -- returns 50.00
[Worker 2] SELECT balance FROM accounts WHERE id = 'acc-123'; -- returns 50.00
[Worker 3] SELECT balance FROM accounts WHERE id = 'acc-123'; -- returns 50.00
[Worker 1] UPDATE accounts SET balance = 25.00 WHERE id = 'acc-123';
[Worker 2] UPDATE accounts SET balance = 25.00 WHERE id = 'acc-123';
[Worker 3] UPDATE accounts SET balance = 25.00 WHERE id = 'acc-123';
```

### Step 4: Locate Boundary
In `ledger/service.go`:
```go
func DeductBalance(db *sql.DB, id string, amount float64) error {
    tx, err := db.Begin()
    if err != nil { return err }
    defer tx.Rollback()

    var current float64
    err = tx.QueryRow("SELECT balance FROM accounts WHERE id = $1", id).Scan(&current)
    if err != nil { return err }

    if current < amount {
        return ErrInsufficientFunds
    }

    _, err = tx.Exec("UPDATE accounts SET balance = balance - $1 WHERE id = $2", amount, id)
    if err != nil { return err }

    return tx.Commit()
}
```
The divergence occurs because the read query does not acquire an exclusive lock, allowing concurrent transactions to pass the `current < amount` check simultaneously.

### Step 5: Form Causal Hypothesis
**Hypothesis**: The read query in `DeductBalance` performs a non-locking `SELECT`, allowing concurrent transactions in `READ COMMITTED` isolation to read the same pre-deduction balance and bypass application-level balance validation before committing.

### Step 6: Validate Hypothesis
1. Checked database transaction isolation level: default PostgreSQL `READ COMMITTED`.
2. Verified query in code: missing `FOR UPDATE` clause.
3. Verified schema: missing `CHECK (balance >= 0)` database-level integrity constraint.

### Step 7: Apply Minimal Justified Fix
Apply the smallest focused change required to enforce the transaction invariant:

```diff
--- a/ledger/service.go
+++ b/ledger/service.go
@@ -6,7 +6,7 @@ func DeductBalance(db *sql.DB, id string, amount float64) error {
     defer tx.Rollback()

     var current float64
-    err = tx.QueryRow("SELECT balance FROM accounts WHERE id = $1", id).Scan(&current)
+    err = tx.QueryRow("SELECT balance FROM accounts WHERE id = $1 FOR UPDATE", id).Scan(&current)
     if err != nil { return err }

     if current < amount {
```

### Step 8: Re-Verify & Regression
1. **Failing Test Re-run**:
   ```bash
   go test -v -run TestConcurrentDeductionsMinimal ./ledger/...
   # Output: PASS: TestConcurrentDeductionsMinimal (0.18s) - Final Balance: 0.00, Successful Deductions: 2, Rejected: 8
   ```

2. **Full Concurrency Suite**:
   ```bash
   go test -v -run TestConcurrentDeductions ./ledger/...
   # Output: PASS (100 parallel workers, zero underflow)
   ```

3. **Regression Suite**:
   ```bash
   go test ./...
   # Output: ok  github.com/example/ledger/cmd  0.08s
   # Output: ok  github.com/example/ledger/pkg  0.45s
   # Output: ok  github.com/example/ledger/tests 1.20s
   # 100% test pass across all existing modules.
   ```

---

## Milestone Report Entry

```text
Defect Record:
- Defect: Concurrent deductions caused balance to drop below zero.
- Root Cause: Non-locking SELECT allowed concurrent transactions to read stale balances.
- Minimal Fix: Added FOR UPDATE row-level locking to transaction read query in ledger/service.go.
- Re-Verification: Concurrency barrier test (100 parallel workers) passed with balance >= 0 invariant maintained.
- Regression: Full test suite green (24 tests passed, 0 failures).
```
