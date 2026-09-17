# `unsafe` Discipline, Soundness & Miri

> **Core Principle**: An `unsafe` block must be sound. Safe code calling an `unsafe` wrapper can NEVER trigger Undefined Behavior (UB) under any valid input.

---

## 1. Rust 2024 `unsafe_op_in_unsafe_fn` Discipline

In modern Rust, declaring a function `unsafe fn` does not make the entire function body implicitly unsafe. Keep unsafe operations strictly scoped inside explicit `unsafe {}` blocks:

```rust
pub unsafe fn write_volatile_byte(ptr: *mut u8, val: u8) {
    // Non-unsafe setup code...

    // SAFETY:
    // 1. Caller guarantees `ptr` is valid, non-null, and properly aligned.
    // 2. Volatile write ensures hardware MMIO side effects are not optimized away.
    unsafe {
        std::ptr::write_volatile(ptr, val);
    }
}
```

---

## 2. Miri Verification Scope & Limitations

`cargo miri test` executes Rust test suites inside an interpreter that detects:
- Out-of-bounds pointer arithmetic and memory accesses.
- Use-after-free and dangling pointer dereferences.
- Unaligned memory reads/writes.
- Data races (under supported concurrency models).

> [!WARNING]
> **Miri is not an absolute mathematical proof**: Miri only checks paths that your tests actually execute, and does not support arbitrary external FFI or certain OS syscalls. Soundness requires thorough code reviews, invariant proofs, and property-based fuzzing in addition to Miri.
