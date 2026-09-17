# Proof-Before-Pass & Adversarial Verification Protocol

> **Core Principle**: An implementation agent MUST NEVER declare code `safe`, `correct`, `race-free`, `idempotent`, or `production-ready` without executed verification evidence and explicit assumptions.

---

## 1. The 15 Failure Verification Dimensions

Before certifying any production Go component, evaluate and verify its invariants across all 15 dimensions:

1. **Concurrent Mutation**: Multiple goroutines or instances mutating the same entity simultaneously.
2. **Lost Update Prevention**: Verify optimistic version fencing (`version`) or atomic SQL mutation prevents overwriting concurrent writes.
3. **Duplicate Delivery**: Verify identical requests with the same idempotency key return cached results with zero duplicate side effects.
4. **Out-of-Order Delivery**: Verify state machines reject illegal transitions when events arrive out of order.
5. **Retry After Timeout**: Verify client retries against unknown outcomes do not double-charge or corrupt state.
6. **Crash-After-Commit**: Verify that if the process dies immediately after committing a database transaction, outbox dispatchers recover and replay events.
7. **Cancellation During Blocking I/O**: Verify all goroutines terminate promptly when `ctx.Done()` fires.
8. **Shutdown While Work Is Active**: Verify in-flight requests finish or abort cleanly without leaving orphaned goroutines or broken transactions.
9. **Resource Exhaustion & Bounded Capacity**: Verify channel buffers, request payloads, and connection pools enforce strict limits against OOM.
10. **Database Disconnect**: Verify transient connection drops return retriable errors and do not deadlock connection pools.
11. **Rolling Deployment (N / N+1)**: Verify schema and serialization formats allow mixed-version fleets to run concurrently.
12. **Security Boundary Bypass**: Verify SSRF dialers block DNS rebinding and path sanitizers block symlink escapes.
13. **Goroutine Termination**: Verify every spawned goroutine exits cleanly with zero goroutine leaks.
14. **Subprocess Timeout & Descendant Cleanup**: Verify child process groups are terminated when context timeouts expire.
15. **Output Limit Enforcement**: Verify subprocesses or readers exceeding memory limits are aborted deterministically with explicit errors.

---

## 2. Verdict Vocabulary

| Verdict | Meaning |
| :--- | :--- |
| **`PASS`** | Invariant is verified by executed automated tests exercising concurrency and failure modes. |
| **`PASS WITH EXPLICIT ASSUMPTIONS`** | Verified under documented operational preconditions (e.g. single-leader DB). |
| **`FAIL`** | Invariant breach detected or unhandled failure mode identified. |
| **`UNVERIFIED`** | Code compiled, but required environment (e.g. live database) was unavailable. |
| **`BLOCKED BY ENVIRONMENT`** | Toolchain or network restrictions prevented test execution. |

> **CRITICAL RULE**: `UNVERIFIED` must NEVER be silently converted into `PASS`.
