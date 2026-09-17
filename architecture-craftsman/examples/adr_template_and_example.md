# ADR-001: Adoption of Transactional Outbox for Payment Event Publishing

## Status
ACCEPTED (2026-08-28)

## Context & Problem Statement
Currently, the Payment Service directly calls an external Kafka broker over HTTP/TCP inside the database transaction when an order is created. 
If Kafka is slow or unavailable, database connections are held open, causing connection pool exhaustion. 
If the process crashes after the database commits but before Kafka acknowledges the message, external downstream services never receive the event (lost work).

## Decision
We adopt the **Transactional Outbox Pattern** with a dedicated asynchronous background publisher:
1. When a payment transaction commits, an outbox event record is inserted into the `outbox_events` table within the same atomic PostgreSQL transaction.
2. A separate background worker reads pending outbox events using `SELECT ... FOR UPDATE SKIP LOCKED`, publishes to Kafka with retry/backoff, and marks the event as `PROCESSED`.

## Evaluated Alternatives
1. **Direct Dual-Write (Rejected)**: Writing to PostgreSQL and Kafka sequentially in application code without an outbox table.
   - *Reason for rejection*: Lacks atomicity. If process crashes between DB commit and Kafka publish, events are permanently lost.
2. **Distributed 2PC / XA Transactions (Rejected)**: Using two-phase commit between PostgreSQL and Kafka.
   - *Reason for rejection*: Unacceptable latency, complex failure modes, and poor broker support.

## Consequences & Trade-Offs
- **Positive**: 
  - Zero connection pool blocking by external network latency.
  - Guarantees at-least-once event publication even across process crashes.
- **Negative / Costs**: 
  - Additional database storage for the outbox table and slight eventual consistency delay (typically < 100ms).
  - Downstream consumers must implement idempotent inbox deduplication.

## Invariants & Failure Analysis
- **Invariant**: No payment event is published unless the database transaction durably commits.
- **Crash Recovery**: If the outbox worker dies midway, events remain `PENDING` and are claimed by another worker instance.
