---
name: business-craftsman
description: >-
  Practical business and product guidance focused on value validation,
  portfolio prioritization, risk containment, delivery readiness, and outcome realization.
license: MIT
---

# Business Craftsman: Business, Product & Project Operations

## Preamble & Core Business Principles

> **A business initiative exists to produce measurable value or materially reduce enterprise risk. Activity is not value. Delivery is not value. A completed project is not automatically a successful project.**  
> **Customer reality beats internal opinion. Economics beats enthusiasm. Reversibility beats blind commitment.**  
> **Stopping a value-destroying initiative early is a successful management decision, not a failure of will.**

---

## 1. The Business Decision Hierarchy

When strategic priorities, resource demands, or stakeholder interests conflict, decisions must be resolved in accordance with this explicit hierarchy:

```text
 1. Legal, Regulatory & Ethical Obligations
 2. Business Survival & Existential Risk Mitigation
 3. Customer Value & Core Problem Resolution
 4. Revenue, Margin & Free Cash Flow Impact
 5. Strategic Positioning & Competitive Moats
 6. Downstream Risk Reduction
 7. Capital Efficiency & Return on Invested Capital (ROIC)
 8. Organizational Capacity & Sustainable Focus
 9. Operational Durability & Long-Term Maintainability
10. Speed of Learning & Hypothesis Validation
11. Future Optionality & Flexibility
12. Internal Convenience
13. Vanity Metrics & Political Accommodation
```

> [!IMPORTANT]
> **Decision Framework Rule**: This hierarchy is a disciplined reasoning framework, not a rigid mechanical formula. Every major investment must document which specific hierarchy tiers justify its funding, and why lower tiers were subordinated.

---

## 2. The 12 Constitutional Business Laws

### 1. Outcomes Over Outputs & Activity
Never measure progress by features delivered, tickets closed, documents drafted, or meetings held. The only valid measure of progress is verified customer outcome, revenue/margin improvement, or proven risk reduction.

### 2. Evidence Before Commitment (Hypothesis Falsification)
Strategic bets and product initiatives start as unverified hypotheses. Invest minimally to test the riskiest assumption first. Distinguish strictly between **Fact**, **Assumption**, **Hypothesis**, **Decision**, and **Irreversible Commitment**.

### 3. Economic Rationality & Opportunity Cost
Every dollar and engineer-hour allocated to Initiative $A$ is permanently denied to Initiatives $B, C,$ and $D$. Initiatives must prove their Expected Value ($\text{EV}$), Total Cost of Ownership ($\text{TCO}$), Cost of Delay ($\text{CoD}$), and Payback Period against the opportunity cost of doing nothing.

### 4. Single Accountable Outcome Ownership
Every initiative, product, project, and risk must have exactly one named Accountable Owner with decision authority. Collective ownership is zero ownership. Escalation must never be used as a mechanism to transfer ownership away from the accountable lead.

### 5. Reversibility & Option Value Preservation
Classify all strategic decisions into **Two-Way Doors (Reversible)** vs **One-Way Doors (Irreversible)**. Reversible decisions must be made rapidly with lightweight discovery. Irreversible commitments (e.g. multi-year vendor lock-in, non-standard architectures, physical contracts) demand disproportionate evidence and an explicit exit strategy.

### 6. Stop-Loss Discipline & Sunk-Cost Immunity
Past expenditure of capital, time, and emotional energy is irrelevant to future funding decisions. At every portfolio review, ask: *"Knowing what we know today, would we fund this initiative from scratch?"* If the answer is no, the initiative must be paused, pivoted, or killed immediately.

### 7. Finite Capacity & Work-In-Progress (WIP) Limits
Organizational capacity (engineering, product, management attention, cash) is strictly finite. Over-allocating teams past 80% sustainable utilization destroys delivery throughput and hides risk. To start a new initiative, the organization must complete, pause, or kill an active initiative.

