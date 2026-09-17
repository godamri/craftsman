# Project Charter: Multi-Currency Payment Rails (Project Magellan)

## 1. Project Metadata
- **Project Name**: Project Magellan (Multi-Currency Rails)
- **Accountable Executive Sponsor**: Chief Product Officer
- **Project Manager**: Senior Technical Program Manager (Billing)
- **Engineering Lead**: Staff Systems Architect
- **Product Manager**: Lead PM (B2B Payments)
- **Approved Budget**: \$135,000 CAPEX / 3 Engineers for 6 weeks
- **Target Launch Window**: $P_{80}$ Forecast: October 15, 2026

---

## 2. In-Scope Deliverables & Explicit Non-Goals

```text
IN-SCOPE DELIVERABLES:
1. Virtual IBAN generation for EUR and GBP customer accounts.
2. Ingestion and idempotent ledger settlement for inbound SEPA and Faster Payments.
3. Automated webhook dispatch to customer ERP systems upon payment confirmation.
4. Finance admin dashboard for exception management and reconciliation.

EXPLICIT NON-GOALS (STRICTLY PROHIBITED):
- Credit card interchange processing (deferred to Phase 2).
- Crypto/stablecoin settlements.
- Offline cash/check collection.
- Consumer-facing mobile app integration.
```

---

## 3. Critical Path Milestones

| Milestone | Target ($P_{80}$) | Exit Criteria |
| :--- | :--- | :--- |
| **M1: Banking Partner Sandbox API** | Aug 15, 2026 | Test transfers completed in sandbox with zero dropped webhooks. |
| **M2: Double-Entry Ledger Core** | Sep 01, 2026 | Invariant race test passing (100 parallel concurrent debits). |
| **M3: Staging Integration Drill** | Sep 15, 2026 | End-to-end ERP webhook test suite passing. |
| **M4: Beta Pilot Launch (10 Clients)**| Oct 01, 2026 | Live pilot processing real funds with zero reconciliation errors. |
| **M5: General Availability (GA)** | Oct 15, 2026 | 100% self-serve rollout enabled; runbooks published. |

---

## 4. DACI Accountability Matrix

| Decision Area | Driver (D) | Approver (A) | Contributors (C) | Informed (I) |
| :--- | :--- | :--- | :--- | :--- |
| Scope & Feature Trade-Offs | Product Manager | CPO | Engineering Lead | Sales / Support |
| Architecture & DB Schema | Engineering Lead | Principal Architect | Backend Engineers | Security / DBA |
| Schedule & Resource Allocation| Project Manager | VP Engineering | Squad Leads | All Stakeholders |
| Banking Vendor Contracts | Finance Director | CFO / General Counsel | PM / Security | Executive Team |
