# API Design, Compatibility & Evolution

In distributed and rolling-deployment environments, Version $N$ and Version $N+1$ binaries will run simultaneously.

---

## 1. Non-Breaking Schema Evolution Rules

1. **Additive Field Changes**: Always add new fields as optional/nullable.
2. **Never Re-number or Repurpose Fields**: In JSON or Protobuf, never reuse existing field names or tag numbers for different data types.
3. **Handle Unknown Fields**: Do not crash or reject payloads containing unknown fields from newer versions (`json.Decoder.DisallowUnknownFields` should only be used in strict contract validation tests, not production ingress).
4. **Zero-Value Ambiguity**: Distinguish between an omitted field and an explicitly sent zero value using pointers (e.g. `*int` or `*bool`) when necessary.
