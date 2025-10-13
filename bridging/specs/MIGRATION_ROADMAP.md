# Migration Roadmap — EVM → Kasplex → Kaspa L1
**Scope:** Phases, readiness criteria, and responsibilities for moving from initial EVM deployment to Kasplex and later Kaspa L1.  
**Status:** Spec (no code). **Language:** EN.

## Phase 0 — EVM Launch (current)
- Protocol live on EVM L2 (PSM, Vault, Safety, Oracles, Token, DAO/Timelock).
- Indexer, telemetry, CI, docs complete.

**Exit Criteria**
- Security: no Critical/High open (DEV13/18).
- Liquidity: ≥ X mm USD PoR; peg deviation p95 < 30 bps over 30d.
- Ops: release process rehearsed (DEV16).

## Phase 1 — Kasplex Integration (bridge-listed token)
- Provide **canonical 1kUSD** on Kasplex via trusted bridge partner or canonical lock/mint (TBD).
- Maintain single canonical supply registry; prevent double-mint.

**Tasks**
- Bridge adapter spec (this repo), partner due diligence, mint/burn hooks.
- Indexer support on Kasplex; SDK chain configs.

**Exit Criteria**
- Canonical mapping published; addresses.json updated.
- Peg parity on both sides (arbitrage via PSM/bridge fees).
- Operational runbook for reorg/finality mismatch.

## Phase 2 — Kasplex Native Modules (progressive port)
- Port **read-only** views first (PoR/Oracle).
- Port **PSM** with Kasplex-compatible Vault; keep EVM as backup.

**Exit Criteria**
- Safety equivalence: pause/caps/rate-limits mirrored.
- Invariant tests on Kasplex testnet pass (subset of DEV13).

## Phase 3 — Kaspa L1 (subject to smart-contract availability)
- Re-implement core modules with Kaspa-native primitives.
- Data/model compatibility maintained for indexers.

**Exit Criteria**
- Audit sign-off; governance approves cutover plan.
- Canonical supply transfer ceremony (see CUTOVER_PROTOCOL.md).

## Canonical Supply & Symbol Policy
- Single **canonical 1kUSD** per chain; registry lists chainId↔address.
- Off-ramps must honor finality and rate-limits; UI enforces safeness.

## Rollback Strategy
- Pause mint on target chain; keep redemptions active on source.
- Failsafe: revert to source PSM-only mode until issue resolved.

## Governance
- DAO/Timelock controls bridge allowlists, cutover timetables, caps.
- All changes via on-chain proposal with public review window.
