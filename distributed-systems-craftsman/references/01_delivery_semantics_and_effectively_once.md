# Delivery Semantics & Effectively-Once Outcomes

> **Core Principle**: In distributed networks, exactly-once delivery is an impossible transport guarantee. Engineering systems must achieve **effectively-once business outcomes** through at-least-once transport and idempotent processing.

---

## 1. The Three Transport Delivery Models

1. **At-Most-Once**:
   - The producer fires a message without waiting for an acknowledgement or retrying.
   - *Failure Mode*: Messages are lost if network drops or consumer crashes.
   - *Use Case*: Non-critical telemetry, metrics, loss-tolerant IoT sensor readings.
2. **At-Least-Once**:
   - The producer retries until an explicit acknowledgement is received.
   - *Failure Mode*: Duplicate, delayed, or out-of-order messages.
   - *Use Case*: Payments, order processing, state synchronization.
3. **Effectively-Once Business Outcomes**:
   - **At-Least-Once Transport** + **Idempotent Inbox Deduplication** = Exact single business outcome.

---

## 2. Why "Exactly-Once" is a Dangerous Overclaim

Even if a message broker (e.g. Kafka transactions) guarantees that a message is written to a topic once, if the consumer process crashes *after* mutating a database but *before* committing the consumer offset, the message is redelivered upon restart.

Therefore, the consumer **must always** be designed to handle duplicate messages.
