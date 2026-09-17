# Transactional Thinking & State Lifecycles

> **Core Principle**: Never assume transport acknowledgment (e.g. `HTTP 200 OK`) equals business transaction settlement. Every state-changing workflow must account for intermediate and unknown states.

---

## 1. The Explicit State Transition Lifecycle

```text
[ ATTEMPTED ] ──(Validation)──> [ ACCEPTED ] ──(DB Commit)──> [ COMMITTED ]
                                                                   │
                                                                   ▼ (Outbox Dispatch)
[ SETTLED / COMPLETED ] <──(Downstream Ack)── [ PUBLISHED / IN-FLIGHT ]
       │
       └──(Refund/Cancel)──> [ REVERSED / COMPENSATED ]
```

---

## 2. Managing the "UNKNOWN" Outcome

When a network timeout occurs during an external payment or mutation API call:
- **Rule 1**: The outcome is **UNKNOWN**, not failed.
- **Rule 2**: Never blindly retry non-idempotent operations or assume the transaction aborted.
- **Rule 3**: Query the external provider using the original `Idempotency-Key` or trigger a background reconciliation job before modifying local state.
