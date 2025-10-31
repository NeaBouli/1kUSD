# Vault Sweeper (DAO Extension) – Spec v0.1

**Goal:**  
Allow DAO to reclaim stray tokens (non-collateral) from TreasuryVault.

## Rules
- Only DAO_ROLE may call `sweep(token, amount, to)`
- Reverts on zero amount
- Skips whitelisted collateral tokens
- Emits `VaultSwept(token, amount, to)`
- Pausable + nonReentrant enforced

## Security
- Prevent accidental sweeping of active collateral
- Uses safeTransfer()
- Logs all DAO sweep events for audit trail
