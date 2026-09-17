# Failure Injection & Recovery Testing

Verify system recovery behavior under simulated adversarial failures.

---

## 1. Simulating Partial Failures & Disconnections

Use test doubles or network proxies to inject transient faults:

```go
type FlakyStore struct {
    failuresRemaining int
}

func (f *FlakyStore) Save(ctx context.Context, data []byte) error {
    if f.failuresRemaining > 0 {
        f.failuresRemaining--
        return net.ErrClosed // Simulate transient connection drop
    }
    return nil // Succeeds on retry
}
```

---

## 2. Testing Crash-After-Commit Recovery

Verify that if a worker dies after committing a database transaction but before completing external dispatch, the background reconciliation worker picks up the pending outbox record.
