# Routing Adapters — Specification

**Scope:** Common interface & safety requirements for AutoConverter routing adapters.
**Status:** Spec (no code). **Language:** EN.

## 1. Interface (concept)
interface IRouteAdapter {
  // Pure/view quote; MUST NOT move funds.
  quote(assetIn, amountIn, assetOut)
    -> { amountOut, gasEstimate, routeId, warnings[] };
  // Execute quoted route; MUST ensure minAmountOut to recipient.
  execute(routeId, amountIn, minAmountOut, recipient)
    -> amountOut;
}

- routeId encodes pools/fees/hops; warnings: "LOW_LIQ"|"VOLATILE"|"SANITY_FAIL"|"ROUTER_RISK".

## 2. Types
- AMM: UniswapV2/V3, Curve.
- Aggregator: 1inch/0x/ParaSwap.
- Router: protocol universal routers.

## 3. Safety
- Quote purity; local sanity checks; min-out enforcement; final recipient = Vault; no lingering approvals.

## 4. Decimals
- Adapters return raw token units; AutoConverter normalizes for oracle checks.

## 5. Tests
- Deterministic routeId; illiquid pools; manipulated reserves; realistic gas estimates.
