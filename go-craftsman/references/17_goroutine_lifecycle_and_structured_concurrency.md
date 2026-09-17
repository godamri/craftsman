# Goroutine Lifecycle & Structured Concurrency

Every goroutine must adhere to the **7-Part Goroutine Contract**:

```text
1. Owner: Which component spawned this goroutine and manages its lifetime?
2. Start Condition: What event triggers this goroutine?
3. Stop Condition: How does this goroutine detect that it must terminate?
4. Cancellation Mechanism: Is ctx.Done() checked on every blocking operation?
5. Wait Mechanism: Does an outer sync.WaitGroup or errgroup.Group wait for termination?
6. Error Propagation: How are errors returned to the caller?
7. Resource Cleanup: Are open channels, sockets, and buffers released in defer?
```

---

## 1. Structured Concurrency with `errgroup`

```go
package pipeline

import (
    "context"
    "fmt"
    "golang.org/x/sync/errgroup"
)

func ProcessItems(ctx context.Context, items []string) error {
    g, ctx := errgroup.WithContext(ctx)
    g.SetLimit(10) // Enforce bounded concurrency limit

    for _, item := range items {
        g.Go(func() error {
            if err := executeWork(ctx, item); err != nil {
                return fmt.Errorf("item %s failed: %w", item, err)
            }
            return nil
        })
    }

    return g.Wait()
}
```

---

## 2. Timer & Ticker Cleanup

Always call `ticker.Stop()` or `timer.Stop()` to prevent leaking runtime timer objects:

```go
ticker := time.NewTicker(1 * time.Second)
defer ticker.Stop()
```
