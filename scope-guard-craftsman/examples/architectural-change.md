# Example: Architectural Change (Passing the Gate)

## User Request
> "Order confirmation emails sometimes time out during checkout, failing the entire payment. Decouple email sending so checkout succeeds even if the email provider is slow."

---

## The New Architecture Gate Evaluation

Before proposing new architecture, the agent establishes:

1. **Existing Path**: `OrderService.checkout()` calls `EmailClient.send()` synchronously within the checkout flow.
2. **Deficiency**: Wrapping `EmailClient.send()` in a try/catch or short timeout either loses emails silently or still risks blocking the thread during network stalls. Synchronous external network I/O inside a checkout transaction fundamentally violates failure domain isolation.
3. **Simpler Alternatives Considered**:
   - *In-memory background thread*: Lost on process crash or restart (Unacceptable reliability).
   - *Full message broker (Kafka/RabbitMQ)*: Massive infrastructure overhead for simple transactional emails (Overengineering).
4. **Justification for New Architecture**:
   - A persistent asynchronous queue boundary is necessary to prevent third-party network latency from aborting database transactions.
   - In this example, the existing PostgreSQL database is the available durable boundary, so a **Transactional Outbox table** polled by a lightweight worker is the minimal justified solution. (The architectural decision directly depends on existing repository capabilities; if an active message broker were already present, composing with it would be preferred).

---

## ✅ Scope Guard Craftsman Plan

```markdown
Plan: Decouple order confirmation emails from checkout using a Transactional Outbox pattern backed by the existing PostgreSQL database; no external message broker or queue cluster will be introduced.

### What will change
- Add an `outbox_events` table via migration to store pending email jobs atomically with the order commit.
- In `OrderService.checkout()`, replace direct `EmailClient.send()` with an insert into `outbox_events` within the existing database transaction.
- Add a lightweight background worker `EmailOutboxWorker` that polls pending events using `SELECT ... FOR UPDATE SKIP LOCKED` and invokes `EmailClient`.

### What will not change
- Checkout API contract, payment processing logic, and user-facing responses remain identical.
- `EmailClient` implementation and email templates remain unchanged.

### Existing capabilities reused
- Existing PostgreSQL database connection pool.
- Existing `EmailClient`.
- Existing transaction block in `OrderService`.

### Affected Files
- `migrations/20260917_create_outbox_events.sql` (NEW)
- `src/services/OrderService.ts` (MODIFIED)
- `src/workers/EmailOutboxWorker.ts` (NEW)

### Verification
- Simulate email provider timeout (inject a 10s delay).
- Verify checkout completes and returns HTTP 200 in < 200ms.
- Verify pending event is committed in `outbox_events`.
- Verify background worker processes the event and delivers the email when provider recovers.
```
