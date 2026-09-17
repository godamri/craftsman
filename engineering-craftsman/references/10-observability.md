# Observability & Causal Telemetry

> **Core Principle**: Observability is not merely collecting logs; it is the capability to understand and reconstruct any internal system state and failure from its external telemetry.

---

## 1. The 4 Golden Signals Framework

Every production service must expose continuous telemetry for:

1. **Latency**: Duration of requests (p50, p95, p99 histograms), differentiating successful vs failing requests.
2. **Traffic**: Request rate (requests/sec, messages/sec, active connections).
3. **Errors**: Explicit error rates (HTTP 5xx, gRPC error codes, unhandled exceptions, DLQ routings).
4. **Saturation**: Fraction of critical resource capacity consumed (CPU, memory, DB pool, thread pool, disk I/O).

---

## 2. Contextual Structured Logging Schema

```json
{
  "timestamp": "2026-08-30T00:25:00Z",
  "level": "ERROR",
  "message": "Payment authorization rejected by provider",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "correlation_id": "req_pay_89102",
  "service": "payment-gateway",
  "version": "v2.4.1",
  "tenant_id": "tenant_enterprise_a",
  "actor_id": "usr_789",
  "error_code": "PROVIDER_TIMEOUT",
  "latency_ms": 5002,
  "attempt": 2
}
```
