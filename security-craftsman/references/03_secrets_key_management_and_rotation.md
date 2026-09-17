# Secrets Management & Key Rotation

---

## 1. Envelope Encryption Architecture

To encrypt sensitive database columns (e.g. credit card tokens, social security numbers) securely:

```text
[ Key Management Service (AWS KMS / Vault) ]
         │ (Stores Master Key - KEK)
         ▼ Generates Data Encryption Key (DEK)
[ Application Process ]
         │ Encrypts plaintext payload with DEK using AES-GCM
         ▼
[ Database Row ]
  - ciphertext: Encrypted payload
  - encrypted_dek: DEK encrypted by KMS Master Key (KEK)
  - key_version: Version of the KEK
```

---

## 2. Safe Secret Rotation

1. Support **Dual-Key Verification**: System attempts decryption with the primary active key ($K_1$), falling back to the previous key ($K_0$) if decryption fails.
2. Background re-encryption script re-encrypts old data with $K_1$.
3. Deprecate and destroy $K_0$ only after 100% of persisted data is migrated.
