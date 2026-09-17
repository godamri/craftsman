# Post-Incident Review (PIR): SEV-1 Database Connection Exhaustion Outage

## 1. Incident Metadata
- **Date & Time**: 2026-08-29 14:15 – 14:48 UTC (Duration: 33 minutes)
- **Impact**: 1,420 checkout attempts failed with HTTP 500; estimated \$48,000 delayed revenue.
- **Incident Commander**: Lead SRE Engineer
- **Lead Investigator**: Principal Systems Architect

---

## 2. Executive Summary
At 14:15 UTC, the central database connection pool reached 100% saturation (500/500 connections), causing API servers to queue incoming HTTP requests until health checks failed, leading to a cascading service outage. 
The root cause was a newly deployed reporting feature that opened an unindexed, long-running database query inside an open transaction while making an external synchronous HTTP call to an analytics vendor.

---

## 3. Timeline (UTC)
- **14:05**: Release v2.3.8 deployed to 100% of fleet.
- **14:15**: Analytics vendor experiences 15s latency; API workers hold DB transactions open waiting for vendor HTTP response.
- **14:18**: Database active connections reach 500 (max limit); lock waits trigger P1 alarm.
- **14:22**: Incident Commander declares SEV-1; executes emergency rollback to v2.3.7.
- **14:35**: Rollback complete; connection pool drains to normal baseline (42 active connections).
- **14:48**: Verification complete; all checkout and settlement metrics confirmed nominal.

---

## 4. 5-Whys Root Cause Analysis
1. *Why did checkouts fail?* Database rejected new connections due to pool exhaustion.
2. *Why was the connection pool exhausted?* 500 connections were held open in `idle in transaction` state.
3. *Why were transactions held open?* The code was awaiting a slow external HTTP analytics response before committing.
4. *Why was external HTTP I/O inside a database transaction?* The developer did not decouple side effects from the database transaction boundary.
5. *Why didn't tests catch this?* The test suite mocked the analytics client as an instant in-memory call and did not test transaction duration under latency injection.

---

## 5. Corrective & Preventive Action Items

| Action Item | Type | Owner | Deadline | Status |
| :--- | :--- | :--- | :--- | :--- |
| Move analytics tracking to an asynchronous outbox event outside the DB transaction. | Architecture | Core Squad | 2026-09-01 | In Progress |
| Configure `SET idle_in_transaction_session_timeout = '5s'` across all DB pools. | Database | DBA / SRE | 2026-08-30 | ✅ Done |
| Add static analysis linter rule forbidding HTTP client calls inside transaction blocks. | CI / Tooling | Tooling Squad| 2026-09-05 | In Progress |
| Add failure injection latency test to CI integration test suite. | QA | QA Squad | 2026-09-03 | In Progress |
