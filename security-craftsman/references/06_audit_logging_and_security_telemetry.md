# Security Audit Logging & Telemetry

---

## 1. Security Event Schema

All security-significant events must produce structured, append-only audit entries:

```json
{
  "timestamp": "2026-08-28T17:35:00Z",
  "event_type": "AUTH_LOGIN_FAILED",
  "actor_id": "usr_987",
  "actor_ip": "203.0.113.45",
  "resource": "sessions",
  "outcome": "DENIED",
  "reason": "INVALID_CREDENTIALS",
  "trace_id": "trace_abc123"
}
```

### Sensitive Data Redaction:
Never log passwords, API tokens, credit card numbers, or encryption keys in audit logs.
