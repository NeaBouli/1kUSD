# Notes — PSM Execution (DEV52)
- Mirror quotes exactly; same block oracle snapshot to avoid drift.
- Prefer fee accrual into Vault buckets over immediate treasury withdraws.
- Enforce CEI: compute before any external calls; mint/burn only after Vault ops check out.
- Reentrancy: guard PSM swap functions; Vault should avoid calling back into PSM.
