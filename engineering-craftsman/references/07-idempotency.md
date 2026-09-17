# Idempotency & Duplicate Execution Defense

> **Core Principle**: In any system exposed to network retries, message brokers, webhooks, or user double-clicks, operations must be strictly idempotent.

---

## 1. Idempotency Key Binding Protocol

```text
Incoming Request ──> [ Extract Idempotency-Key & Compute Payload SHA-256 Hash ]
                             │
                             ▼
               [ Query Persistent Inbox Table ]
                 ├── Found & Same Hash     ──> Return Cached Response (IDEMPOTENT REPLAY)
                 ├── Found & Different Hash──> Reject with 409 Conflict (KEY CONFLICT)
                 └── Not Found             ──> Execute Business Mutation & Persist Response
```

---

## 2. Invariant Checklist for Idempotent APIs

1. **Cryptographic Binding**: Bind the idempotency key to a hash of the request body and user identity to prevent key-hijacking.
2. **Atomic Registration**: Insert the in-progress idempotency record inside the transaction or via atomic conditional write (`INSERT ... ON CONFLICT DO NOTHING`).
3. **Retention Window**: Retain idempotency records for a defined operational window (e.g. 7–30 days) before automated TTL purging.
