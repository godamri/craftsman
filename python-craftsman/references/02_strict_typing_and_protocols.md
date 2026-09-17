# Typing & Interface Decision Rules

Type hints and interfaces should clarify code and enforce contracts at real boundaries without adding speculative machinery.

---

## 1. When to Introduce Interfaces (`typing.Protocol`)

- **Rule**: Introduce an interface only when it creates a real benefit at a dependency boundary, test seam, or multiple-implementation requirement.
- **Do not introduce Protocols** if only one concrete implementation exists and no mock/fake isolation is required.

```python
from typing import Protocol

# Introduce only when multiple storage backends or test fakes exist
class BlobStoragePort(Protocol):
    def read_bytes(self, key: str) -> bytes: ...
    def write_bytes(self, key: str, data: bytes) -> None: ...
```

---

## 2. Function Overloads (`@typing.overload`)

Use `@overload` only when a function's return type depends strictly on input argument types or literal flags:

```python
from typing import overload, Literal
from pathlib import Path

@overload
def read_content(path: Path, *, as_text: Literal[True]) -> str: ...

@overload
def read_content(path: Path, *, as_text: Literal[False] = False) -> bytes: ...

def read_content(path: Path, *, as_text: bool = False) -> str | bytes:
    if as_text:
        return path.read_text(encoding="utf-8")
    return path.read_bytes()
```
