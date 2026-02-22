# Peg Stability Module – Swap Core (Spec v0.1)

**Goal:** Convert collateral ↔ stablecoin with safety checks and fees.

## Flow Overview
1. User calls `swapCollateralForStable(token, amountIn)`
2. OracleAggregator provides `price`
3. FeeRouterV2 routes fee portion
4. Remaining stable minted to user
5. Guardian + DAO can pause swaps

## Security
- NonReentrant + Pausable
- Uses latest median price
- Validates amount > 0
- Emits `SwapExecuted(user, token, amountIn, stableOut)`
