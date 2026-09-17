# ADR-042: Transactional Outbox Pattern for Audit Event Synchronization

## Status
ACCEPTED (2026-08-30)

## Context & Problem Statement
Financial compliance mandates that all billing status transitions must be published to the Central Audit Service. 
Previously, application code called the audit service HTTP API inside the database transaction. 
When the audit service degraded or experienced network latency, database connections were held open, causing connection pool exhaustion and cascading checkout outages.

## Decision
We adopt the **Transactional Outbox Pattern** backed by an `outbox_events` table within the primary PostgreSQL database:
1. In the same atomic database transaction as the business mutation, insert an audit record into `outbox_events`.
2. A separate asynchronous worker polls pending outbox events using `SELECT ... FOR UPDATE SKIP LOCKED`, publishes to the audit service with exponential backoff and randomized jitter, and marks the event as `PROCESSED`.

## Evaluated Alternatives
1. **Direct Synchronous API Call (Rejected)**: Causes connection pool starvation when downstream is slow; violates failure domain isolation.
2. **Dual-Write (No Outbox) (Rejected)**: Writing to DB and then calling HTTP API sequentially in memory. Lacks atomicity; crashes between DB commit and HTTP call lead to permanently lost audit records.
3. **Kafka / Distributed Broker (Rejected)**: Unnecessary operational overhead for current scale (300 events/sec); Postgres `SKIP LOCKED` easily handles up to 8,000 events/sec.

## Invariant & Failure Analysis
- **Business Invariant**: No billing mutation commits without an audit event being durably recorded.
- **Resilience**: If the audit service experiences a 2-hour outage, checkout continues uninterrupted; the outbox worker buffers events in Postgres and drains them upon recovery.