### 8. Customer Problem Discovery Over Solution Passion
Fall in love with the customer's problem, not the internal solution. Validate problem frequency, severity, and willingness to pay before building software. A feature requested by a vocal customer is a data point, not an automatic product roadmap commitment.

### 9. Strict Scope Governance & Anti-Creep Discipline
Every project must maintain an explicit list of Non-Goals alongside Scope. Any proposed change request must evaluate impact on value, timeline, cost, dependencies, and opportunity cost. "It's just a small change" is strictly prohibited without formal impact analysis.

### 10. Buy vs Build & Vendor Risk Governance
Do not build what can be commoditized. Do not buy what forms your core strategic competitive moat. Every third-party vendor relationship must define an architectural and operational exit strategy, data ownership guarantees, and business continuity contingencies.

### 11. Honest Delivery Forecasting (Range-Based Confidence)
Reject fake precision. Single-date delivery promises on complex, uncertain initiatives are delusions. Express delivery timelines using probabilistic ranges ($P_{50}, P_{80}, P_{90}$) based on empirical cycle times, dependency risks, and historical throughput.

### 12. Mandatory Value Realization & Blameless Learning
A project is not complete at launch. An initiative is complete only after the post-launch **Value Realization Review** validates that the intended business outcome was achieved, customer behavior changed, and operational stability held for 30+ days.

---

## 3. Constitutional Prohibitions

1. **PROHIBITED**: Feature Factory behavior—shipping endless feature backlogs without verifying customer adoption, retention, or business impact.
2. **PROHIBITED**: Sunk-Cost continuation—justifying ongoing funding because "we have already invested \$1M and 6 months."
3. **PROHIBITED**: Roadmap Theater—treating long-term multi-quarter Gantt charts as binding commitments rather than evolving strategic hypotheses.
4. **PROHIBITED**: Status Theater—reporting project status as "GREEN" when critical path dependencies, capacity deficits, or unresolved P0 risks are concealed.
5. **PROHIBITED**: Vanity Metrics—celebrating page views, registered accounts, code commits, or velocity story points while revenue, retention, and margins degrade.
6. **PROHIBITED**: HiPPO Prioritization—allocating millions in capital solely on the basis of the "Highest Paid Person's Opinion" without evidence or risk evaluation.
7. **PROHIBITED**: Meeting-as-Work Culture—substituting endless alignment meetings and status check-ins for accountable execution.
8. **PROHIBITED**: Artificial Urgency & Hero Culture—substituting unsustainable crunch and emergency heroics for competent capacity planning and risk management.
9. **PROHIBITED**: Unbounded Scope Creep—silently inflating project deliverables during execution without adjusting budget, schedule, or trade-offs.
10. **PROHIBITED**: Launch-and-Forget—disbanding project teams immediately upon deployment without measuring value realization and post-launch stability.

---

## 4. Business No-Go Conditions (Automatic Veto)

An initiative, project, or release candidate is subjected to an **AUTOMATIC EXECUTIVE VETO / HALT** if ANY of the following conditions exist:

```text
❌ CRITICAL NO-GO CONDITIONS (AUTOMATIC PROJECT HALT)
- [ ] No single named Accountable Outcome Owner.
- [ ] Absence of a quantified, measurable business problem and target success metric.
- [ ] Negative unit economics or negative lifecycle ROI without an explicit, approved strategic loss-leader rationale.
- [ ] Unbounded legal, regulatory, compliance, or security liability exposure.
- [ ] Hard critical external dependency without a documented, verified contingency or fallback plan.
- [ ] Material risk classified as P0 Existential with zero approved mitigation strategy.
- [ ] Irreversible capital commitment lacking a documented and verified exit/unwind plan.
- [ ] Team allocated past 100% capacity without deprioritizing active committed work.
- [ ] Continued funding requested solely on the basis of past sunk costs.
- [ ] Scope materially exceeds the validated customer requirement without approved change control.
```

---

## 5. Governance Gate Lifecycle

Every significant business investment must progress through 10 evidence-based decision gates:

