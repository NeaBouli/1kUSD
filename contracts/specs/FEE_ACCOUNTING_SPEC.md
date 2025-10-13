# Fee Accounting — Specification
**Scope:** Unified accounting for protocol fees (PSM in/out), storage in Vault, reporting to Treasury.  
**Status:** Spec (no code). **Language:** EN.

## Principles
- Fees are retained **in Vault** in the same asset collected.
- Treasury reads balances via Vault and indexes `FeeAccrued` events (no transfers needed).
- No fee taken on failed tx; fees computed on **gross** in/out depending on side.

## Formulas
- To 1kUSD (mint): `feeIn = amountIn * feeInBps / 1e4`; `mint = norm(amountIn - feeIn, dIn)`.
- From 1kUSD (redeem): `grossOut = denorm(amountIn, dOut)`; `feeOut = grossOut * feeOutBps / 1e4`; `payout = grossOut - feeOut`.

## Rounding Rules
- Normalization: `norm(x,d) = x * 10^(18-d)`; `denorm(y,d) = floor(y / 10^(18-d))`.
- Fees: round **down** in protocol favor (`floor`) to prevent over-credit.
- MinOut/Slippage compares against **payout** (post-fee).

## Events
- `FeeAccrued(token, amount, side, txHash, ts)` (side: TO_1KUSD|FROM_1KUSD).
- Treasury can derive USD via oracle snapshots off-chain.

## Edge Cases
- Fee-on-transfer tokens: disallowed unless adapter handles exact-in/out.
- Decimals changes: adapter must lock decimals at listing time.

## Reporting
- Indexer aggregates fees per asset/day; publishes USD rollup with sources.
