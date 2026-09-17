# Typestate Pattern vs Runtime State Machines

> **Core Principle**: Use Rust's type system to make illegal domain states impossible where appropriate, but choose between compile-time typestate and runtime state machines based on actual operational boundaries.

---

## 1. When to Use Typestate (Compile-Time State)

Use typestate when lifecycle invariants are **local, stable, and benefit materially from compile-time enforcement**:

```rust
use std::marker::PhantomData;

pub struct Draft;
pub struct Submitted;
pub struct Paid;

pub struct Order<State> {
    id: String,
    total_cents: u64,
    _state: PhantomData<State>,
}

impl Order<Draft> {
    pub fn new(id: impl Into<String>, total_cents: u64) -> Self {
        Order { id: id.into(), total_cents, _state: PhantomData }
    }

    pub fn submit(self) -> Order<Submitted> {
        Order { id: self.id, total_cents: self.total_cents, _state: PhantomData }
    }
}

impl Order<Submitted> {
    pub fn pay(self) -> Order<Paid> {
        Order { id: self.id, total_cents: self.total_cents, _state: PhantomData }
    }
}
```

---

## 2. When to Use Runtime State Machines (Persisted State)

Use standard runtime enums when state is **externally persisted in databases, dynamically received over the network, or updated asynchronously**:

```rust
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum OrderStatus {
    Draft,
    Submitted,
    Paid,
    Cancelled,
}

pub struct PersistedOrder {
    pub id: String,
    pub status: OrderStatus,
    pub version: u64,
}

impl PersistedOrder {
    pub fn transition_to(&mut self, next: OrderStatus) -> Result<(), DomainError> {
        match (&self.status, &next) {
            (OrderStatus::Draft, OrderStatus::Submitted) => {
                self.status = next;
                self.version += 1;
                Ok(())
            }
            (OrderStatus::Submitted, OrderStatus::Paid) => {
                self.status = next;
                self.version += 1;
                Ok(())
            }
            _ => Err(DomainError::InvalidStateTransition(self.status.clone(), next)),
        }
    }
}
```
*Do not force database-persisted entities into artificial compile-time typestate hierarchies.*
