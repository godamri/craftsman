# Observability & Configuration

---

## 1. Startup Configuration & Secrets Validation

Validate environment variables at startup and fail fast before accepting traffic.

```python
import os
from dataclasses import dataclass

class ConfigurationError(Exception):
    """Raised when mandatory application settings are invalid or missing."""

@dataclass(frozen=True)
class AppConfig:
    database_url: str
    port: int
    api_key: str  # Kept in memory, never printed or logged

    @classmethod
    def from_env(cls) -> "AppConfig":
        db_url = os.getenv("DATABASE_URL")
        if not db_url:
            raise ConfigurationError("DATABASE_URL environment variable is mandatory.")
        
        try:
            port = int(os.getenv("PORT", "8080"))
        except ValueError as err:
            raise ConfigurationError("PORT must be a valid integer.") from err

        api_key = os.getenv("API_KEY")
        if not api_key:
            raise ConfigurationError("API_KEY environment variable is mandatory.")

        return cls(database_url=db_url, port=port, api_key=api_key)
```

---

## 2. Structured Logging with Context

> **Principle**: Log an error where it can be acted upon, not at every layer it passes through.

```python
import logging

logger = logging.getLogger(__name__)

# Include correlation context in the 'extra' mapping
logger.info(
    "Processing order payment",
    extra={"order_id": "ord_987", "user_id": "usr_123", "request_id": "req_abc"},
)
```
