# Context & Cancellation

Context controls deadlines, cancellation signals, and request-scoped values across API boundaries.

---

## 1. Context Propagation Rules

1. **First Parameter**: `ctx context.Context` must always be the first parameter of any function performing I/O.
2. **Never Store in Structs**: Do not store a `context.Context` inside a struct field. Pass it explicitly through method signatures.
3. **Pass Downstream**: Always pass `ctx` to all downstream database calls, HTTP client requests, and subprocesses.

```go
package service

import (
    "context"
    "fmt"
    "time"
)

func QueryWithTimeout(parentCtx context.Context, query string) (string, error) {
    ctx, cancel := context.WithTimeout(parentCtx, 2*time.Second)
    defer cancel()

    result, err := executeQuery(ctx, query)
    if err != nil {
        if errors.Is(ctx.Err(), context.DeadlineExceeded) {
            return "", fmt.Errorf("query timed out after 2s: %w", err)
        }
        return "", err
    }
    return result, nil
}
```
