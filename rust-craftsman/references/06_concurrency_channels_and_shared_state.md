# Concurrency, Mutex Discipline & Channel Semantics

---

## 1. Mutex Discipline: `std::sync::Mutex` vs `tokio::sync::Mutex`

- **`std::sync::Mutex<T>` / `parking_lot::Mutex<T>`**:
  - Best for short, in-memory synchronous critical sections (e.g. updating a map or counter).
  - **Hazard**: A synchronous `MutexGuard` MUST NOT be held across an `.await` boundary. Doing so risks runtime thread starvation, deadlocks under load, and produces non-`Send` futures that cannot be spawned on multi-threaded Tokio runtimes.
- **`tokio::sync::Mutex<T>`**:
  - Use ONLY when a lock must genuinely be held while performing asynchronous I/O across an `.await` point.

```rust
// ✅ CORRECT: Scope synchronous lock so it is dropped BEFORE .await
{
    let mut guard = sync_mutex.lock().unwrap();
    guard.update_state();
} // Lock released immediately

// Async network operation proceeds without holding the lock
network_client.send_heartbeat().await?;
```

---

## 2. Channel Semantics & System Backpressure

| Channel | Model | Semantics |
| :--- | :--- | :--- |
| **`tokio::sync::mpsc::channel(n)`** | Multi-producer, single-consumer | Bounded FIFO queue. Provides natural backpressure by suspending senders when full. |
| **`tokio::sync::oneshot::channel()`** | Single-producer, single-consumer | Exactly 1 value handshake. |
| **`tokio::sync::watch::channel(val)`**| Multi-receiver, retains latest value | State broadcasting (e.g. dynamic config, readiness flags). |
| **`tokio::sync::broadcast::channel(n)`**| Multi-producer, multi-consumer | Ring-buffer event stream. Lagging receivers receive `RecvError::Lagged` and skip missed items. |

> [!IMPORTANT]
> **System-Wide Backpressure**: Backpressure must propagate from downstream databases/APIs all the way to ingress endpoints. Never use unbounded queues (`unbounded_channel()`) to disguise downstream bottlenecks.
