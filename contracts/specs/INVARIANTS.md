# Protocol Invariants & Safety Properties

**Scope:** System-wide invariants that must hold at all times. **Language:** EN.

---

## 1. Monetary & Collateral Invariants

- **I1 (Supply Bound):** `totalSupply(1kUSD) ≤ Σ_i (VaultBalance_i * Price_i)` (USD terms), under the assumption that PSM mints only against on-chain reserves.
- **I2 (PSM Conservation):** For any swap `A_in` with fee `f`, net effect on reserves and liabilities must satisfy:
  - Mint path: `Δ1kUSD = A_in - f`, `ΔVaultStable = +A_in`, `FeeStable = f`.
  - Redeem path: `Δ1kUSD = -A_in` (burn), `ΔVaultStable = -(A_in - f)`, `FeeStable = f`.
- **I3 (No Free Mint):** Mint requires approved stable deposit reaching the Vault.
- **I4 (No Unauthorized Burn):** Burn only allowed when initiated by PSM during redeem or by protocol modules explicitly authorized.

## 2. Limits & Pausing

- **I5 (Caps):** For any asset `a`: `VaultBalance[a] ≤ Cap[a]`.
- **I6 (Rate Limits):** Within any rolling window `W`: `Σ_flow(W) ≤ maxAmount`.
- **I7 (Pause Safety):** If paused, **no** state-changing PSM operations succeed.

## 3. Oracle Health

- **I8 (Oracle Liveness):** `now - lastUpdate(asset) ≤ maxAgeSec`.
- **I9 (Deviation Guard):** `abs(medianPrice - $1) ≤ deviationBps/10000` for relevant assets.
- **I10 (Atomicity):** A swap must read a **single coherent** oracle snapshot (no mixed feeds mid-call).

## 4. Event Consistency

- **I11:** For every swap, exactly one of `SwappedTo1kUSD` or `SwappedFrom1kUSD` is emitted.
- **I12:** `amountIn = amountOut + fee` after normalizing decimals (within 1 wei of target unit).
- **I13:** `FeeAccrued(source="PSM")` is emitted with the exact `fee`.

## 5. Reentrancy & Ordering

- **I14:** No reentrancy to external tokens causes double-accounting (nonReentrant).
- **I15:** Checks → Effects → Interactions order maintained.

## 6. Treasury & Governance

- **I16:** No direct withdrawals from Vault except via protocol-approved paths (redeem) or DAO/Treasury spend.
- **I17:** Parameter changes only via DAO/Timelock; Safety-Automata can pause/resume but not move assets.

## 7. Proof Obligations (Testing)

- Property tests assert I1–I17 across random sequences (mint/redeem/pause/oracle changes).
- Fuzz tests include decimal mismatches and boundary conditions at caps/rate limits.
