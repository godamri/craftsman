# Capacity Management & WIP Limit Governance

> **Core Principle**: Organizational capacity is a hard mathematical constraint. Running teams at 100% planned utilization creates infinite queue delays and guarantees delivery failure.

---

## 1. The Capacity Allocation Model

Total team capacity must be allocated according to a sustainable, resilient distribution:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ 1. STRATEGIC COMMITTED WORK (60% Capacity)                                            │
│    Active funded roadmap initiatives and high-priority project milestones.            │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 2. OPERATIONAL MAINTENANCE & BUG REMEDIATION (20% Capacity)                            │
│    System health, security patches, technical debt reduction, and customer support.    │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ 3. UNPLANNED DISRUPTIONS & BUFFER (20% Capacity)                                       │
│    Incident response, critical escalations, discovery spikes, and sick leave.          │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Queuing Theory & The Utilization Trap (Kingman's Formula)

As team utilization approaches 100%, wait time for new work increases asymptotically toward infinity:

```text
Wait Time (Queue Delay)
     ▲
     │                                            │ (100% Util = Infinite Delay)
     │                                           /
     │                                         /
     │                                      _--
     │                             _------''
     └───────────────────────────''────────────────────────► Utilization (%)
                               80%              100%
```

- **Rule**: Cap planned roadmap commitments at **80% of effective historical velocity**.
- **Rule**: If an emergency initiative MUST start, an active in-flight initiative MUST be paused, killed, or descheduled to maintain capacity balance.
