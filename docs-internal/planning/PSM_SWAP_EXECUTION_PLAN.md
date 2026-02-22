# PSM Swap Execution Plan (Spec)

**Status:** Spec/Docs (no code). **Audience:** Core devs, auditors, SDK.  
**Scope:** Defines *execution-time* behavior for PSM swaps after quotes are available (post DEV40). Covers CEI, guards, Vault interactions, fees, and events.

---

## 1) Design Principles
- **CEI** (Checks-Effects-Interactions) must be strictly enforced.
- **No reentrancy** via `nonReentrant` (or equivalent guard).
- **Determinism:** Execution must mirror the Quote exactly (same block/oracle snapshot).
- **Pull-accounting:** The PSM interacts only with `CollateralVault` for asset movements.

---

## 2) Pre-checks (common)
1. **Safety:** `safety.isPaused(MODULE_ID) == false`.
2. **Whitelist:** PSM `isSupported(token)` **and** Vault `isAssetSupported(token)`.
3. **Oracle:** `Oracle.getPrice(token)` → `healthy == true`, `updatedAt <= MAX_AGE`, deviation within limits.
4. **Params:** `feeBps = registry.getUint(PARAM_PSM_FEE_BPS)`.
5. **Deadline:** `deadline >= block.timestamp`.
6. **Slippage:** `netOut >= minOut` (after fees) or revert `SLIPPAGE`.

> **Snapshot:** A consistent oracle snapshot MUST be used for Quote & Exec. Either (a) Quote returns a snapshot ID echoed by Exec, or (b) Exec re-reads and validates identical values/bounds.

---

## 3) `swapTo1kUSD(tokenIn, amountIn, to, minOut, deadline)`
**A. Checks**
- Run the common pre-checks above.
- User must grant PSM `allowance(tokenIn) >= amountIn` (prepared off-chain).

**B. Effects (state)**
- Compute `(grossOut, fee, netOut)` per Quote rules (see `docs/PSM_QUOTE_SEMANTICS.md`).
- Do **not** increase 1kUSD supply before assets are confirmed in the Vault.
- Emit `FeeAccrued` only **after** successful accounting.

**C. Interactions**
1. **Ingress:** `safeTransferFrom(user -> Vault, amountIn)`  
   - Use `Vault.deposit(tokenIn, user, amountIn)` so FoT-guard & caps apply.
2. **Mint:** `OneKUSD.mint(to, netOut)` (PSM holds MINTER role).
3. **Fees:** Either `Vault.deposit(tokenIn, address(this), fee)` or accrual:
   - **Recommended:** PSM accrues fees → `pendingFees[tokenIn] += fee` (tracked by Vault).

**D. Events**
- `SwapTo1kUSD(user, tokenIn, amountIn, fee, netOut, block.timestamp)`
- Vault `Deposit`, Token `Transfer` (mint).

**E. Failure atomicity**
- If `deposit` fails → revert without mint.
- If `mint` fails (should not) → revert the entire transaction.

---

## 4) `swapFrom1kUSD(tokenOut, amountIn, to, minOut, deadline)`
**A. Checks**
- Run the common pre-checks with `tokenOut`.
- User must have 1kUSD `allowance(PSM) >= amountIn`.

**B. Effects**
- Compute `(grossOut, fee, netOut)` in **tokenOut** units.

**C. Interactions**
1. **Burn ingress:** `OneKUSD.burn(user, amountIn)` (PSM holds BURNER role).
2. **Egress:** `Vault.withdraw(tokenOut, to, netOut, "PSM_REDEEM")`.
3. **Fees:** Either immediate treasury withdrawal or accrual:
   - **Recommended:** Accrue in Vault (`pendingFees[tokenOut] += fee`) and sweep later.

**D. Inventory & headroom**
- Before `burn`, ensure `Vault.balanceOf(tokenOut) >= netOut + fee`. Otherwise revert `INSUFFICIENT_LIQUIDITY`.

**E. Events**
- `SwapFrom1kUSD(user, tokenOut, amountIn, fee, netOut, block.timestamp)`
- Token `Transfer` (burn), Vault `Withdraw`.

---

## 5) Reentrancy & Ordering
- Guard PSM swap functions with `nonReentrant`.
- Order:
  - **To1k:** Checks → Compute → `Vault.deposit` → `mint` → Fee accrual.
  - **From1k:** Checks → Compute → `burn` → `Vault.withdraw(net)` → Fee accrual/sweep.
- **No external callbacks** in PSM/Vault (no hooks) to reduce attack surface.

---

## 6) Errors & Custom Errors
- `UNSUPPORTED_ASSET`, `PAUSED`, `ORACLE_STALE`, `ORACLE_UNHEALTHY`, `DEVIATION_EXCEEDED`,
  `CAP_EXCEEDED`, `INSUFFICIENT_LIQUIDITY`, `SLIPPAGE`, `ACCESS_DENIED`, `ZERO_ADDRESS`.

---

## 7) Events (normative)
- PSM:
  - `SwapTo1kUSD(user, tokenIn, amountIn, fee, minted, ts)`
  - `SwapFrom1kUSD(user, tokenOut, amountIn, fee, paidOut, ts)`
- Vault:
  - `Deposit(asset, from, amount)`, `Withdraw(asset, to, amount, reason)`, `FeeSwept`.

---

## 8) Invariants (execution)
- Consistency: Exec `(gross, fee, net)` equals Quote for the same inputs/snapshot.
- No mint/burn without corresponding Vault movement (or liquidity check).
- Fee conservation: Sum of fees per asset reaches Treasury bucket.

---

## 9) Governance & Roles
- PSM requires `MINTER` and `BURNER` on 1kUSD.
- Treasury address from Registry (`PARAM_TREASURY_ADDRESS`).
- Fee BPS & limits come from Registry; changeable only via Timelock.

---

## 10) Test Sketch (later)
- Unit: fee/rounding, slippage, errors.
- Integration: deposit→mint, burn→withdraw, insufficient liquidity.
- Invariants: conservation, supply bound, monotonicity.
