# Failure Injection & Chaos Testing

---

## 1. Configurable Fault-Injecting Fakes

Instead of mocking single return values, create configurable fakes that simulate real infrastructure degradation:

```go
type FaultInjectingGateway struct {
    FailEveryNth int
    Latency      time.Duration
    callCount    atomic.Int64
}

func (f *FaultInjectingGateway) ProcessPayment(ctx context.Context, amount int64) error {
    count := f.callCount.Add(1)
    if f.Latency > 0 {
        select {
        case <-time.After(f.Latency):
        case <-ctx.Done():
            return ctx.Err()
        }
    }
    if f.FailEveryNth > 0 && count%int64(f.FailEveryNth) == 0 {
        return errors.New("simulated network drop / 503 service unavailable")
    }
    return nil
}
```

Verify that the caller handles timeout, retries with backoff, and leaves no orphaned resources.
