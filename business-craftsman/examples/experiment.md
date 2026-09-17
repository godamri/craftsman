# Experiment Brief & Learning Memo: Self-Serve IBAN Activation (EXP-044)

## 1. Hypothesis & Objective
- **Hypothesis**: Allowing enterprise clients to generate EUR virtual IBANs directly via self-serve dashboard (vs requiring customer support ticket) will reduce customer time-to-first-payment from 4 days to < 2 hours and increase 30-day activation by >= 25%.
- **Baseline**: Current assisted onboarding activation rate = 38%; time-to-first-payment = 96 hours.

---

## 2. Experiment Setup & Sample Bounds
- **Sample Size**: 200 newly onboarded international enterprise accounts over 21 days.
- **Control (100 Accounts)**: Standard assisted onboarding (support agent provisions IBAN via ticket).
- **Treatment (100 Accounts)**: Self-serve instant 1-click IBAN provisioning widget.
- **Primary Metric**: % of accounts completing first payment within 7 days.
- **Guardrail Metric**: Fraud / compliance false-positive rate must stay < 0.1%.

---

## 3. Results & Empirical Decision

| Metric | Control Group | Treatment Group | Lift | Statistical Significance |
| :--- | :--- | :--- | :--- | :--- |
| **7-Day Activation Rate** | 39.0% | **62.0%** | **+58.9%** | $p = 0.002$ ($p < 0.01$) |
| **Time-to-First-Payment** | 88 hours | **1.8 hours** | **-97.9%** | $p < 0.001$ |
| **Compliance Flag Rate** | 0.08% | **0.09%** | Nominal | Within guardrail limit |

- **Decision**: **SCALE IMMEDIATELY TO 100% OF ENTERPRISE ACCOUNTS**.
