# Event-Driven Systems & Queue Correctness

Event-driven architectures must be engineered for duplicate delivery, out-of-order execution, and poison payloads.

---

## 1. Message Acknowledgement & Visibility Timeouts

1. **Acknowledge Only After Persistence**: Do not acknowledge (`ack`) a message before the processing results have been durably committed to the database.
2. **Extend Visibility on Long Tasks**: If message processing exceeds visibility timeout, extend the heartbeat lease to prevent sibling workers from picking up the same message concurrently.

---

## 2. Poison Message Isolation (DLQ)

If a message consistently causes a panic or unrecoverable error:
1. Track retry counts in message metadata headers.
2. If `retry_count >= max_retries`, publish to Dead-Letter Queue (DLQ) and acknowledge the original message to unblock consumer throughput.
