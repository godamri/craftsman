# Performance, Profiling & Memory

Performance optimization must be driven by measurement, not speculation.

---

## 1. Optimization Hierarchy

```text
1. Algorithm & Data Structure (e.g. O(1) set lookup vs O(n) list scan)
   ↓
2. I/O & Network Batching (reducing round-trips)
   ↓
3. Query Design & Indexing (eliminating N+1 queries)
   ↓
4. Concurrency Model (async for I/O, multiprocessing for CPU)
   ↓
5. Memory Allocation (streaming generators for large files, slots for large collections)
   ↓
6. Micro-optimization (only when measured by cProfile / tracemalloc)
```

---

## 2. Memory-Efficient Streaming with Generators

Stream large datasets lazily with generators to maintain constant memory consumption:

```python
from collections.abc import Iterator
from pathlib import Path
import json

def stream_json_lines(path: Path) -> Iterator[dict[str, object]]:
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            if line := line.strip():
                try:
                    yield json.loads(line)
                except json.JSONDecodeError:
                    continue
```

---

## 3. Bounded Caching & Slots

- **`functools.lru_cache(maxsize=...)`**: Always specify `maxsize` to prevent unbounded memory growth.
- **`slots=True`**: Use slots only when object memory usage is a demonstrated concern (e.g. millions of small instances).
