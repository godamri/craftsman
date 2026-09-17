# Performance, Allocation & Dispatch Strategy

> **Core Principle**: Profile before micro-optimizing. Choose static or dynamic dispatch and memory structures based on real workload requirements, not dogma.

---

## 1. Static vs Dynamic Dispatch

| Approach | Mechanism | Benefits | When to Choose |
| :--- | :--- | :--- | :--- |
| **Static Dispatch** (`impl Trait`, Generics) | Compile-time monomorphization | Zero runtime overhead, full compiler inlining. | Internal core loops, hot data paths, mathematical algorithms. |
| **Dynamic Dispatch** (`Box<dyn Trait>`, `&dyn Trait`) | Runtime vtable lookup | Heterogeneous collections, decoupled plugin boundaries, reduced binary size, faster build times. | Dependency boundaries, middleware chains, test seams, plugin handlers. |

---

## 2. Practical Allocation Strategy

- **Default to Owned Types Where Simple**: Standard types like `String` and `Vec<T>` are clear, safe, and maintainable.
- **`Cow<'a, T>` for Conditional Mutation**: Use Copy-on-Write (`Cow`) only when benchmark measurements demonstrate that cloning in read-heavy paths is an actual bottleneck.
- **Stack Slices for Read APIs**: Accept `&str` and `&[T]` in function arguments to allow callers to pass either stack or heap data without forcing allocations.

---

## 3. Benchmarking Discipline

Use statistical benchmarking (`criterion`) to measure performance changes against baseline thresholds before accepting complex optimizations.
