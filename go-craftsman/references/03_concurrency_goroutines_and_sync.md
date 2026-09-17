# Concurrency, Goroutines & Synchronization

> **Principle**: Never start a goroutine without knowing how and when it will stop.

---

## 1. Structured Concurrency with `errgroup`

Use `errgroup.WithContext` to coordinate concurrent tasks with fail-fast cancellation.

```go
package worker

import (
    "context"
    "fmt"
    "golang.org/x/sync/errgroup"
)

func ProcessBatch(ctx context.Context, itemIDs []string) error {
    g, ctx := errgroup.WithContext(ctx)
    // Limit concurrency to 4 simultaneous goroutines
    g.SetLimit(4)

    for _, id := range itemIDs {
        id := id // Go 1.22+ handles loop variable scoping automatically
        g.Go(func() error {
            if err := processItem(ctx, id); err != nil {
                return fmt.Errorf("processing item %s: %w", id, err)
            }
            return nil
        })
    }

    return g.Wait()
}
```

---

## 2. Preventing Goroutine Leaks

Always ensure goroutines exit when context is cancelled:

```go
func StreamResults(ctx context.Context, source <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for {
            select {
            case <-ctx.Done():
                return // Exit immediately on cancellation to avoid leaking goroutine
            case val, ok := <-source:
                if !ok {
                    return
                }
                select {
                case <-ctx.Done():
                    return
                case out <- val * 2:
                }
            }
        }
    }()
    return out
}
```
