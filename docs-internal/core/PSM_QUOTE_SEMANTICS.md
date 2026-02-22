# PSM Quote Semantics — Fees & Rounding (Future-Proof)

**Status:** Spec/Docs (no code). **Audience:** Core devs, SDK authors, auditors.  
**Scope:** Defines how `quoteTo1kUSD` / `quoteFrom1kUSD` normalize decimals, apply fees, and round. Applies when swaps are implemented (quotes MUST mirror execution exactly).

---

## 1) Inputs, Decimals & Normalization

- **Inputs**
  - `tokenIn` / `tokenOut`: ERC-20 address (may be 6 or 18 decimals; fee-on-transfer tokens are **not** supported).
  - `amountIn`: amount in **token decimals** (uint256).
- **Decimals**
  - `tokenDecimals = decimals(token)`
  - `oneKUSDec = 18` (1kUSD has 18 decimals)
- **Normalization**
  - Convert `amountIn` → **USD-basis** via oracle:
    - `priceUSD` = OracleAggregator.getPrice(token).price (units: USD with `priceDecimals`)
    - Use integer math:  
      - `amountUSD = amountIn * priceUSD * 10^(USD_DECIMALS_PAD) / 10^tokenDecimals / 10^priceDecimals`
    - **USD_DECIMALS_PAD**: chosen to avoid precision loss; implementation MUST document it (e.g., 18).
- **Downstream rounding rule (normative)**
  - **Conservative towards user** on quotes:
    - For **mint** (`to 1kUSD`): round **down** output (floor).
    - For **redeem** (`from 1kUSD`): round **up** fees and **down** net output.

---

## 2) Fees Model (parameterized)

- Global parameter: `PARAM_PSM_FEE_BPS` (0..10000).
- **Gross/Net**
  - `grossOut` (pre-fee) = normalized output before fee.
  - `fee = ceil(grossOut * feeBps / 10_000)`
  - `netOut = grossOut - fee`
- **Direction**
  - Same fee policy for both directions by default.
  - Registry MAY define per-asset or per-direction overrides later (must keep backward compatibility).

---

## 3) Quote Functions (spec)

### 3.1 `quoteTo1kUSD(tokenIn, amountIn) → (grossOut, fee, netOut)`
- **Meaning:** mint 1kUSD using `tokenIn`.
- **Steps:**
  1. Validate `tokenIn` supported (PSM & Vault & Safety OK).
  2. Read oracle price; fail if `!healthy` or stale/deviation per policy.
  3. Normalize to 1kUSD(18):
     - `grossOut = floor(amountUSD * 10^18 / 10^USD_DECIMALS)`
  4. `fee = ceil(grossOut * feeBps / 10_000)`
  5. `netOut = grossOut - fee`
- **Rounding guarantees:**
  - No over-issuance: `netOut <= economicAmountMintable`.
  - Deterministic integer math; no hidden casts.

### 3.2 `quoteFrom1kUSD(tokenOut, amountIn) → (grossOut, fee, netOut)`
- **Meaning:** redeem 1kUSD to `tokenOut`.
- **Steps:**
  1. Validate `tokenOut` supported; oracle healthy.
  2. Convert 1kUSD(18) to USD, then to `tokenOut(decimals)`:
     - `grossOut = floor(amountUSD * 10^tokenDecimals / priceUSDAdj)`
  3. Fee in **tokenOut** units:
     - `fee = ceil(grossOut * feeBps / 10_000)`
  4. `netOut = grossOut - fee`
- **Rounding guarantees:**
  - No under-collateralization from math drift.

---

## 4) Edge Cases & Guards

- **Zero/Small amounts:** if normalization → 0 netOut, return `(grossOut, fee, netOut)` with zeros; SDKs should gray out CTA.
- **Decimals mismatch:** must use token-decimals from on-chain; optional `PARAM_DECIMALS_HINT` is advisory only.
- **Oracle guards:** reject if `!healthy`, stale (`updatedAt` too old), or deviation > threshold.
- **Paused:** reject when SafetyAutomata marks PSM paused.
- **Unsupported tokens:** revert `UNSUPPORTED_ASSET`.
- **Fee=0:** allowed; still apply rounding policy.

---

## 5) Examples (worked)

Assume `feeBps=10` (0.10%), `USDC.decimals=6`, `1kUSD.decimals=18`, oracle `USDC/USD = 1.000000 (6 decimals)`.

- **To 1kUSD:** `amountIn = 100_000_000` (100 USDC)
  - Normalize → `grossOut = 100 * 1e18`
  - `fee = ceil(100e18 * 10 / 10000) = ceil(0.01e18) = 10^16`
  - `netOut = 100e18 - 10^16`

- **From 1kUSD:** `amountIn = 100e18`
  - Normalize → `grossOut = floor(100 * 1e6) = 100_000_000`
  - `fee = ceil(100_000_000 * 10 / 10000) = 10_000`
  - `netOut = 99_990_000` (USDC units)

---

## 6) Invariants (must hold)

- **I1 Supply Bound:** Vault USD value ≥ 1kUSD supply (including pending fees).
- **I2 Conservation:** Quote + Exec produce identical `(gross, fee, net)` for same inputs within a block.
- **I3 Monotonicity:** Increasing `amountIn` must not decrease `netOut` (piecewise linear with fee ceiling).

---

## 7) SDK Notes

- Always display units/decimals clearly; format using token decimals.
- Show `(gross, fee, net)` explicitly; never recompute fee client-side.
- Cache addresses/params from `ops/config/*.json`; re-read on updates.

---

## 8) Migration / Compatibility

- Any change to fee policy or rounding requires a **minor version bump** in RPC interface docs and a CHANGELOG entry.
- Contracts MUST expose a `version()` or emit an upgrade event when behavior changes.