```text
GATE 0: Idea & Problem Framing       --> Problem severity, target actors, and non-goals defined.
GATE 1: Problem & Market Validated   --> Customer discovery interviews, data evidence, willingness to pay.
GATE 2: Business Case & Economics    --> TCO, expected return, cost of delay, and alternatives evaluated.
GATE 3: Funding & Portfolio Approval --> Priority scored against portfolio capacity; single owner named.
GATE 4: Delivery & Scope Readiness   --> Milestones, dependencies, probabilistic forecast, and DoD defined.
GATE 5: Execution & Milestone Check  --> Active sprint delivery, continuous risk register updates, WIP bounded.
GATE 6: Launch & Operational Gate    --> Runbooks live, support trained, rollback plan tested, canary ready.
GATE 7: Adoption & Early Telemetry   --> Activation, user onboarding, error rate monitoring (Day 1–30).
GATE 8: Value Realization Review     --> Revenue, margin, retention, and business case targets audited (Day 60–90).
GATE 9: Scale / Pivot / Sunset       --> Final disposition: invest further, maintain as stable, or decommission.
```

---

## 6. Business Operating Scorecard

Evaluate initiatives across all operational dimensions to determine funding and execution disposition:

| Operational Dimension | Evidence-Based Evaluation Standard | Rating |
| :--- | :--- | :--- |
| **1. Strategic Alignment** | Directly reinforces top-3 company strategic objectives and competitive moats. | `[PASS / FAIL]` |
| **2. Problem & Customer Value**| Solves a validated, high-frequency, high-severity problem for a defined user segment. | `[PASS / FAIL]` |
| **3. Financial Economics** | Positive risk-adjusted ROI, bounded TCO, verified payback period, and acceptable CoD. | `[PASS / FAIL]` |
| **4. Scope & Complexity** | Minimal viable scope clearly separated from non-goals; zero gold-plating. | `[PASS / FAIL]` |
| **5. Capacity & Feasibility** | Staffed within sustainable capacity limits without starving other critical initiatives. | `[PASS / FAIL]` |
| **6. Risk & Blast Radius** | All P0/P1 risks identified with active owners, mitigation triggers, and contingencies. | `[PASS / FAIL]` |
| **7. Dependencies & Vendors** | Third-party dependencies minimized with SLAs, exit strategies, and fallbacks. | `[PASS / FAIL]` |
| **8. Delivery Forecast** | Probabilistic timeline ranges ($P_{80}$) based on empirical data, not wishful dates. | `[PASS / FAIL]` |
| **9. Reversibility & Exit** | Clear stop-loss triggers defined; cost of reversal documented and bounded. | `[PASS / FAIL]` |
| **10. Value Realization Plan** | Measurable leading/lagging KPIs instrumented to audit real outcome post-launch. | `[PASS / FAIL]` |

```text
FINAL EVALUATION DISPOSITION:
[ ] PASS        — All 10 dimensions verified with evidence. Initiative funded / approved.
[ ] CONDITIONAL — Minor gaps in 1-2 dimensions with designated owner and 7-day remediation plan.
[ ] PAUSE       — Blocked on external dependency, missing customer evidence, or capacity deficit.
[ ] ESCALATE    — Unresolved strategic conflict or resource contention requiring executive decision.
[ ] KILL        — Fails economic viability, unmitigated existential risk, or negative discovery outcome.
```

---

## 7. The Anti-Bureaucracy Law

> **Governance exists exclusively to improve decision quality, contain material risk, and allocate scarce capital. It does NOT exist to demonstrate that governance exists.**  
> - Every document, meeting, scorecard, and approval gate must pass this test: *"Does this artifact directly improve an investment decision, reduce a material risk, or enforce critical accountability?"*  
> - If the answer is NO: **Eliminate the artifact immediately.**

---

## Status Declaration

```text
BUSINESS-CRAFTSMAN
VERSION: 1.0
STATUS: RATIFIED & FROZEN
```

---

## License

This skill is open source under the [MIT License](LICENSE).
