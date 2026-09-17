# Buy vs Build Analysis: International Sanctions & PEP Screening Engine

## 1. Context & Business Need
To process European B2B payments legally, Project Magellan must screen all transaction counterparties against OFAC, EU, and UN sanctions and Politically Exposed Persons (PEP) lists in real time (< 200ms latency).

---

## 2. Evaluation Matrix: Build vs Buy

| Evaluation Criteria | Option A: Build In-House Scraping Engine | Option B: Integrate Commercial Sanctions API (ComplyAdvantage) |
| :--- | :--- | :--- |
| **Initial Build Cost** | \$180,000 (3 Engineers $\times$ 3 months) | \$25,000 (1 Engineer $\times$ 3 weeks integration) |
| **Ongoing Annual Cost** | \$90,000 (Sanctions list data feeds + maintenance) | \$42,000/year (SaaS API subscription) |
| **Regulatory Risk** | **High**: In-house scraper missing updated aliases leads to \$5M+ fines. | **Low**: Vendor indemnifies list accuracy and maintains 24/7 audit trail. |
| **Time-to-Market** | 16 weeks (Blocks Project Magellan) | 3 weeks (Meets October launch target) |
| **Strategic Differentiation**| **Zero**: Sanctions screening is a pure regulatory commodity. | **Zero**: Commodity utility. |

---

## 3. Decision & Exit Governance
- **Recommendation**: **BUY Option B (Commercial Sanctions API)**.
- **Exit Strategy**: API client wrapped in domain interface port (`SanctionsChecker`). If vendor fails SLA, secondary fallback vendor (LexisNexis) can be swapped in via config change in < 48 hours.
