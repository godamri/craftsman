# Operability & Production Lifecycle Governance

> **Core Principle**: A system is only operable if an on-call engineer who did not write the code can safely triage, restart, scale, and recover it at 3:00 AM using standard documentation and telemetry.

---

## 1. The Production Operability Contract

Every service deployed to production must satisfy:

1. **Startup Validation (Fail Fast)**: Validate all environment variables, secrets, database migrations, and network connectivity at startup. If configuration is invalid, abort immediately with clear fatal log messages.
2. **Health vs Readiness Probes**:
   - `Liveness / Health`: Is the process running and responsive? (Failing triggers container restart).
   - `Readiness`: Is the service initialized and capable of accepting traffic? (Failing temporarily pulls node from load balancer).
3. **Graceful Shutdown**: Intercept `SIGTERM` / `SIGINT`, close listeners, finish in-flight requests within a bounded window (e.g. 15–30s), flush buffers, and exit cleanly.
4. **Actionable Alerts**: Every alert page must link directly to a verified Runbook containing:
   - What the alert means and business impact.
   - Initial triage commands and diagnostic queries.
   - Immediate mitigation / rollback steps.
   - Escalation paths.
