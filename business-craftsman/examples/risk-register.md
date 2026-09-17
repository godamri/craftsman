# Project Risk Register: Project Magellan (Multi-Currency Rails)

## Active Risk Log

| Risk ID | Description & Cause | Category | Prob (1-5) | Imp (1-5) | Exposure ($P \times I$) | Early Warning Indicator | Mitigation Strategy | Contingency Plan | Owner | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **RSK-01** | European banking partner API latency spikes during London market close (> 15s). | Technology | 3 | 4 | **12 (P1)** | Webhook response time > 3s on sandbox telemetry. | Implement asynchronous outbox polling with 30s timeout and circuit breaker. | Fall back to batch file settlement (EOD). | Staff Architect | **Mitigated** |
| **RSK-02** | Delayed UK regulatory approval for virtual IBAN safeguarding accounts. | Regulatory | 2 | 5 | **10 (P1)** | FCA correspondence delay > 14 days. | Retain partner bank's existing umbrella license rather than direct entity filing. | Launch EUR first; delay GBP launch by 4 weeks. | General Counsel | **Active** |
| **RSK-03** | Concurrent double-debit race condition on rapid customer retry. | Business | 2 | 5 | **10 (P1)** | Duplicate idempotency key queries in staging tests. | Enforce database `CHECK (balance >= 0)` and unique constraint on `idempotency_key`. | Automated ledger reversal background worker. | Lead DB Eng | **Closed** |
| **RSK-04** | Client ERP system rejects new multi-currency webhook schema. | Integration | 4 | 2 | **8 (P2)** | Schema validation failure in beta partner sandbox. | Versioned webhooks (`v2026-10`) with backward-compatible JSON payloads. | Customer support manual CSV export fallback. | Lead PM | **Active** |
