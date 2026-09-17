# Invariant & Property-Based Testing

---

## 1. Testing Domain Invariants

Instead of testing only specific values, test that mathematical and domain invariants hold before and after every state mutation:

### Financial Ledger Invariants:
1. `Sum(Debits) == Sum(Credits)` (Zero-Sum Invariant).
2. `Account.Balance >= 0` for non-overdraft accounts.
3. Total system money before batch transfer equals total system money after batch transfer (Conservation of Value).

---

## 2. Property-Based Testing & Fuzzing

Use property-based fuzzers (e.g. Go `testing.F`, Python `hypothesis`) to generate thousands of random inputs:

```go
func FuzzMoneyParsing(f *testing.F) {
    f.Add("$12.34")
    f.Add("0.00")
    f.Add("-100.50")

    f.Fuzz(func(t *testing.T, raw string) {
        amount, err := ParseMoney(raw)
        if err == nil {
            // Property: String roundtrip must match parsed representation
            formatted := amount.String()
            reparsed, err2 := ParseMoney(formatted)
            if err2 != nil || reparsed != amount {
                t.Fatalf("Roundtrip failure for %q -> %v", raw, amount)
            }
        }
    })
}
```
