# Collateral Vault — Accounting Plan (Spec)

**Status:** Spec/Docs (no code). **Audience:** Core devs, auditors, SDK.  
**Scope:** Defines token-level accounting, deposits/withdrawals, fee flows, and decimals policy to implement later.

---

## 1) Goals & Constraints
- Support multiple ERC-20 collaterals with potentially non-standard decimals (6/8/18).
- Deterministic integer math; no rounding that violates supply bound.
- Vault holds **assets**, not 1kUSD. Fees accrued in asset units (per-asset buckets).
- No fee-on-transfer tokens supported in v1.

---

## 2) State Model (per Asset)
For each `asset`:
- `balances[asset]` — total units held by Vault (token decimals).
- `pendingFees[asset]` — fees accrued, not yet swept to Treasury (token decimals).
- `caps[asset]` — soft cap from `ParameterRegistry` (token decimals).
- `supported[asset]` — mirror of toggle (PSM may have its own whitelist).

> Storage visibility via read-only functions:
> - `balanceOf(asset)` → `balances[asset]`
> - `feesPending(asset)` → `pendingFees[asset]`

---

## 3) Deposits
`deposit(asset, from, amount)`
- **Prechecks:** Safety not paused; `supported[asset] = true`; `amount > 0`; cap headroom.
- **Transfer:** `safeTransferFrom(from, this, amount)`; revert if fee-on-transfer detected (see 3.1).
- **Accounting:** `balances[asset] += amount`.
- **Events:** `Deposit(asset, from, amount)`.

### 3.1 Fee-on-Transfer Guard
- Read post-transfer balance delta; require `delta == amount`.  
- If `delta < amount` → revert `FOT_NOT_SUPPORTED`.

---

## 4) Withdrawals
`withdraw(asset, to, amount, reason)`
- **Prechecks:** Safety not paused; supported; `amount > 0`; `balances[asset] >= amount`.
- **Accounting:** `balances[asset] -= amount`.
- **Transfer:** `safeTransfer(to, amount)`.
- **Events:** `Withdraw(asset, to, amount, reason)`.

> `reason` (bytes32): `"PSM_REDEEM" | "TREASURY_SPEND" | "MAINTENANCE" | ...`  
> The PSM uses `"PSM_REDEEM"`. Treasury sweeps use `"TREASURY_SPEND"`.

---

## 5) Fee Accrual & Sweep
- PSM calculates fees in **output asset units** (per PSM Quote Spec).
- PSM calls `deposit(asset, PSM, fee)` or batches into a net deposit.
- Vault increments `pendingFees[asset] += fee`.
- DAO/Treasury later executes `sweepFees(asset, to)`:
  - Prechecks: only Timelock admin; Safety OK.
  - Transfer `pendingFees[asset]` to `to` and zero bucket.
  - Event: `FeeSwept(asset, to, amount)`.

---

## 6) Caps & Headroom
- `cap = registry.getUint(keccak256("PARAM_CAP_PER_ASSET", asset))` (advisory in v1).
- `headroom = cap == 0 ? MAX_UINT : cap - balances[asset]`.
- Deposits must satisfy `amount <= headroom`.

---

## 7) Decimals Policy
- Vault **does not rescale** asset balances. All stored in token decimals.
- Conversions happen in PSM using oracle & decimals to 1kUSD(18).
- SDK must format amounts using token decimals from chain; registry `PARAM_DECIMALS_HINT` is advisory fallback.

---

## 8) Invariants (to test later)
- **V1:** `sum_i balances[i]*price[i] >= totalSupply(1kUSD)` (USD terms).
- `balances[asset] >= pendingFees[asset]`.
- Monotonicity: deposits increase `balances[asset]`; withdrawals decrease.

---

## 9) Errors (canonical)
- `ASSET_NOT_SUPPORTED`, `CAP_EXCEEDED`, `INSUFFICIENT_BALANCE`, `FOT_NOT_SUPPORTED`,
  `PAUSED`, `ACCESS_DENIED`, `ZERO_ADDRESS`, `INVALID_AMOUNT`.

---

## 10) Events (canonical)
- `Deposit(asset, from, amount)`
- `Withdraw(asset, to, amount, reason)`
- `FeeAccrued(asset, from, amount)` (optional, if PSM emits only Fee; Vault can mirror)
- `FeeSwept(asset, to, amount)`

---

## 11) Governance Hooks
- Caps and support toggles updated via ParameterRegistry + Timelock ops.
- Treasury address from `PARAM_TREASURY_ADDRESS` (sweep destination).

---

## 12) Migration Notes
- If decimals or token behavior changes on upstream token, governance must disable asset and migrate balances manually (docs TBD).

