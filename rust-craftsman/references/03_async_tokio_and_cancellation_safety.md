# Async Tokio, Cancellation Safety & Task Lifecycles

> **Core Principle**: In Tokio, futures can be dropped at any `.await` point (cancellation). In-memory state must remain consistent when dropped, but cancellation safety does not equal transactional atomicity.

---

## 1. Cancellation Safety $\neq$ Transactional Atomicity

When a future is dropped (e.g. in `tokio::select!` or on timeout), execution halts immediately:
- **In-Memory Cancellation Safety**: Ensures in-memory buffers or channel queues are not left half-read or corrupted.
- **External Transactional Atomicity**: Dropping a future does **NOT** undo external database mutations, published messages, or network side effects. Multi-step operations crossing boundaries must establish correctness through explicit database transactions, idempotency keys, outbox/inbox patterns, or compensating actions.

---

## 2. Tokio Runtime Offloading Strategy

Tokio uses a fixed worker thread pool sized to available CPU cores. Blocking an async worker thread starves all other cooperative tasks:

| Workload Type | Execution Strategy | Example |
| :--- | :--- | :--- |
| **Async I/O** | Direct async/await on Tokio | `tokio::net::TcpStream`, `reqwest` async calls. |
| **Blocking File I/O & Short Sync Work** | `tokio::task::spawn_blocking` | `std::fs::read_to_string`, local DNS resolution. |
| **Sustained / Parallel CPU Computation** | Dedicated CPU pool (e.g. Rayon) | Image processing, cryptography key generation, large JSON batch parsing. |

```rust
// Sustained CPU compute delegated to Rayon
let processed_data = tokio::task::spawn_blocking(move || {
    rayon_pool.install(|| {
        heavy_cpu_transform(&raw_data)
    })
}).await??;
```

---

## 3. Task Ownership & Graceful Shutdown Sequence

Every long-lived spawned task must have an explicit owner, a cancellation mechanism, and a join strategy:

```text
1. STOP INGRESS (Refuse new incoming requests / close listeners)
        ↓
2. SIGNAL SHUTDOWN (Broadcast CancellationToken to worker tasks)
        ↓
3. DRAIN WORK (Allow in-flight tasks to complete within a bounded timeout)
        ↓
4. FLUSH STATE (Commit pending outbox events, flush disk buffers)
        ↓
5. JOIN TASKS (Await all JoinHandles to verify clean exit)
```

```rust
use tokio_util::sync::CancellationToken;

pub async fn worker_loop(token: CancellationToken, mut rx: tokio::sync::mpsc::Receiver<Job>) {
    loop {
        tokio::select! {
            _ = token.cancelled() => {
                tracing::info!("Shutdown signal received. Draining remaining jobs...");
                while let Ok(job) = rx.try_recv() {
                    process_job(job).await;
                }
                break;
            }
            Some(job) = rx.recv() => {
                process_job(job).await;
            }
            else => break,
        }
    }
}
```
