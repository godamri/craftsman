# Post-Project Review (PPR): Project Magellan Delivery Retrospective

## 1. Project Overview & Final Metrics
- **Duration**: 7 weeks (Forecast $P_{80}$: 6 weeks; Variance: +1 week due to UK FCA regulatory shift).
- **Cost**: \$128,500 CAPEX (Approved budget: \$135,000).
- **Final Outcome**: Successful EUR launch; GBP launched 3 weeks later in Phase 1.1.

---

## 2. Systemic Learnings (What Worked vs What Failed)

```text
WHAT WORKED (REINFORCE ACROSS ORGANIZATION):
1. Upfront DACI Matrix: Single named leads eliminated cross-squad decision paralysis.
2. Invariant-First Testing: Concurrency barrier race tests caught 2 critical double-debit bugs before code reached staging.
3. Decoupling Currencies: Phasing EUR ahead of GBP protected $850k in European revenue from being blocked by UK regulatory delays.

WHAT FAILED (SYSTEMIC DEFECTS TO FIX):
1. Regulatory Dependency Lead Time: Underestimated FCA response latency by 3 weeks.
2. Sales Communication Gap: Sales team initially promised custom PDF letters to Client Alpha without consulting product change control.

CORRECTIVE ACTIONS INSTITUTED:
- Add 30-day regulatory buffer to all future banking compliance forecasts.
- Institute mandatory 1-page Change Request (CR) workflow for all sales custom requests.
```
