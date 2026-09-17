# Time & Clock Correctness

> **Critical Rule**: Wall-clock timestamps are not a reliable distributed ordering primitive due to clock skew and NTP jumps.

---

## 1. Monotonic vs Wall-Clock Time in Go

- **`time.Time` in Go**: Holds both wall clock (for calendar dates/times) and monotonic clock (for measuring durations).
- **Duration Measurements**: Always use `time.Since(start)` or `t2.Sub(t1)` which use the monotonic clock and remain unaffected by NTP adjustments.
- **Serialization**: Converting to JSON or database timestamps strips the monotonic clock.

---

## 2. Distributed Ordering Alternatives

Never rely on `time.Now()` across multiple servers to order concurrent transactions. Use:
1. Database autoincrementing sequences or identity columns.
2. Monotonic epoch version counters.
3. UUIDv7 (k-sorted by millisecond timestamp + random monotonic bits).
