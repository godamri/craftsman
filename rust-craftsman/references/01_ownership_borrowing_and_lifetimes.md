# Ownership, Borrowing & Memory Representation

> **Core Principle**: Rust's borrow checker guarantees memory safety and data-race freedom at compile time. Design data flows to work with the borrow checker, not against it, while avoiding premature lifetime complexity.

---

## 1. The Borrowing Rules

1. At any given time, you can have **either** one mutable reference (`&mut T`) **or** any number of immutable references (`&T`) to a particular piece of data.
2. References must always be valid; the data they point to cannot be dropped while references exist.

---

## 2. Lifetime Elision & Anti-Overengineering

The compiler automatically applies lifetime elision rules:
- Each input reference gets its own lifetime parameter.
- If there is exactly one input lifetime parameter, that lifetime is assigned to all output references.
- If there are multiple input lifetime parameters, but one is `&self` or `&mut self`, the lifetime of `self` is assigned to all output references.

> [!TIP]
> **Anti-Overengineering Rule**: Do not introduce borrowing complexity, `Cow`, or manual lifetime parameters solely to avoid heap allocations unless profiling shows that allocation overhead materially affects system performance. Owned types (`String`, `Vec<T>`, `Box<T>`, `Arc<T>`) are standard, robust tools.

---

## 3. Explicit Memory Representation

Ordinary Rust struct field layout is not guaranteed to be stable or deterministic across compiler releases. If ABI compatibility, FFI, network protocols, or memory alignment requires deterministic layout, specify explicit representations:

```rust
// Guarantees C-compatible field order and alignment
#[repr(C)]
pub struct PacketHeader {
    pub magic: u32,
    pub payload_len: u32,
}

// Guarantees the struct has the exact memory layout of the inner type
#[repr(transparent)]
pub struct AccountId(pub u64);
```
