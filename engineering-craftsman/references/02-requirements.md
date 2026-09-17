# Requirements Engineering & Verification Seams

> **Core Principle**: Ambiguous requirements lead directly to defective architectures. Every critical requirement must have an owner, a verification seam, and an explicit blast-radius classification.

---

## 1. The Requirements Taxonomy

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ 1. FUNCTIONAL REQUIREMENTS                                                             │
│    What the system does (e.g. "Calculate sales tax based on billing address").         │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 2. NON-FUNCTIONAL REQUIREMENTS & SLOs                                                  │
│    How the system performs (e.g. "p99 latency < 150ms under 5,000 req/sec").           │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 3. BUSINESS RULES & INVARIANTS                                                         │
│    Rules that must never be broken (e.g. "Account balance cannot drop below zero").     │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 4. SECURITY & COMPLIANCE REQUIREMENTS                                                  │
│    Access control, data residency, PII redaction, encryption, and auditability.        │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 5. OPERATIONAL & RECOVERY REQUIREMENTS                                                 │
│    Cold-start time, non-blocking rolling deployments, backup frequency, and RTO/RPO.   │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Requirement Verification Seams

Every critical requirement specification must define its verification method before code is written:

```markdown
### REQ-042: Idempotent Payment Capture
- **Statement**: Retrying a payment capture with the same idempotency key must not charge the customer twice.
- **Owner**: Billing Squad (Lead Engineer)
- **Verification Method**: Automated integration test simulating network drop and duplicate webhook replay.
- **Failure Impact**: P0 Financial Defect / Customer Overcharge / Regulatory Non-Compliance.
```
