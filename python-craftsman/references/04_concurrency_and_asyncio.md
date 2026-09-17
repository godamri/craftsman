# Concurrency & Async Rules

Concurrency improves throughput and latency only when the workload and underlying drivers benefit from it.

---

## 1. Concurrency Model Selection

- **`asyncio`**: When workload is I/O-bound and async-compatible libraries are available.
- **Threadpool / `asyncio.to_thread`**: When I/O libraries are blocking.
- **Processpool**: When workload is strictly CPU-bound.
- **Synchronous**: Default for simple, sequential workflows.

---

## 2. `TaskGroup` vs `gather`

- **`asyncio.TaskGroup`**: Use when related sibling tasks must fail together (exception in one cancels all siblings).
- **`asyncio.gather(*tasks, return_exceptions=True)`**: Use when independent partial results are intentionally acceptable.

```python
import asyncio

async def fetch_user_data(user_id: int) -> tuple[dict[str, object], list[str]]:
    async with asyncio.TaskGroup() as tg:
        t1 = tg.create_task(get_profile(user_id))
        t2 = tg.create_task(get_permissions(user_id))
    return t1.result(), t2.result()
```

---

## 3. Timeouts, Limits & Cancellation

- **Timeouts**: Wrap remote operations in `asyncio.timeout(seconds)`.
- **Throttling**: Bound concurrent connections via `asyncio.Semaphore(max_concurrency)`.
- **Cancellation**: If `asyncio.CancelledError` is caught for cleanup, **always re-raise it**.
