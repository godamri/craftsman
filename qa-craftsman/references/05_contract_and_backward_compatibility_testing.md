# Contract & Backward Compatibility Testing

---

## 1. Multi-Version Cross-Compatibility Testing

During rolling deployments, services of Version $N$ and Version $N+1$ coexist. Test compatibility by validating:

1. **Old Client $\to$ New Server**: Can a legacy client payload still be parsed and processed by the updated server without errors?
2. **New Client $\to$ Old Server**: Does a legacy server gracefully ignore newly added optional fields without crashing?
3. **Database Schema Coexistence**: Can legacy application binaries execute queries against the migrated schema during Phase 1 & 2 of an expand/contract migration?
