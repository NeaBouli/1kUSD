# TreasuryVault Accounting Rules (Spec v0.1)

**Goal:** define balance tracking and access restrictions
for Peg Stability Module (PSM) deposits.

## Rules
- Only PSM may call `depositCollateral()`.
- Zero-amount deposits revert.
- Each token tracked separately in `balances[token]`.
- Emits `VaultDeposit(from, token, amount)` on success.
