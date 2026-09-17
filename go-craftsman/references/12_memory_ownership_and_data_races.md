# Memory Ownership, Aliasing & Data Races

Understanding Go's memory and ownership model prevents memory leaks, data corruption, and runtime panics.

---

## 1. Slice Aliasing & Defensive Copying

Slices are reference headers containing a pointer, length, and capacity. Reslicing an existing slice shares the underlying array:

```go
type DocumentStore struct {
    tags []string
}

// Unsafe: Caller can modify store's internal slice elements
func (d *DocumentStore) UnsafeTags() []string {
    return d.tags
}

// Safe: Return a defensive copy when the caller might mutate it
func (d *DocumentStore) Tags() []string {
    if len(d.tags) == 0 {
        return nil
    }
    copied := make([]string, len(d.tags))
    copy(copied, d.tags)
    return copied
}
```

> [!NOTE]
> Copy only when ownership or mutation semantics require it. Do not copy small, read-only slices unnecessarily.

---

## 2. Channel Ownership & Panic Prevention

Sending to a closed channel causes an immediate, unrecoverable panic: `panic: send on closed channel`.

### Channel Ownership Rules:
1. **The producer owns the channel**: The goroutine that writes to a channel is the only entity permitted to close it.
2. **Never close from the consumer**: Receivers must never call `close(ch)`.
3. **Multiple producers**: If multiple goroutines write to a single channel, use a `sync.WaitGroup` or coordinate closure through a separate owner goroutine.

```go
func ProduceItems(ctx context.Context, count int) <-chan int {
    out := make(chan int, 10)
    go func() {
        defer close(out) // Producer alone closes the channel
        for i := 0; i < count; i++ {
            select {
            case <-ctx.Done():
                return
            case out <- i:
            }
        }
    }()
    return out
}
```

---

## 3. Race Detector Limitations

> **Critical Rule**: `go test -race` detects data races; it does **NOT** prove the absence of deadlocks, leaks, ordering bugs, lost work, or distributed consistency failures.
