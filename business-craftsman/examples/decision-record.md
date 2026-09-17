# Decision Record: DR-018 Phased Phased Currency Launch for Project Magellan

## Status
ACCEPTED (2026-08-30)

## Context & Problem
Project Magellan was scoped to launch both EUR (SEPA) and GBP (Faster Payments) rails simultaneously on October 15, 2026. 
While EUR integration and regulatory requirements are 100% verified, the UK FCA correspondence regarding safeguarding account structure will not arrive until October 28. 
Waiting for GBP would delay the entire \$1.2M annual revenue opportunity by 4–6 weeks.

## Evaluated Options
1. **Option A: Hold Entire Launch until GBP Cleared (Rejected)**
   - *Cost of Delay*: \$100,000 lost revenue in October.
   - *Risk*: Demoralizes team and misses enterprise pilot commitments.
2. **Option B: Phased Rollout — Launch EUR on Oct 15, GBP in November (Recommended)**
   - *Pros*: Captures 75% of revenue immediately (€850k/yr); satisfies European enterprise clients.
   - *Cons*: Requires minor UI feature flag to hide GBP virtual accounts temporarily.
3. **Option C: Launch GBP using Third-Party Umbrella Rails (Rejected)**
   - *Reason*: Incurs 0.45% additional transaction fees, destroying unit margins.

## Chosen Decision & Trade-Offs
- **Decision**: Execute Option B (Phased Rollout).
- **Economic Impact**: Captures \$70k revenue in Month 1 while keeping UK compliance 100% sound.
- **Revisit Trigger**: Arrival of FCA clearance letter on or before October 28, 2026.
