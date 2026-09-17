# Business Case: Automated Multi-Currency Invoice Settlement

## 1. Executive Summary
- **Initiative**: Automated multi-currency checkout & virtual accounts for enterprise B2B customers.
- **Accountable Owner**: VP of Product (Fintech)
- **Requested Capital**: \$135,000 CAPEX (1.5 engineer-months) + \$480/month OPEX.
- **Projected Value**: \$1.2M annual reclaimed revenue + \$60k/year operational savings.
- **Payback Period**: 1.4 months (Net ROI: 780% in Year 1).

---

## 2. Problem Statement & Customer Evidence
- **Pain Point**: 4.2% of cross-border invoice settlements fail due to manual bank transfer delays and lack of local payment rails in Europe and UK.
- **Customer Discovery Data**: 18 of top 25 enterprise clients confirmed they would expand transaction volume by 20% if local EUR/GBP virtual accounts were available.

---

## 3. Financial Economics & TCO Analysis

| Cost Category | Year 1 Estimated Spend | Year 2 Estimated Spend |
| :--- | :--- | :--- |
| **Engineering Build (CAPEX)** | \$135,000 (3 engineers $\times$ 6 weeks) | \$0 |
| **Cloud Hosting & Database (OPEX)**| \$5,760 (\$480/month) | \$6,500 |
| **Banking API Partner Fees** | \$18,000 (0.15% per tx) | \$24,000 |
| **Ongoing Maintenance (10% FTE)** | \$18,000 | \$18,000 |
| **Total Cost of Ownership (TCO)** | **\$176,760** | **\$48,500** |

$$\text{Net Annual Benefit (Year 1)} = \$1,260,000 - \$176,760 = \$1,083,240$$

---

## 4. Evaluated Alternatives

1. **Do Nothing (Rejected)**: Continues \$1.2M annual revenue leakage and strains finance headcount.
2. **Outsource to Full SaaS Gateway (Rejected)**: Charges 1.8% transaction fee (\$216k/year), eroding gross margins.
3. **Build via Modular Banking API Partner (Recommended)**: Hybrid approach; builds core UI/ledger in-house, uses licensed banking APIs for rails (0.15% fee).

---

## 5. Stop-Loss & Kill Thresholds
- If beta conversion rate < 85% of target after 45 days, halt project and pivot to third-party hosted checkout.
