# Time, Ordering & Distributed Causality

> **Core Principle**: Physical wall-clock time (`time.Now()`) cannot guarantee causal ordering across distributed nodes due to NTP synchronization jumps and crystal oscillator drift.

---

## 1. Wall-Clock vs Monotonic Clock

- **Wall Clock (`time.Now().UTC()`)**: Represents human calendar time. Susceptible to NTP step adjustments (can jump backward in time!). Unsafe for ordering or timeout interval calculation.
- **Monotonic Clock (`time.Since(start)`)**: Continuously ticks forward on a single CPU. Safe for calculating local durations and timeouts. Cannot be compared across different machines.

---

## 2. Distributed Ordering Primitives

1. **Monotonic Sequences from Single Leader**: Central PostgreSQL sequences (`BIGSERIAL`) or Raft consensus log indexes.
2. **UUIDv7**: Time-ordered UUIDs with millisecond timestamp prefix and monotonic random entropy bits.
3. **Lamport Timestamps**: Simple scalar integer incremented on local events and updated to `max(local, incoming) + 1` on message receipt.
4. **Vector Clocks**: Array of counters tracking causal history across $N$ known nodes.
