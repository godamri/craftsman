# Error Handling: `thiserror` vs `anyhow` & Panic Policy

> **Core Principle**: Errors are explicit domain values in Rust. Panics in production request paths represent unhandled defects and must be eliminated.

---

## 1. Domain Errors with `thiserror` (Libraries & Core Domains)

Use `thiserror` to define strongly typed, enumerated errors that callers can programmatically match against:

```rust
use thiserror::Error;

#[derive(Debug, Error)]
pub enum PaymentError {
    #[error("account {0} has insufficient balance (required: {1}, available: {2})")]
    InsufficientBalance(String, u64, u64),

    #[error("payment gateway timeout after {0:?}")]
    GatewayTimeout(std::time::Duration),

    #[error("database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("invalid account state: {0}")]
    InvalidState(String),
}
```

---

## 2. Application Ingress with `anyhow` (CLI & Main Services)

Use `anyhow` at the outermost layer of an application (HTTP route handlers, background worker loops, CLI entrypoints) to attach rich operational context:

```rust
use anyhow::{Context, Result};

pub async fn run_billing_cycle(account_id: &str) -> Result<()> {
    let account = fetch_account(account_id)
        .await
        .with_context(|| format!("failed to fetch account {account_id}"))?;

    charge_card(&account)
        .await
        .with_context(|| format!("card charge failed for account {account_id}"))?;

    Ok(())
}
```

---

## 3. Panic Policy: Production vs Tests & Examples

- **Production Request Paths**: `.unwrap()` and `.expect()` are **strictly prohibited** unless accompanied by an explicit invariant proof comment (`// INVARIANT:`). A proof comment is never an excuse for convenience; error propagation (`?`) is always preferred.
- **Tests, Benchmarks & Example Runners**: Calling `.unwrap()` or `.expect()` is permitted to assert test setup conditions and fixture integrity without setting bad guidance for production code.

```rust
// INVARIANT: The regex pattern is a compile-time static literal verified by unit tests.
static EMAIL_REGEX: Lazy<Regex> = Lazy::new(|| Regex::new(r"^\S+@\S+\.\S+$").expect("valid regex"));
```
