# Backpressure, Overload & Capacity

> **Critical Rule**: Reject "just spawn more goroutines." Unbounded concurrency converts load spikes into fatal out-of-memory crashes.

---

## 1. Bounded Queues & Backpressure

Always bound channel capacity. If an incoming producer exceeds worker capacity, enforce backpressure or reject with load shedding:

```go
type RateLimiter struct {
    sem chan struct{}
}

func NewRateLimiter(maxConcurrent int) *RateLimiter {
    return &RateLimiter{sem: make(chan struct{}, maxConcurrent)}
}

func (r *RateLimiter) TryAcquire() bool {
    select {
    case r.sem <- struct{}{}:
        return true
    default:
        return false // Shed load immediately when capacity is saturated
    }
}

func (r *RateLimiter) Release() {
    <-r.sem
}
```

---

## 2. Preventing Retry Storms (Jitter & Budgets)

```go
// Exponential backoff with Full Jitter
func BackoffWithJitter(attempt int, baseDelay, maxDelay time.Duration) time.Duration {
    temp := min(maxDelay, baseDelay*(1<<attempt))
    return time.Duration(rand.Int64N(int64(temp)))
}
```
