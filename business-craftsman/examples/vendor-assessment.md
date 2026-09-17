# Vendor Risk Assessment & Exit Plan: Banking-as-a-Service Partner (RailsBank)

## 1. Vendor Profile & Scope
- **Vendor**: RailsBank Ltd (UK / EU Banking Partner)
- **Scope**: Providing virtual IBAN issuance and SEPA/Faster Payments scheme connectivity.
- **Contract Value**: \$18,000/year minimum commit + 0.15% per settlement volume.

---

## 2. Risk & Resilience Evaluation

```text
EVALUATION CHECKLIST:
[x] Security & Compliance : SOC2 Type II and ISO 27001 verified; pen-test report reviewed.
[x] Data Ownership        : Contract Article 8 guarantees 100% customer data portability on demand.
[x] Availability SLA      : 99.95% API uptime with financial penalty credits for downtime > 20 mins/mo.
[x] Bankruptcy Risk       : Funds safeguarded in Tier-1 central clearing accounts (Barclays/BNP).
```

---

## 3. Mandatory Vendor Exit Strategy
If RailsBank suffers persistent outages, undergoes regulatory suspension, or increases pricing > 20%:
1. **Abstraction Seam**: All banking calls flow through internal domain port `VirtualAccountProvider`.
2. **Pre-Integrated Fallback**: Maintain warm secondary contract with Modulr API.
3. **Migration RTO**: Maximum 5 business days to redirect virtual IBAN generation to secondary partner with zero customer database schema changes.
