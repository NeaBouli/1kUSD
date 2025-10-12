# AutoConverter — Functional Specification

**Scope:** Converts supported **volatile** or non-stable assets into approved **stablecoins** with best-execution guarantees and bounded slippage; outputs go to **CollateralVault**.
**Status:** Spec (no code). **Language:** EN.

## 1. Goals & Non-Goals
- Goals: best execution across adapters; bounded slippage; oracle sanity; direct deposit to Vault; optional PSM handoff.
- Non-Goals: custody, cross-chain bridging, market-making.

## 2. External Interfaces
- convert(assetIn, amountIn, preferredStable, slippageBps, minOutHint?, deadline?) -> {assetOut, amountOut, routeId}
- systemConvert(...) -> same shape, for protocol callers
- Admin (via Safety/DAO): addAdapter/removeAdapter, setMaxSlippageBps, setMinLiquidityUSD, setStableWhitelist, pause/resume

## 3. Routing & Quotes
- Adapters implement IRouteAdapter (see ROUTING_ADAPTERS_SPEC.md).
- Best execution: collect quotes, filter by oracle-implied minOut & minLiquidityUSD, pick max amountOut (tie → min gas).
- Oracle sanity: expectedOut from OracleAggregator; enforce slippage bound.

## 4. Flow
1) Checks & token pull → 2) quote/select → 3) execute to Vault recipient → 4) emit events → 5) optional PSM mint.

## 5. Storage / Params
- adapters[], maxSlippageBps, minLiquidityUSD, stableWhitelist, paused.

## 6. Events
- ConvertRequested(user, assetIn, amountIn, slippageBps, ts)
- RouteSelected(routeId, aggregator, expectedOut, ts)
- Converted(assetIn, assetOut, amountIn, amountOut, fee, ts)

## 7. Errors
- MODULE_PAUSED, ASSET_NOT_APPROVED, NO_VALID_ROUTE, ORACLE_UNHEALTHY,
  SLIPPAGE_EXCEEDED, INSUFFICIENT_OUTPUT_AMOUNT, DEADLINE_EXPIRED, TRANSFER_FROM_FAILED

## 8. Security
- nonReentrant; CEI; oracle health required; minOut enforced; allowances cleaned.

## 9. Tests
- Multi-adapter selection; decimals 6↔18; oracle stale/deviation; thin liquidity; deadline/slippage edges; reentrancy.
