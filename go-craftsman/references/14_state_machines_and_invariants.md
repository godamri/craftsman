# State Machines & Invariant Engineering

Model complex lifecycles (payments, order processing, workflow orchestration) as formal state machines.

---

## 1. State Machine Modeling

Define explicit states, allowed transitions, and terminal boundaries:

```go
package domain

import (
    "errors"
    "fmt"
)

type PaymentState string

const (
    PaymentStatePending    PaymentState = "PENDING"
    PaymentStateAuthorized PaymentState = "AUTHORIZED"
    PaymentStateCaptured   PaymentState = "CAPTURED"
    PaymentStateFailed     PaymentState = "FAILED"
    PaymentStateRefunded   PaymentState = "REFUNDED"
)

var (
    ErrInvalidStateTransition = errors.New("invalid state transition")
    ErrTerminalState          = errors.New("cannot transition from terminal state")
)

type Payment struct {
    ID      string
    State   PaymentState
    Version int64
}

func (p *Payment) Authorize() error {
    if p.State != PaymentStatePending {
        return fmt.Errorf("%w: cannot authorize payment in %s state", ErrInvalidStateTransition, p.State)
    }
    p.State = PaymentStateAuthorized
    p.Version++
    return nil
}

func (p *Payment) Capture() error {
    if p.State != PaymentStateAuthorized {
        return fmt.Errorf("%w: cannot capture payment in %s state", ErrInvalidStateTransition, p.State)
    }
    p.State = PaymentStateCaptured
    p.Version++
    return nil
}
```

---

## 2. Optimistic Version Fencing

Prevent concurrent state transition races by updating only when the version matches:

```sql
UPDATE payments
SET state = 'CAPTURED', version = version + 1
WHERE id = $1 AND version = $2 AND state = 'AUTHORIZED';
```
If `rows_affected == 0`, return a conflict/stale-version error to trigger an idempotent reload.
