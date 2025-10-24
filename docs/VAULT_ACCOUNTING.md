
CollateralVault Accounting (v1)

Status: Normative. Language: EN.

1) Goals

Correct per-asset balances under mixed decimals (6/8/18).

Fee-on-transfer (FoT) tokens handled via received-amount accounting.

Separate fee accrual bucket per asset (pendingFees[asset]).

No direct asset custody by Safety/DAO; Vault is the source of truth.

2) Deposit (Ingress)

Input: asset, from, amount (requested)
Steps:

Before: bal0 = balanceOf(asset, Vault)

TransferFrom(from -> Vault, amount) (MUST use safe wrapper)

After: bal1 = balanceOf(asset, Vault)

received = bal1 - bal0

Require: received > 0 (else revert FOT_ZERO_RECEIVED)

Increase internal ledger by received; emit Deposit(asset, from, received)

3) Withdraw (Egress)

Input: asset, to, amount, reason

Require: ledger[asset] - pendingFees[asset] >= amount

Transfer(Vault -> to, amount)

Decrease ledger; emit Withdraw(asset, to, amount, reason)

4) Fee Accrual

To1k path: PSM takes fees in tokenIn → prefer track in PSM then sweep → OR:
Vault.accumulateFee(asset, fee) to bump pendingFees[asset].

From1k path: fee in tokenOut → Vault.accumulateFee(asset, fee) before transfer.

Sweep: Vault.sweepFees(asset, treasury) moves pendingFees and zeroes bucket; emit FeeSwept(asset, amount).

5) Decimals & Units

Ledger stores raw token units as-is (no normalization).

Cross-asset math occurs off-chain or in PSM (1kUSD conversion).

6) Invariants

Vault ledger ≥ on-chain ERC-20 balance (FoT can only reduce received, never inflate).

Σ(pendingFees) ≤ Vault ledger for each asset.

Withdraw never exceeds ledger - pendingFees.

7) Errors & Events (normative)

Errors: FOT_ZERO_RECEIVED, INSUFFICIENT_LIQUIDITY, FEE_OVERFLOW
Events: Deposit(asset, from, amount), Withdraw(asset, to, amount, reason), FeeSwept(asset, amount)
