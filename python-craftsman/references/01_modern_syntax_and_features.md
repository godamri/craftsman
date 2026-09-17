# Language & Typing Baseline (Python 3.12+)

Modern Python features are tools, not design requirements. Prefer the simplest readable syntax.

---

## 1. Filesystem & String Constants

- **Filesystem Paths**: Prefer `pathlib.Path` for filesystem paths in application code because it is clearer and safer than manual string path manipulation.
- **Named String States**: Use `enum.StrEnum` when a closed set of named string states benefits from explicit typing and interoperability.

```python
from enum import StrEnum
from pathlib import Path

class JobStatus(StrEnum):
    PENDING = "pending"
    COMPLETED = "completed"

def load_payload(base_dir: Path, job_id: str) -> str:
    path = base_dir / "jobs" / f"{job_id}.json"
    return path.read_text(encoding="utf-8")
```

---

## 2. Pattern Matching vs If-Else

- **Pattern Matching (`match / case`)**: Use when destructuring nested algebraic data types or complex AST/payload shapes where destructuring adds clear readability.
- **If/Else**: Use standard `if/elif/else` for simple equality checks and boolean conditions.

---

## 3. Type Aliases & Generics (Python 3.12+)

Use the `type` statement and bracket syntax `[T]` for generic definitions:

```python
type JSONPrimitive = str | int | float | bool | None
type JSONDict = dict[str, JSONPrimitive | list[JSONPrimitive]]

def first_or_default[T](items: list[T], default: T) -> T:
    return items[0] if items else default
```
