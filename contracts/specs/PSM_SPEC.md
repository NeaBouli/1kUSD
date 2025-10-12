# Peg-Stability Module (PSM) — Functional Specification

**Scope:** This file defines the behavior of the Peg-Stability Module (PSM) for 1kUSD.  
**Status:** Spec (no code). **Language:** EN.

---

## 1. Purpose

The PSM maintains the 1kUSD peg by enabling **near-1:1 swaps** between 1kUSD and approved stablecoins (e.g., USDC/USDT/DAI) with small fees and explicit **rate limits** and **caps**. It integrates with:
- **CollateralVault** for custody of stablecoins,
- **1kUSD Token** for mint/burn,
- **OracleAggregator** for deviation/staleness guards,
- **Safety-Automata** for pause/resume and parameter enforcement,
- **Treasury** for fee accrual.

The PSM **cannot** move assets arbitrarily; it follows strict, auditable flows.

---

## 2. Interfaces (High-Level)

### 2.1 User-Facing Functions
- `swapTo1kUSD(tokenIn, amountIn) -> amountOut`
  - Accepts approved stablecoin, collects fee, **mints** `amountOut` 1kUSD to user.
- `swapFrom1kUSD(tokenOut, amountIn) -> amountOut`
  - **Burns** `amountIn` 1kUSD from user, transfers `amountOut` stablecoin from Vault to user.

Both revert when:
- Module paused by Safety-Automata,
- Oracle guards fail (deviation/stale),
- Caps/rate limits exceeded,
- Token not approved.

### 2.2 Administrative (via DAO/Timelock, executed by Safety-Automata or Governance executors)
- `setFeeBps(uint256 bps)` — total fee in basis points (e.g., 10 = 0.10%).
- `setAssetCap(asset, capAmount)` — maximum net exposure per asset.
- `setRateLimit(windowSec, maxAmount)` — rolling window limiter for gross flow.
- `setApprovedAsset(asset, enabled)` — add/remove stablecoin.
- `setTreasury(address)` — fee sink (non-custodial).
- `pause()/resume()` — via Safety-Automata only.

---

## 3. Parameters & Storage

- `feeBps: uint256` — global fee (may be split mint/redeem if later needed).
- `caps[asset]: uint256` — exposure cap per stablecoin in Vault.
- `rateLimit`: `{windowSec:uint256, maxAmount:uint256}`
  - Applies to **gross notional** across both directions (configurable future extension: per-direction).
- `approved[asset]: bool`
- `treasury: address` — receives fees (stablecoin fees credited in Vault, 1kUSD fees via burn-with-skimming if ever configured; **initially stable-only**).
- Rolling window buckets for rate limit: e.g., **cumulative amount** within last `windowSec` seconds (implementation can use circular buffer or summed buckets).

---

## 4. Fees & Amount Calculation

Let:
- `A_in` = user input amount,
- `fee = floor(A_in * feeBps / 10000)`,
- `A_eff = A_in - fee`.

**To 1kUSD (mint path):**  
- User deposits `A_in` stablecoin, fee credited to Treasury (as stable in Vault).
- PSM **mints** `A_eff` of 1kUSD to `msg.sender`.  
- All stablecoin remain in Vault (including fee).

**From 1kUSD (redeem path):**  
- User burns `A_in` 1kUSD, `fee` withheld as **1kUSD** (burned to Treasury bucket) or alternatively collected as **stable** (implementation choice).  
- PSM transfers `A_eff` stablecoin from Vault to user.
- **Initial design:** fee kept in **stable** for simplicity and accounting symmetry (burn full `A_in` 1kUSD, pay out `A_eff` stable; fee accounted to Treasury as stable).

**Note:** For chains with stablecoins of differing decimals (e.g., 6 vs 18), conversions must be handled losslessly with rounding **in favor of the protocol** (min payout).

---

## 5. Caps, Rate Limits, Oracle Guards

