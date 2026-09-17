# DNS, TLS & Network Cutover Strategies

---

## 1. Zero-Downtime DNS Migration Protocol

1. **Phase 1 (T-48 Hours)**: Reduce DNS TTL to `60` seconds on the current authoritative nameserver.
2. **Phase 2 (T-0 Hours)**: Deploy new infrastructure and verify health with direct IP / host header curl tests:
   ```bash
   curl -vk --resolve app.example.com:443:203.0.113.50 https://app.example.com/health/ready
   ```
3. **Phase 3 (Cutover)**: Point DNS record to the new IP / CNAME.
4. **Phase 4 (T+48 Hours)**: Increase DNS TTL back to standard value (e.g. `3600` or `86400` seconds).
