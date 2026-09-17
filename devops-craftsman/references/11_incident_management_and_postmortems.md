# Incident Management & Blameless Postmortems

---

## 1. The Incident Response Hierarchy

During a production outage:
1. **Incident Commander (IC)**: Single decision-maker responsible for orchestrating response, assigning tasks, and maintaining communication.
2. **Operations Lead**: Focuses strictly on mitigating user impact and restoring service availability.
3. **Communications Lead**: Updates internal stakeholders and publishes customer-facing status page notifications.

---

## 2. Blameless Postmortem Structure

After mitigation:
- **Timeline**: Exact chronological sequence of events (T-0 detection, T+5 escalation, T+12 mitigation, T+20 full recovery).
- **Root Cause & Trigger**: Distinguish underlying architectural vulnerability from the immediate trigger.
- **Action Items**: Preventative measures with assigned owners and hard deadlines (e.g. "Add automated rollback rule by Friday").
