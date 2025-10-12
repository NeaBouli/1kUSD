# Treasury — Functional Specification

**Scope:** Accounting sink for protocol fees (primarily stablecoins from PSM and, later, AutoConverter). Controlled by DAO/Timelock. No discretionary withdrawals.
**Status:** Spec (no code). **Language:** EN.

---

## 1. Goals
- Accrue protocol fees **in Vault** (stablecoins) with transparent accounting.
- Execute DAO-approved spends via Timelock to recipient addresses for audits, bounties, ops.
- Publish on-chain and indexer-friendly **spend proposals** and executions.

## 2. Sources of Funds
- **PSM fees:** stablecoins retained in Vault; Treasury has an **accounting balance** per asset.
- **Converter fees:** initially 0; future stable fees accrue similarly.
- Other sources (donations/grants) via dedicated deposit path.

## 3. Accounting Model
- `balances[asset]` (accounting only; Vault actually holds tokens).
- On fee accrual: `FeeAccrued(source="PSM"|"...", asset, amount)`; Treasury increases accounting balance.
- On spend: Timelock-authorized call instructs **Vault.withdraw(asset, to, amount, reason="GOV_SPEND")`; Treasury reduces accounting balance.

## 4. Interfaces (High-Level)
- `proposeSpend(asset, amount, to, ref)` → emits `SpendProposed(id, asset, amount, to)`. (May be implicit in Governance UI; optional.)
- `executeSpend(id)` → callable **only** by Timelock/Executor; triggers Vault withdrawal and emits `SpendExecuted`.
- Views: `getBalance(asset)`, `listSpends(status?)`.

## 5. Events (align with ONCHAIN_EVENTS.md)
- `FeeAccrued(source, asset, amount, ts)` (emitted upstream; Treasury observes)
- `SpendProposed(id, asset, amount, to, ts)`
- `SpendExecuted(id, asset, amount, to, ts)`

## 6. Guards
- Optional **min reserve buffer** in Vault before spends (policy).
- Assets limited to approved stables.
- No EOAs with withdraw privilege; Timelock only.

## 7. Testing Guidance
- Accounting mirrors Vault movements; invariants hold across reorgs.
- Spend failure recovery (idempotent exec or cancel).