### 5.1 Exposure Caps
- For mint path: `vaultBalance(asset) + A_in ≤ caps[asset]`.  
- For redeem path: `A_eff ≤ available(asset)`; otherwise revert `CAP_EXCEEDED`.
- Safety-Automata is the single writer for `caps` (via DAO/Timelock).

### 5.2 Rate Limits (Global)
- Maintain sliding window sum `Σ_flow(window)` over last `windowSec` seconds.  
- Before swap, ensure: `Σ_flow(window) + A_in ≤ maxAmount`. Else `RATE_LIMIT_EXCEEDED`.
- On success, record `A_in` in window.

### 5.3 Oracle Guards
- Before swap:
  - Fetch `isHealthy(asset)` and `deviation` vs. USD peg.  
  - If not healthy or deviation > configured threshold: **revert** `ORACLE_UNHEALTHY` or **auto-pause** via Safety-Automata policy hook (read-only here; pause is external).

---

## 6. State Machine (Informal)

States: `Active` | `Paused`.  
- Transitions:
  - `Active -> Paused`  : Safety-Automata `pause()` (oracle stale/deviation, incident, governance action).
  - `Paused -> Active`  : Safety-Automata `resume()` after conditions met.

**Active:** swaps allowed if caps and rate limit permit.  
**Paused:** swaps revert `MODULE_PAUSED`.

---

## 7. Event Semantics (must match `interfaces/ONCHAIN_EVENTS.md`)

- `SwappedTo1kUSD(user, tokenIn, amountIn, amountOut, fee, ts)`  
- `SwappedFrom1kUSD(user, tokenOut, amountIn, amountOut, fee, ts)`  
- `PSMFeeSet(bps, ts)`  
- `PSMCapSet(asset, cap, ts)`  
- `PSMRateLimitSet(windowSec, maxAmount, ts)`

**All** with consistent decimals and timestamping.

---

## 8. Error Conditions (non-exhaustive)

- `MODULE_PAUSED`
- `ASSET_NOT_APPROVED`
- `CAP_EXCEEDED`
- `RATE_LIMIT_EXCEEDED`
- `ORACLE_UNHEALTHY` / `PRICE_DEVIATION`
- `INSUFFICIENT_LIQUIDITY`
- `DECIMAL_OVERFLOW` (mismatched decimals)
- `ZERO_AMOUNT`

Return meaningful custom errors for reproducibility.

---

## 9. Accounting & Treasury

- Fees accumulated **in Vault** per asset.  
- `FeeAccrued(source="PSM", asset, amount, ts)` emitted on each swap.  
- Treasury **cannot** pull funds except via DAO-approved spend (Timelock).  
- **Invariant:** `sum(stable in Vault) ≥ outstanding 1kUSD liabilities implied by PSM flows` (see Invariants doc).

---

## 10. Security Considerations

- No reentrancy: single-function non-reentrant guard.  
- Checks-Effects-Interactions: update internal limits before external calls.  
- Pausable via Safety-Automata; PSM itself has no owner with withdrawal power.  
- Oracle guard: enforce `isHealthy(asset)` and maximum `deviationBps`.  
- Precision: unify to 18 decimals in internal math; convert at boundaries.

---

## 11. Test Matrix (Guidance)

- Happy paths: small/large swaps both directions; boundary at caps and rate limits.  
- Oracle anomalies: stale feed, deviation > threshold → revert; ensure no state drift.  
- Liquidity: redeem with insufficient Vault balance → revert.  
- Decimal mismatch: USDC(6) <-> 1kUSD(18) exact rounding tests.  
- Pausing/resuming: state transitions, pending swaps revert during pause.

---

## 12. Future Extensions

- Per-asset fees and per-direction fees.  
- Multi-tranche caps (soft/hard).  
- Dynamic fees based on deviation or utilization.  
- Allowlist for institutional routes with separate limits (optional).
