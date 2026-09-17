# Failure Domains & Blast Radius Containment

> **Core Principle**: System architecture must ensure that the failure of an optional dependency or background subsystem cannot crash core business functionality.

---

## 1. Bulkhead Architecture & Isolation

Partition resources (threads, connections, memory, queues) so that one failing subsystem does not consume shared resources:

```text
[ Incoming Web Traffic ]
        │
        ├──> [ Critical Path Pool ] ───> Core Database (Reserved Connections)
        │
        └──> [ Background Worker Pool ] ──> Async Queue (Isolated Connections)
```

If the background queue backs up or third-party email sending hangs, the critical payment and login paths remain unaffected.

---

## 2. Graceful Degradation & Fallbacks

When external dependencies (recommendation engine, analytics, review service) become unavailable:
1. **Circuit Breaker Opens**: Fast-fail requests to avoid tying up HTTP client threads.
2. **Fallback Value**: Return cached static defaults or omit non-essential UI widgets.
3. **Log & Alert**: Record the partial degradation without escalating it to a total system outage.
