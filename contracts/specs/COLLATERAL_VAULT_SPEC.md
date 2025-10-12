# CollateralVault — Functional Specification

**Scope:** Non-custodial vault for approved stablecoins (e.g., USDC/USDT/DAI). No human withdrawals. All flows via protocol modules (PSM/Treasury).  
**Status:** Spec (no code). **Language:** EN.

---

## 1. Goals & Constraints
- Hold reserves for 1kUSD backing; expose views for **Proof of Reserves (PoR)**.
- Enforce **exposure caps** per asset (set by Safety-Automata).
- Support **protocol-only** withdrawals (PSM redeem path, DAO/Treasury spend).
- Precisely handle **decimals** (6/8/18 etc.) with normalized internal math (18-decimal accounting).
- Emit complete audit trail via events.

**Non-goals:** Accepting volatile assets (handled by AutoConverter). Lending/rehypothecation is out of scope.

---

## 2. Storage & Types (Conceptual)
- `approved[asset: address] -> bool`
- `balances[asset: address] -> uint256` (raw token decimals)
- `decimals[asset: address] -> uint8` (cached at first set/approval)
- Read-only link to Safety-Automata for `caps`.
- `treasury: address` (fee sink; stable stays in Vault until DAO spend).
- Optional `minReserveBufferBps` for spend guards (DAO policy).

---

## 3. Interfaces (High-Level)
### 3.1 Ingress
- `deposit(asset, from, amount)`  
  Path: user → PSM (or system) → Vault. Called by PSM/AutoConverter; reverts unless `msg.sender` is authorized module.

- `systemDeposit(asset, amount, source)`  
  For module-internal accounting (PSM fees). `source ∈ {"PSM","AUTOCONVERTER"}`.

**Both**:
- Require `approved[asset] == true`.
- Update `balances[asset] += amount`.
- Check **caps** after update: `balances[asset] ≤ cap(asset)`.

### 3.2 Egress
- `withdraw(asset, to, amount, reason)`  
  Allowed reasons: `"PSM_REDEEM"` or `"GOV_SPEND"`.
  - `"PSM_REDEEM"`: callable by PSM only; transfers `amount` out to user.
  - `"GOV_SPEND"`: callable by Treasury executor (Timelock) only; transfers to DAO target.

Guards:
- Sufficient balance after considering decimals.
- For `"GOV_SPEND"`, optional **buffer**: `postBalance ≥ minBuffer(asset)` if configured.

### 3.3 Admin (via DAO/Timelock)
- `setApprovedAsset(asset, enabled)`
- `setTreasury(address)`
- No direct setCap here — caps come from Safety-Automata.

---

## 4. Decimal Handling & Normalization
- Track `decimals[asset]` once; validate against token to prevent changes.
- Provide **normalized** read views:
  - `getNormalizedBalance(asset) -> uint256(1e18)`
  - `getTotalNormalizedUSD()` via OracleAggregator median (read-only), for dashboards only (non-authoritative for mint).

Conversions:
- `raw -> 18`: `raw * 10^(18 - d)`  
- `18 -> raw`: `norm / 10^(18 - d)` rounding **in favor of the protocol**.

---

## 5. Caps Enforcement
- On **deposit/systemDeposit**: check `balances[asset] + delta ≤ cap(asset)`.
- On **withdraw**: no cap check required (reduces exposure), but buffer policy may apply for `"GOV_SPEND"`.

---

## 6. Events (must match ONCHAIN_EVENTS.md)
- `Deposit(asset (indexed) address, from (indexed) address, amount uint256, ts uint256)`
- `SystemDeposit(asset (indexed) address, amount uint256, source (indexed) string, ts uint256)`
- `Withdraw(asset (indexed) address, to (indexed) address, amount uint256, reason (indexed) string, ts uint256)`
- `ExposureCapSet(asset (indexed) address, cap uint256, ts uint256)` *(emitted by Safety; Vault may mirror for UI in future)*
- `ExposureBreached(asset (indexed) address, requested uint256, cap uint256, ts uint256)`

---

## 7. Errors (non-exhaustive)
- `ASSET_NOT_APPROVED`
- `CAP_EXCEEDED`
- `INSUFFICIENT_BALANCE`
- `UNAUTHORIZED_CALLER`
- `INVALID_REASON`
- `DECIMAL_MISMATCH`

---

## 8. Security Considerations
- **No owner** funds path; only module-authorized routes.
- NonReentrant modifiers; pull patterns where applicable.
- Check-Effects-Interactions; external token calls after state updates.
- Oracle reads only for **views** (PoR); no mint authorization from Vault reads.

---

## 9. Testing Guidance
- Deposits trigger cap check; boundary conditions around cap and decimals.
- Withdraw path `"PSM_REDEEM"` vs `"GOV_SPEND"`; buffer policy if enabled.
- Reorg-safe balance verification (idempotent events).
- Fuzz decimal conversions (6/8/18) for rounding safety.

---

## 10. Invariants (xref: INVARIANTS.md)
- I1 Supply Bound (Vault USD value ≥ 1kUSD supply).  
- I5 Caps enforced on every deposit.  
- I16 No direct withdrawals except protocol paths.
