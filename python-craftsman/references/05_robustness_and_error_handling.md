# Robustness & Failure Semantics

---

## 1. Exception Specificity & Chaining

- **Standard vs Custom Exceptions**: Use specific custom exceptions when callers need to distinguish failure types programmatically. Otherwise, built-in exceptions (`ValueError`, `LookupError`, `RuntimeError`) are sufficient.
- **Exception Chaining**: Use `raise CustomError(...) from err` when translating across boundaries to preserve root-cause stack traces.

---

## 2. Safe Inline Retry Pattern

Do not create generic retry decorators as default architecture. Inline retries at specific transient I/O boundaries where operations are idempotent:

```python
import asyncio
import logging
import random

logger = logging.getLogger(__name__)

async def fetch_with_retry(url: str, max_attempts: int = 3) -> str:
    for attempt in range(1, max_attempts + 1):
        try:
            return await call_remote_api(url)
        except (TimeoutError, ConnectionResetError) as exc:
            if attempt == max_attempts:
                logger.error("Request to %s failed after %d attempts: %s", url, max_attempts, exc)
                raise
            jitter = random.uniform(0.8, 1.2)
            delay = (0.2 * (2 ** (attempt - 1))) * jitter
            logger.warning("Transient failure on %s (attempt %d/%d). Retrying in %.2fs...", url, attempt, max_attempts, delay)
            await asyncio.sleep(delay)
```

---

## 3. Structured Logging

Use lazy format arguments with metadata in the `extra` dict:

```python
import logging

logger = logging.getLogger(__name__)

logger.info(
    "User authentication succeeded for user_id=%s",
    "usr_123",
    extra={"user_id": "usr_123", "event": "auth_success"},
)
```
