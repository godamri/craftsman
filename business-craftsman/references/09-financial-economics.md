# Financial Economics & Total Cost of Ownership

> **Core Principle**: Cheap to build is not necessarily cheap to own. Fast to launch is not necessarily fast to value. Economic viability is an inescapable constraint.

---

## 1. The Total Cost of Ownership (TCO) Equation

$$\text{TCO} = \text{Initial CAPEX (Build)} + \sum_{t=1}^{N} \left( \text{Cloud OPEX} + \text{SaaS Licenses} + \text{Maintenance Engineering} + \text{Support Overhead} \right) + \text{Exit Cost}$$

```text
ECONOMIC ANALYSIS CHECKLIST:
1. Payback Period      : How many months until cumulative net gross profit exceeds total build cost? (Target: < 12 months).
2. Cost of Delay (CoD) : How much gross revenue or market share is lost for every week delivery is delayed?
3. Unit Economics      : Is the Gross Margin > 70% after accounting for all compute, third-party APIs, and payment fees?
4. LTV to CAC Ratio    : Is Customer Lifetime Value (LTV) at least 3x the Customer Acquisition Cost (CAC)?
```

---

## 2. Cost of Delay (CoD) Prioritization (WSJF)

When prioritizing competing initiatives in a portfolio, use **Weighted Shortest Job First (WSJF)**:

$$\text{WSJF} = \frac{\text{Cost of Delay}}{\text{Job Size / Duration}}$$

$$\text{Cost of Delay} = \text{User-Business Value} + \text{Time Criticality} + \text{Risk Reduction / Opportunity Enablement}$$

*Initiatives with high Cost of Delay and short duration deliver the highest return on invested capacity.*
