# Concurrency, Invariant & Replay Testing

> **Principle**: Test the invariant, not merely the implementation path.

---

## 1. Concurrency Testing Without Arbitrary `sleep()`

Use synchronization primitives (`asyncio.Barrier` or `threading.Barrier`) to guarantee simultaneous execution and test race conditions deterministically.

```python
import asyncio
import pytest

class InMemoryCounter:
    def __init__(self) -> None:
        self.value = 0
        self._lock = asyncio.Lock()

    async def increment(self) -> None:
        async with self._lock:
            current = self.value
            await asyncio.sleep(0)  # Yield point to expose unprotected race conditions
            self.value = current + 1

@pytest.mark.asyncio
async def test_concurrent_counter_increments() -> None:
    counter = InMemoryCounter()
    barrier = asyncio.Barrier(10)

    async def worker() -> None:
        await barrier.wait()  # Synchronize all 10 workers to start at the exact same instant
        await counter.increment()

    async with asyncio.TaskGroup() as tg:
        for _ in range(10):
            tg.create_task(worker())

    # Invariant: Exact count matches total operations
    assert counter.value == 10
```

---

## 2. Idempotency & Replay Testing

Verify that executing the same command twice does not create duplicate side effects or corrupted state:

```python
def test_idempotent_account_activation() -> None:
    account = Account(id=uuid.uuid4(), balance=Money(100), is_active=False)
    
    # First execution
    account.activate()
    assert account.is_active is True

    # Replay execution: must be a safe no-op or explicit handled rejection
    with pytest.raises(UserAlreadyActiveError):
        account.activate()
```

---

## 3. Database Rollback Testing

```python
def test_transaction_rolls_back_on_error(db_conn: sqlite3.Connection) -> None:
    with pytest.raises(ValueError):
        with transaction(db_conn) as cursor:
            cursor.execute("INSERT INTO accounts (id, balance) VALUES ('123', 500)")
            raise ValueError("Forced application failure inside transaction")

    # Assert invariant: record was never persisted
    cursor = db_conn.cursor()
    cursor.execute("SELECT count(*) FROM accounts WHERE id = '123'")
    assert cursor.fetchone()[0] == 0
```
