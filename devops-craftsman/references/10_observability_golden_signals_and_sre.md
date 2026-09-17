# SRE Observability & The 4 Golden Signals

---

## 1. The 4 Golden Signals Framework

1. **Latency**: Time taken to service a request (differentiate latency of successful requests from failed requests).
2. **Traffic**: Measure of high-level system demand (e.g. HTTP requests per second, active I/O operations).
3. **Errors**: Explicit rate of failed requests (e.g. HTTP 5xx responses, failed database queries).
4. **Saturation**: How full the service is (e.g. CPU/Memory saturation, thread pool utilization, database connection pool exhaustion).

---

## 2. Actionable Alerting Hygiene

- Alert on **Symptoms and SLO Breaches** rather than arbitrary host utilization (e.g. alert when 5xx rate > 1% for 5 minutes, NOT merely when CPU reaches 85%).
- Every paging alert MUST include a link to an active, verified **Runbook** explaining exact mitigation steps.
