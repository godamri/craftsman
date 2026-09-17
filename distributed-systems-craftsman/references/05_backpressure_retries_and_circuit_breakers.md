# Backpressure, Retries & Circuit Breakers

---

## 1. Preventing Retry Storms: Full Jitter Algorithm

When an upstream dependency fails, concurrent clients retrying on a fixed exponential schedule synchronize and overwhelm the recovering service (thundering herd).

### Full Jitter Backoff Formula (AWS Architecture standard):
```text
sleep = random_between(0, min(max_delay, base_delay * (2 ^ attempt)))
```

```go
func FullJitterBackoff(attempt int, baseDelay, maxDelay time.Duration) time.Duration {
    temp := min(maxDelay, baseDelay*(1<<attempt))
    if temp <= 0 {
        return baseDelay
    }
    return time.Duration(rand.Int64N(int64(temp)))
}
```

---

## 2. Circuit Breaker States & Fast-Failing

- **CLOSED**: Normal operation. Calls pass through. If error rate > threshold, trip to **OPEN**.
- **OPEN**: Fast-fail requests immediately without calling downstream. Prevents resource exhaustion. After timeout, transition to **HALF-OPEN**.
- **HALF-OPEN**: Allow a single trial request. If it succeeds, reset to **CLOSED**; if it fails, return to **OPEN**.
