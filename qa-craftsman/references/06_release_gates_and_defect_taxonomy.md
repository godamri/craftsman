# Release Gates & Defect Taxonomy

---

## 1. Automated Release Quality Gates

A pull request or deployment artifact is blocked from release if any of the following gates fail:

1. **Unit & Invariant Tests**: 100% passing.
2. **Race Detector**: Zero data race warnings (`go test -race`).
3. **Flaky Test Check**: Zero quarantined or unstable tests in the release path.
4. **Security Vulnerability Scanner**: Zero high/critical CVEs in direct dependencies (Trivy, Grype, Dependabot).
5. **Migration Verification**: Database migration rollback scripts tested against staging volume snapshots.

---

## 2. Defect Root-Cause Taxonomy

| Classification | Root Cause Description | Remediation Rule |
| :--- | :--- | :--- |
| **Logic Defect** | Missing invariant assertion or algorithm bug | Add unit/property test asserting invariant. |
| **Concurrency Defect** | Race condition or unsynchronized shared memory | Add barrier concurrency test with `-race`. |
| **Boundary Defect** | Unhandled null, empty, or overflow payload | Add negative boundary test case. |
| **Transient Defect** | Unhandled timeout, connection drop, 503 error | Add failure injection test with retries. |
