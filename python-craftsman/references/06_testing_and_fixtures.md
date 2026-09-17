# Practical Testing & Test Doubles

Tests should target actual operational risk rather than boilerplate coverage.

---

## 1. Test Matrix

- **Unit Tests**: Pure domain logic, state machines, and deterministic algorithms.
- **Integration Tests**: Real database queries, filesystem operations, and HTTP client adapters.
- **Contract Tests**: External schemas, serialization formats, and API boundaries.
- **End-to-End Tests**: Critical user workflows and complete system paths.

---

## 2. In-Memory Fakes Over Heavy Mocking

Use simple in-memory fakes implementing the target protocol for deterministic tests:

```python
from typing import Protocol

class PaymentPort(Protocol):
    def charge(self, user_id: str, amount_cents: int) -> bool: ...

class FakePaymentGateway:
    def __init__(self) -> None:
        self.charged: list[tuple[str, int]] = []
        self.should_fail: bool = False

    def charge(self, user_id: str, amount_cents: int) -> bool:
        if self.should_fail:
            return False
        self.charged.append((user_id, amount_cents))
        return True
```

---

## 3. Parametrization with Explicit IDs

```python
import pytest

@pytest.mark.parametrize(
    ("price", "is_vip", "expected"),
    [
        (100.0, True, 80.0),
        (100.0, False, 100.0),
    ],
    ids=["vip-discount", "standard-no-discount"],
)
def test_discounts(price: float, is_vip: bool, expected: float) -> None:
    assert calculate_discount(price, is_vip=is_vip) == pytest.approx(expected)
```
