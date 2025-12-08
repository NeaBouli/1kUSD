# DEV-11 – Implementation backlog for Solidity track (r1)

## 1. Scope & constraints

This document defines a **high-level implementation backlog** for a future
Solidity developer track (e.g. DEV-31+) working on advanced BuybackVault and
StrategyEnforcement features.

Scope:

- Translate the DEV-11 planning docs into concrete, implementable tickets.
- Focus on **v0.52+** features (Advanced / Phase A and related telemetry).
- Keep the v0.51 baseline **unchanged** and stable.

Out of scope:

- Final parameter values (caps, ratios, time windows).
- Governance processes and UI integration.
- Indexer and dashboard implementation (separate tracks).

All items in this backlog are **proposals** and must be validated by
architects and economic reviewers before implementation.

## 2. Reference documents

The backlog assumes familiarity with the following docs:

- `docs/architecture/buybackvault_strategy_phase1.md`
- `docs/architecture/buybackvault_strategy_phaseA_advanced.md`
- `docs/architecture/economic_layer_overview.md`
- `docs/dev/DEV11_BuybackVault_EconomicAdvanced_Plan_r1.md`
- `docs/dev/DEV11_Telemetry_Events_Outline_r1.md`
- `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
- `docs/reports/DEV74-76_StrategyEnforcement_Report.md`

A future Solidity developer should treat this document as an index and
cross-check each ticket with the references above.

## 3. Proposed implementation tickets (high-level)

This section lists **candidate tickets** for a Solidity-focused DEV track.
Ticket IDs and exact numbering are illustrative and can be adapted.

### 3.1 DEV-31 – StrategyEnforcement Phase A rule set (core logic)

Goal:

- Implement the core rule set described in the Phase A advanced spec:
  treasury safety bounds, rolling caps, and basic market impact limits.

Key tasks (summary):

- Introduce configuration structures for:
  - per-asset and global buyback limits,
  - rolling-window caps (e.g. daily/weekly),
  - safe price bands derived from oracles.
- Integrate these checks into the StrategyEnforcement path used by
  BuybackVault operations.
- Ensure all checks are **fail-closed**: if data is missing or invalid,
  the operation is rejected.

Dependencies:

- Finalised Phase A spec (DEV-11 docs).
- Confirmation of which on-chain parameters are configurable vs. fixed.

### 3.2 DEV-32 – Guardian & emergency control integration

Goal:

- Implement clear on-chain levers for the Guardian / Safety role to
  restrict or pause advanced buyback behaviour.

Key tasks:

- Add Guardian-controlled flags or modes for:
  - global buyback pause,
  - tightened per-asset limits,
  - stricter slippage/price constraints in stress scenarios.
- Ensure mode changes are:
  - atomic and observable via events,
  - applied consistently across all relevant buyback paths.

Dependencies:

- Existing Guardian role definitions and access-control patterns.
- Alignment with StrategyEnforcement Phase A checks.

### 3.3 DEV-33 – Oracle health integration for buybacks

Goal:

- Make StrategyEnforcement aware of oracle health conditions and price
  quality signals.

Key tasks:

- Consume existing oracle health indicators:
  - staleness flags,
  - deviation checks,
  - aggregation guards.
- Define behaviour when oracle data is unhealthy:
  - reduce limits or reject operations.
- Emit clear reason codes when buybacks are rejected due to oracle issues.

Dependencies:

- Oracle aggregator and health guard specs.
- DEV-11 Telemetry & Events outline for reason codes.

### 3.4 DEV-34 – Telemetry & events for buyback decisions

Goal:

- Implement the minimal event surface needed for indexers to explain
  buyback decisions (executed, capped, rejected).

Key tasks:

- Define and emit events for:
  - attempted buyback operations (requested asset, size, side),
  - evaluation context (mode, limits, key parameters),
  - outcome (executed, partially executed, rejected).
- Align event fields with the Telemetry & Events outline.
- Ensure that event emission is consistent and does not leak
  sensitive internals beyond what is needed for monitoring.

Dependencies:

- DEV11_Telemetry_Events_Outline_r1.
- DEV-31 and DEV-33 decisions on rule structure and reason codes.

### 3.5 DEV-35 – Config & governance hooks (minimal surface)

Goal:

- Expose a minimal, well-defined configuration surface for governance
  to adjust advanced buyback parameters without breaking safety.

Key tasks:

- Identify which parameters must be adjustable (e.g. limits, caps,
  time windows) and which should remain hard-coded.
- Implement governance-approved setters with:
  - access control,
  - sanity checks,
  - events describing parameter changes.
- Ensure changes do not bypass StrategyEnforcement or weaken invariants.

Dependencies:

- Governance playbook and parameter governance docs.
- Finalisation of the Phase A parameter model.

## 4. Dependencies & sequencing

A possible execution order for the implementation track:

1. DEV-31 – core Phase A rule set
2. DEV-33 – oracle health integration
3. DEV-32 – Guardian / emergency control hooks
4. DEV-34 – telemetry & events
5. DEV-35 – governance configuration surface

This ordering favours a working, conservative rule set first, then
observability and governance control.

## 5. Review & sign-off process

Before any of the above tickets go into implementation:

- Architects and economic reviewers should:
  - validate the ticket wording,
  - confirm that no v0.51 semantics are unintentionally changed,
  - ensure that StrategyEnforcement Phase A remains compatible with
    existing reports and release notes.

After implementation, each ticket should:

- ship with unit and integration tests,
- update or extend the relevant docs (Phase A spec, Telemetry outline,
  governance/playbook),
- be reflected in release notes for the affected version line (v0.52+).

This backlog is intentionally conservative and should evolve as DEV-11
planning documents are refined.

## Progress – DEV-11 A01 (per-operation treasury cap)

- Implemented `maxBuybackSharePerOpBps` in `BuybackVault` (Phase A, per-operation treasury cap).
- Behaviour: when the cap is set > 0, any single buyback that would consume more than this share of the dedicated treasury reverts.
- Tests: to be added in a follow-up DEV-11 A01 tests task.

## DEV-11 A02 – Oracle/Health gate for buybacks (Phase A)

Status: planned

Summary:
- Enforce that buyback execution is only allowed when oracle health is "good" and guardian/safety flags allow buybacks.
- Integrate with existing oracle health/guardian signals without changing v0.51 baseline behaviour unless explicitly enabled.

Implementation hints:
- Introduce a dedicated check function in BuybackVault that is called from executeBuyback paths.
- Emit explicit events and/or use reason codes for blocked buybacks (oracle_stale, oracle_diff_too_large, guardian_block).

Expected deliverables:
- Solidity implementation in BuybackVault (or dedicated StrategyEnforcement helper).
- Foundry tests covering happy-path and blocked buybacks (oracle unhealthy, guardian stop).
- Telemetry entries wired into DEV11_Telemetry_Events_Outline_r1.md.


---

### DEV-11 A03 – Rolling window cap on cumulative buybacks

**Goal:** Limit the *cumulative* buyback volume over a rolling time window (e.g. 24h),
to prevent aggressive drain of the buyback treasury even if single-transaction caps
(DEV-11 A01) are respected.

**Implementation sketch (Solidity track):**

- Add accounting for cumulative buyback volume over a configurable window (e.g. 24h):
  - Track total stable spent for buybacks within the active window.
  - Track window start timestamp and reset / roll forward when the window elapses.
- Introduce DAO-only configuration for:
  - `maxBuybackSharePerWindowBps` (or similar) – percentage of the buyback treasury usable within one window.
  - `buybackWindowSeconds` – window length in seconds (e.g. 86400).
- Enforce the window cap in buyback execution paths:
  - Before executing a buyback, compute the *post-trade* cumulative volume for the current window.
  - If the cap would be exceeded, revert with a dedicated reason / error code and emit a telemetry event.
- Emit indexer-friendly events for:
  - Window cap updates (parameters).
  - Window reset / rollover.
  - Window cap breaches / prevented operations.
- Tests (Foundry):
  - Happy path: multiple buybacks within the window that stay below the cap.
  - Failure path: buyback that would exceed the window cap reverts with the expected reason.
  - Boundary cases:
    - Exactly at the cap.
    - Just after the window elapses (reset / new window).
    - Changing window parameters via DAO while a window is active.
- Non-goals:
  - No changes to core PSM logic.
  - No changes to oracle aggregation or guardian rules beyond using already exposed health / status signals.


- [x] DEV-11 A02 – oracle/health gate stub wired into BuybackVault (hook called from buyback execution paths; enforcement logic still TBD).

#### DEV-11 A02 – Enforcement wiring status (Phase A)

- [x] BuybackVault is now wired to an external oracle health module via:
  - `oracleHealthModule` (address) and `oracleHealthGateEnforced` (bool) state.
  - `setOracleHealthGateConfig(address newModule, bool newEnforced)` (DAO-only) with a ZERO_ADDRESS guard when enabling enforcement.
- [x] `_checkOracleHealthGate()` now:
  - short-circuits when `oracleHealthGateEnforced == false` (v0.51 behaviour preserved),
  - otherwise queries the external module and reverts with typed errors mirroring
    `BUYBACK_ORACLE_UNHEALTHY` and `BUYBACK_GUARDIAN_STOP` semantics.
- [ ] Dedicated BuybackVault tests for all enforcement modes (disabled / healthy / unhealthy / guardian-stop) – to be added in a follow-up DEV-11 A02 patch.


## DEV-11 A03 – Rolling Window Cap Enforcement (Status Update)

Status: **implemented in BuybackVault (Phase A)**

The BuybackVault now tracks cumulative buyback volume over a configurable rolling window
(`rollingWindowDuration` + `rollingWindowCapBps`) and enforces the cap in both
`executeBuyback` and `executeBuybackPSM`. When the cap would be exceeded, the call
reverts and the window accumulator is advanced to the current timestamp.

This keeps the per-operation cap (A01) and the oracle/health gate (A02) in place, while
adding a second dimension of protection against repeated buybacks in a short period of
time.

---

## DEV-11 Phase B – Telemetry & Test Expansion (Planning Only)

**Scope:**  
Phase B focuses on refining telemetry and test coverage for the existing safety layers A01–A03 in `BuybackVault` without introducing new contract features.

**Reference:**  
See `docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md` for details.

**Planned milestones:**

- **B01 – Telemetry Audit & Alignment**
  - Align Reason Codes and events with integrations and indexer docs.
- **B02 – Parameter Boundary Tests**
  - Expand tests around boundary values and governance profiles.
- **B03 – Scenario & Regression Tests**
  - Add multi-step scenario tests combining health gate and cap settings.

This section is intentionally planning-only and does not imply any active work beyond documentation until explicitly scheduled by the architect.

