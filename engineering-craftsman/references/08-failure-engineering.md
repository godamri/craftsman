# Failure Engineering & Resilience Amplification Hazards

> **Core Principle**: Systems must be engineered to fail safely and gracefully. Every resilience mechanism must be evaluated against its potential to amplify failures.

---

## 1. The 10 Realistic Failure Modes

Every critical workflow must account for:
1. **Network Partitions / TCP Dropouts**: Sockets hang without RST packets.
2. **Slow Dependency Degraded Latency**: Downstream responds in 30s instead of 50ms, exhausting thread pools.
3. **Database Connection Pool Exhaustion**: Long-running transactions hold connections idle.
4. **Process Mid-Transaction Crash**: OS terminates process before completing state synchronization.
5. **Disk / Storage Saturation**: WAL logs fill disk, flipping databases into read-only mode.
6. **Expired Auth Credentials / Certificates**: TLS certificates or API tokens expire mid-operation.
7. **Poison Messages**: Malformed payloads repeatedly crash queue workers.
8. **Thundering Herd**: Cache invalidation triggers simultaneous queries to the primary database.
9. **Out-of-Order Message Delivery**: Status update arrives before creation event.
10. **Partial Fleet Deployments**: Version $N$ and $N+1$ communicate with incompatible serialization formats.

---

## 2. Failure Amplification Hazards

| Resilience Mechanism | Intended Benefit | Failure Amplification Risk | Mitigation |
| :--- | :--- | :--- | :--- |
| **Retries** | Absorbs transient blips | **Retry Storm**: Overwhelms recovering backend with exponentially compounding load. | Enforce Max Attempts (e.g. 3), Full Randomized Jitter, and global retry budgets. |
| **Queues** | Decouples throughput peaks | **Hidden Backlog**: Queues grow silently to millions, causing massive lag and OOM crashes. | Strict bounded queues (`max_size`), DLQ after $N$ failures, and queue depth alerting. |
| **Caches** | Offloads database reads | **Stale Truth / Cache Stampede**: Serving stale data or crashing DB when cache expires. | Monotonic read routing, cache warming, probabilistic early expiration (XFetch). |
| **Circuit Breakers** | Fast-fails failing calls | **Premature Outage**: Misconfigured error threshold trips prematurely during brief blips. | Calibrated error rate thresholds with volume minimums and half-open testing. |
