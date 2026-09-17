# Scientific Experimentation & Hypothesis Validation

> **Core Principle**: An experiment without an upfront decision threshold is post-hoc rationalization. Define success and failure metrics before exposing users to treatments.

---

## 1. The Experiment Brief Structure

Every product hypothesis test or A/B experiment must document:

```markdown
### EXP-012: Simplified 1-Click Checkout Conversion
- **Hypothesis**: Replacing multi-step form with saved credit card tokenization will increase mobile conversion by >= 15%.
- **Baseline Metric**: Current mobile checkout conversion = 3.2%.
- **Target Metric**: Mobile checkout conversion >= 3.68% (p-value < 0.05).
- **Control vs Treatment**: 50% traffic control (legacy form) vs 50% treatment (1-click).
- **Observation Window**: 14 days or minimum 10,000 completed checkout attempts.
- **Decision Threshold**:
  - If conversion lift >= +15%: Roll out to 100% of mobile traffic.
  - If conversion lift between 0% and +14%: Iterate on UX copy for 7 days.
  - If conversion lift <= 0% or error rate > 0.1%: Rollback and KILL immediately.
```
