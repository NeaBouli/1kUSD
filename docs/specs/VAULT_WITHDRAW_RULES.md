# TreasuryVault Withdraw Rules (Spec v0.1)

**Goal:** define withdrawal and access control for TreasuryVault.

## Core Rules
- Only DAO_ROLE may call `withdrawCollateral()`.
- Zero-amount withdrawals revert.
- Balance for token must be >= amount.
- Emits `VaultWithdraw(to, token, amount)` on success.
- Guardian may pause withdrawals.

## Security
- NonReentrant modifier enforced.
- Uses safeTransfer().
