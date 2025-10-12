# Peg-Stability Module (PSM) — Functional Specification
**Scope:** 1:1 swaps between approved stables and 1kUSD with minimal fee, enforcing caps/rate-limits and oracle/safety guards.  
**Status:** Spec (no code). **Language:** EN.

## 1. Goals
- Maintain peg via **1:1 swap** paths: Stable → 1kUSD (**mint**) and 1kUSD → Stable (**redeem**).
- Low, configurable **feeBps** (symmetric or dual: `feeInBps`, `feeOutBps`).
- Enforce **exposure caps** (per-asset) and **rate limits** (gross flow/window).
- Emit complete event trail for indexers; no custody beyond immediate flow.

## 2. External Interfaces (high-level)
- `swapTo1kUSD(tokenIn, amountIn, to, minOut, deadline) -> amountOut`
- `swapFrom1kUSD(tokenOut, amountIn, to, minOut, deadline) -> amountOut`
- Views:
  - `getParams() -> { feeInBps, feeOutBps, rate:{windowSec,maxAmount}, caps: AssetCap[] }`
  - `quoteTo1kUSD(tokenIn, amountIn) -> { grossOut, fee, netOut }`
  - `quoteFrom1kUSD(tokenOut, amountIn) -> { grossOut, fee, netOut }`

**Admin (DAO via Safety/Timelock):**
- `setFees(feeInBps, feeOutBps)`
- `setRateLimit(windowSec, maxAmount)`
- `setAssetCap(token, cap)`
- `pause()/resume()` (Safety)

## 3. Core Flow (Stable → 1kUSD)
1. **Preflight:** not paused; token approved; **OracleAggregator healthy** (for sanity only); **RateLimit** headroom; **cap** headroom in **Vault** for `tokenIn`.
2. Pull `amountIn` of `tokenIn` from user.
3. Compute `fee = amountIn * feeInBps / 1e4`; `net = amountIn - fee`.
4. **Deposit** `amountIn` to **Vault** (`deposit(tokenIn, PSM, amountIn)`).
5. **Mint** `net` worth of **1kUSD** (normalized for decimals): `mint = normalize(net, d_tokenIn)`; mint to `to`.
6. Update **Treasury accounting** with `fee` (fee retained in Vault).
7. Emit `SwapTo1kUSD`.

## 4. Core Flow (1kUSD → Stable)
1. **Preflight:** not paused; token approved; **RateLimit** headroom; Vault has liquidity.
2. Burn `amountIn` of 1kUSD from user.
3. Compute `fee = grossOut * feeOutBps / 1e4` where `grossOut = denormalize(amountIn, d_tokenOut)`.
4. Withdraw `(grossOut - fee)` of `tokenOut` from **Vault** to `to` with reason `"PSM_REDEEM"`.
5. Fee stays in Vault, **Treasury** accounting increased.
6. Emit `SwapFrom1kUSD`.

## 5. Math & Decimals
- **Normalization:** tokens with `d` decimals converted to 18-decimal internal units:
  - `norm(x,d) = x * 10^(18-d)`; `denorm(y,d) = floor(y / 10^(18-d))` (round in protocol favor).
- **Fees:** integer math; use `mulDiv`-style safe math to avoid precision loss.

## 6. Guards
- **Pause guard** (Safety).
- **Rate limit** (rolling window on gross flow; both directions share the same window by default).
- **Caps:** For Stable→1kUSD, cap applies to **post-deposit** Vault exposure of `tokenIn`.
- **Oracle sanity:** Optional mid-price check vs $1 with `maxDeviationBps` (advisory; failure → revert to prevent anomalies).
- **Deadline**: `block.timestamp ≤ deadline`.

## 7. Storage (concept)
- `feeInBps`, `feeOutBps`
- `rateLimit{windowSec, maxAmount, usedInWindow}`
- Reference to **Safety-Automata** for caps & pause state.
- Reference to **Vault**, **OracleAggregator**, **Treasury accounting hook**.

## 8. Events (align with interfaces/ONCHAIN_EVENTS.md)
- `SwapTo1kUSD(user (indexed), tokenIn (indexed), amountIn, fee, minted, ts)`
- `SwapFrom1kUSD(user (indexed), tokenOut (indexed), amountIn, fee, paidOut, ts)`
- `FeesUpdated(feeInBps, feeOutBps, ts)`
- `RateLimitUpdated(windowSec, maxAmount, ts)`
- `CapViolation(token (indexed), requested, cap, ts)` (mirror from Safety/Vault where applicable)

## 9. Errors (non-exhaustive)
- `MODULE_PAUSED`, `ASSET_NOT_APPROVED`, `CAP_EXCEEDED`, `RATE_LIMIT_EXCEEDED`
- `INSUFFICIENT_LIQUIDITY`, `SLIPPAGE_EXCEEDED`, `DEADLINE_EXPIRED`, `ORACLE_UNHEALTHY`

## 10. Testing Guidance
- Fee rounding (6/18 decimals), cap boundary, rate-limit window rollover, pause/resume, oracle deviation block, reentrancy.
