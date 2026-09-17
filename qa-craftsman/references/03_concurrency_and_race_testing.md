# Concurrency & Race Condition Testing

> **Core Principle**: Never use `time.Sleep()` to synchronize concurrent test routines. Use deterministic synchronization barriers (`sync.WaitGroup`, channels, countdown latches).

---

## 1. The Synchronized Race Barrier Pattern

To maximize the probability of catching race conditions, hold all concurrent workers at a starting gate before releasing them simultaneously:

```go
func TestConcurrentAccountDebits(t *testing.T) {
    const numWorkers = 50
    const initialBalance = 1000

    account := NewAccount(initialBalance)
    startGate := make(chan struct{})
    var wg sync.WaitGroup

    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            <-startGate // Wait for all workers to spawn and align

            // Simultaneous concurrent mutation
            _ = account.Debit(10)
        }()
    }

    // Release all 50 workers simultaneously
    close(startGate)
    wg.Wait()

    // Assert invariant: Balance must be >= 0 and exactly reflect successful debits
    if account.Balance < 0 {
        t.Fatalf("Invariant violated: negative balance %d", account.Balance)
    }
}
```
Run with `go test -race -count=20 .` to prove absence of data races.
