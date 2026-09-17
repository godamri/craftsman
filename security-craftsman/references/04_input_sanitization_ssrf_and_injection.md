# Input Sanitization, SSRF & Injection Defense

---

## 1. SSRF & DNS Rebinding Defense Protocol

When fetching user-supplied URLs (e.g. webhooks, avatars, previews), naive checks like `strings.HasPrefix(url, "127.0.0.1")` fail against DNS rebinding (where a malicious domain resolves to an external IP on validation, and then to `127.0.0.1` on actual connect).

### The 4-Step SSRF Protection Algorithm:
1. **Validate Scheme**: Allow only `http` or `https`.
2. **Resolve IP Addresses**: Resolve host DNS to `[]net.IP`.
3. **Block Private Subnets**: Reject any IP matching:
   - Loopback (`127.0.0.0/8`, `::1`)
   - Link-local (`169.254.0.0/16`)
   - RFC 1918 (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`)
   - Cloud metadata endpoints (`169.254.169.254`)
4. **Pin Connection to Verified IP**: Construct an `http.Transport` with a custom `DialContext` connecting directly to the validated IP address.
