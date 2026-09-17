# Architecture & Design Rules

Architecture must follow actual system complexity, not architectural fashion.

---

## 1. Value Objects vs Entities

- **Value Objects**: Immutable by default (`@dataclass(frozen=True)`). Compare by value, validate invariants on construction.
- **Entities**: Encapsulate identity (`id`) and state transitions. Mutability is expected when lifecycle/state transitions require mutation.

```python
import uuid
from dataclasses import dataclass

@dataclass(frozen=True)
class Money:
    amount_cents: int
    currency: str = "USD"

@dataclass
class Account:
    id: uuid.UUID
    balance: Money
    is_active: bool = True

    def withdraw(self, amount: Money) -> None:
        if not self.is_active:
            raise RuntimeError(f"Account {self.id} is inactive.")
        if self.balance.amount_cents < amount.amount_cents:
            raise ValueError(f"Insufficient funds in account {self.id}.")
        self.balance = Money(self.balance.amount_cents - amount.amount_cents, self.balance.currency)
```

---

## 2. Explicit Dependency Injection

Pass dependencies explicitly into constructors or function arguments. Avoid dependency injection frameworks for ordinary Python applications.

```python
class PaymentService:
    def __init__(self, storage: BlobStoragePort) -> None:
        self._storage = storage
```
