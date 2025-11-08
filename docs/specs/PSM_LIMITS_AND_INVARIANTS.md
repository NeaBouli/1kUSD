# Peg Stability Module – Limits & Invariants (Spec v0.1)

**Goal:** Enforce swap volume caps and reserve safety.

## Parameters
- `maxSingleSwap` – maximum per swap (set by DAO)
- `maxDailySwap` – cumulative per day (set by DAO)
- `dailyVolume` – tracks current day's total
- `stableReserves` – total stable available

## Invariant
`stableReserves >= collateralValue`

## Enforcement
- Revert if `amountIn > maxSingleSwap`
- Revert if `dailyVolume + amountIn > maxDailySwap`
- Reset `dailyVolume` when a new UTC day begins
- Check invariant before minting stable

