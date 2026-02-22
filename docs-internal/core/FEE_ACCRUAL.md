
Fee Accrual (PSM & Vault) — Normative

Fee location

To1k: fee charged in tokenIn → accrue on Vault side (preferred) OR accumulate in PSM then sweep.

From1k: fee charged in tokenOut → accrue on Vault before user transfer.

Rounding

Fees computed via floor (see ROUNDING_RULES.md).

Accrual bucket increments exactly by computed fee.

Sweeping

Only DAO/Timelock authorized caller for sweepFees (or PSM with ROLE_SWEEPER for its own accruals if policy allows).

Sweep emits FeeSwept(asset, amount) and transfers to Treasury.

Reporting

Indexer exposes pendingFees per asset.

PoR includes pendingFees separately from spendable balances.
