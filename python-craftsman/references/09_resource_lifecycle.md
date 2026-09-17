# Resource Ownership & Lifecycle

> **Principle**: Resource ownership must be explicit, and every acquired resource must have a deterministic release path.

---

## 1. Explicit Ownership & Single-Owner Rule

Every resource (file descriptor, network socket, lock, database connection, child process) must have a single clearly defined owner responsible for closing/releasing it.

```python
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
import asyncio

class ManagedConnection:
    def __init__(self, host: str, port: int) -> None:
        self.host = host
        self.port = port
        self._reader: asyncio.StreamReader | None = None
        self._writer: asyncio.StreamWriter | None = None

    async def __aenter__(self) -> "ManagedConnection":
        self._reader, self._writer = await asyncio.open_connection(self.host, self.port)
        return self

    async def __aexit__(self, exc_type: object, exc_val: object, exc_tb: object) -> None:
        if self._writer is not None:
            self._writer.close()
            await self._writer.wait_closed()
```

---

## 2. Cancellation-Safe Cleanup

Always guarantee resource cleanup even when `asyncio.CancelledError` interrupts execution:

```python
async def transfer_payload(conn: ManagedConnection, data: bytes) -> None:
    try:
        await conn.send(data)
    finally:
        # Guaranteed cleanup on success, failure, or cancellation
        await conn.flush_buffers()
```
