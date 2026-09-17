use std::fmt;
use std::marker::PhantomData;

// ==============================================================================
// 1. DOMAIN ERROR TYPES (Implementing std::error::Error)
// ==============================================================================

#[derive(Debug, PartialEq, Eq)]
pub enum OrderError {
    InvalidAmount(u64),
    PaymentFailed(String),
}

impl fmt::Display for OrderError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            OrderError::InvalidAmount(cents) => {
                write!(f, "invalid order amount: {} cents (must be > 0)", cents)
            }
            OrderError::PaymentFailed(reason) => {
                write!(f, "payment processing failed: {}", reason)
            }
        }
    }
}

impl std::error::Error for OrderError {}

// ==============================================================================
// 2. TYPESTATE PATTERN: ZERO-SIZED STATE MARKERS
// ==============================================================================

#[derive(Debug)]
pub struct Draft;

#[derive(Debug)]
pub struct Submitted;

#[derive(Debug)]
pub struct Paid;

#[derive(Debug)]
pub struct Order<State> {
    id: String,
    total_cents: u64,
    _state: PhantomData<State>,
}

impl Order<Draft> {
    pub fn new(id: impl Into<String>, total_cents: u64) -> Result<Self, OrderError> {
        if total_cents == 0 {
            return Err(OrderError::InvalidAmount(0));
        }
        Ok(Order {
            id: id.into(),
            total_cents,
            _state: PhantomData,
        })
    }

    pub fn submit(self) -> Order<Submitted> {
        println!("📝 Order {} transitioned from Draft -> Submitted", self.id);
        Order {
            id: self.id,
            total_cents: self.total_cents,
            _state: PhantomData,
        }
    }
}

impl Order<Submitted> {
    pub fn process_payment(self, simulate_success: bool) -> Result<Order<Paid>, OrderError> {
        if !simulate_success {
            return Err(OrderError::PaymentFailed("insufficient funds".to_string()));
        }
        println!(
            "💳 Order {} transitioned from Submitted -> Paid (${:.2})",
            self.id,
            self.total_cents as f64 / 100.0
        );
        Ok(Order {
            id: self.id,
            total_cents: self.total_cents,
            _state: PhantomData,
        })
    }
}

impl Order<Paid> {
    pub fn id(&self) -> &str {
        &self.id
    }

    pub fn total_cents(&self) -> u64 {
        self.total_cents
    }
}

// ==============================================================================
// 3. MAIN RUNNER & VERIFICATION
// ==============================================================================

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("=== RUST CRAFTSMAN: TYPESTATE & ERROR HANDLING DEMO ===");

    // 1. Invalid Order Validation
    let invalid_order = Order::new("ord_000", 0);
    assert_eq!(invalid_order.unwrap_err(), OrderError::InvalidAmount(0));
    println!("✅ 1. Zero amount properly rejected by type constructor");

    // 2. Happy Path Lifecycle
    let draft = Order::new("ord_101", 4500)?;
    let submitted = draft.submit();
    let paid = submitted.process_payment(true)?;

    println!(
        "✅ 2. Order {} successfully completed and paid (Total: {} cents)",
        paid.id(),
        paid.total_cents()
    );

    // 3. Simulated Payment Failure
    let draft2 = Order::new("ord_102", 9900)?;
    let submitted2 = draft2.submit();
    let payment_result = submitted2.process_payment(false);

    match payment_result {
        Err(OrderError::PaymentFailed(reason)) => {
            println!("✅ 3. Handled expected payment failure cleanly: {}", reason);
        }
        _ => panic!("Expected PaymentFailed error"),
    }

    println!("=== ALL INVARIANTS VERIFIED AT COMPILE TIME & RUNTIME ===");
    Ok(())
}
