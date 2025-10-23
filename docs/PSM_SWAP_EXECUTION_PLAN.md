# PSM Swap Execution Plan (Spec)

**Status:** Spec/Docs (no code). **Audience:** Core devs, auditors, SDK.  
**Scope:** Defines *execution-time* behaviour for PSM swaps once aktiviert (nach DEV40 Quotes). Behandelt CEI, Guards, Vault-Interaktionen, Fees, Events.

---

## 1) Design-Prinzipien
- **CEI** (Checks-Effects-Interactions) strikt einhalten.
- **No reentrancy** via `nonReentrant` (oder äquivalenter Guard).
- **Determinismus**: Execution spiegelt Quote exakt (gleiches Block/Oracle-Snapshot).
- **Pull-Accounting**: PSM interagiert ausschließlich mit `CollateralVault` für Assetbewegungen.

---

## 2) Pre-Checks (gemeinsam)
1. **Safety**: `safety.isPaused(MODULE_ID) == false`.
2. **Whitelist**: PSM `isSupported(token)` **&** Vault `isAssetSupported(token)`.
3. **Oracle**: `Oracle.getPrice(token)` → `healthy == true`, `updatedAt <= MAX_AGE`, Deviation innerhalb Limits.
4. **Params**: `feeBps = registry.getUint(PARAM_PSM_FEE_BPS)`.
5. **Deadline**: `deadline >= block.timestamp`.
6. **Slippage**: `netOut >= minOut` (nach Gebühren), sonst revert `SLIPPAGE`.

> **Snapshot**: Ein konsistenter Oracle-Snapshot muss für Quote & Exec verwendet werden. Entweder (a) Quote liefert Snapshot-ID zurück oder (b) Exec liest erneut und verifiziert gleiche Werte/Bounds.

---

## 3) `swapTo1kUSD(tokenIn, amountIn, to, minOut, deadline)`
**A. Checks**
- Pre-Checks (oben).
- User muss PSM `allowance(tokenIn) >= amountIn` gewähren (off-chain vorbereiten).

**B. Effects (state)**
- Berechne `(grossOut, fee, netOut)` via Quote-Formeln (docs/PSM_QUOTE_SEMANTICS.md).
- **Keine** 1kUSD-Erhöhung vor erfolgreichem Asset-Zufluss in Vault.
- Emittiere `FeeAccrued` *nach* erfolgreicher Verbuchung.

**C. Interactions**
1. **Ingress**: `safeTransferFrom(user -> Vault, amountIn)`.  
   - Über `Vault.deposit(tokenIn, user, amountIn)` damit FoT-Guard & Caps greifen.
2. **Mint**: `OneKUSD.mint(to, netOut)` (PSM hat MINTER-Role).
3. **Fees**: `Vault.deposit(tokenIn, address(this), fee)` oder interne Verrechnung:
   - *Empfohlen:* PSM verbucht Fee separat → `pendingFees[tokenIn] += fee`.

**D. Events**
- `SwapTo1kUSD(user, tokenIn, amountIn, fee, netOut, block.timestamp)`
- Vault `Deposit`, Token `Transfer` (mint).

**E. Failure atomicity**
- Falls `deposit` fehlschlägt → revert ohne Mint.
- Falls `mint` fehlschlägt (sollte nicht) → revert gesamte Transaktion.

---

## 4) `swapFrom1kUSD(tokenOut, amountIn, to, minOut, deadline)`
**A. Checks**
- Pre-Checks (oben) mit `tokenOut`.
- User 1kUSD `allowance(PSM) >= amountIn`.

**B. Effects**
- Berechne `(grossOut, fee, netOut)` in **tokenOut**-Einheiten.

**C. Interactions**
1. **Burn ingress**: `OneKUSD.burn(user, amountIn)` (PSM hat BURNER-Role).
2. **Egress**: `Vault.withdraw(tokenOut, to, netOut, "PSM_REDEEM")`.
3. **Fees**: `Vault.withdraw(tokenOut, treasury, fee, "TREASURY_SPEND")` **oder** accrual-bucket:
   - *Empfohlen:* Accrual im Vault (`pendingFees[tokenOut] += fee`) und später `sweepFees`.

**D. Inventory & Headroom**
- Vor `burn`: prüfen, ob `Vault.balanceOf(tokenOut) >= netOut + fee`. Sonst revert `INSUFFICIENT_LIQUIDITY`.

**E. Events**
- `SwapFrom1kUSD(user, tokenOut, amountIn, fee, netOut, block.timestamp)`
- Token `Transfer` (burn), Vault `Withdraw`.

---

## 5) Reentrancy & Ordering
- `nonReentrant` auf PSM-Swappfaden.
- Reihenfolge:
  - **To1k**: Checks → Compute → `Vault.deposit` → `mint` → Fee-Accrual.
  - **From1k**: Checks → Compute → `burn` → `Vault.withdraw(net)` → Fee-Accrual/Sweep.
- **No external callbacks** im PSM/Vault (keine Hooks), um Angriffsflächen zu minimieren.

---

## 6) Fehler & Custom Errors
- `UNSUPPORTED_ASSET`, `PAUSED`, `ORACLE_STALE`, `ORACLE_UNHEALTHY`, `DEVIATION_EXCEEDED`,
  `CAP_EXCEEDED`, `INSUFFICIENT_LIQUIDITY`, `SLIPPAGE`, `ACCESS_DENIED`, `ZERO_ADDRESS`.

---

## 7) Events (normativ)
- PSM:
  - `SwapTo1kUSD(user, tokenIn, amountIn, fee, minted, ts)`
  - `SwapFrom1kUSD(user, tokenOut, amountIn, fee, paidOut, ts)`
- Vault:
  - `Deposit(asset, from, amount)`, `Withdraw(asset, to, amount, reason)`, `FeeSwept`.

---

## 8) Invariants (Exec)
- Konsistenz: Exec-(gross,fee,net) == Quote für dieselben Inputs/Snapshot.
- Kein Mint/Burn ohne korrespondierende Vault-Bewegungen (oder Liquiditätscheck).
- Fee Conservation: Summe Fees → Treasury-Bucket (per asset).

---

## 9) Governance & Roles
- PSM benötigt `MINTER` und `BURNER` auf 1kUSD.
- Treasury-Adresse aus Registry (`PARAM_TREASURY_ADDRESS`).
- Fee-BPS & Limits aus Registry; nur via Timelock änderbar.

---

## 10) Test-Skizze (später)
- Unit: fee/rounding, slippage, errors.
- Integration: deposit→mint, burn→withdraw, insufficient liquidity.
- Invariants: conservation, supply bound, monotonicity.

