# DEV-11 Phase B – Telemetry & Test Expansion for Buyback Safety

**Role:** DEV-11 (Solidity / Economic Layer)  
**Scope:** BuybackVault safety layers A01–A03 (Per-Op Cap, Health Gate, Rolling Window Cap)  
**Status:** Planning document for Phase B (no code changes yet)

---

## 1. Context & Phase A Recap

Phase A introduced three safety layers in `BuybackVault`:

- **A01 – Per-Op Treasury Cap**
  - Parameter: `maxBuybackSharePerOpBps`
  - Effect: caps the size of a *single* buyback operation as a share of treasury.
  - Behaviour: if cap > 0 and a buyback exceeds it, the operation reverts with `BuybackPerOpTreasuryCapExceeded()`.

- **A02 – Oracle / Health Gate**
  - Hook: `_checkOracleHealthGate()` invoked in all buyback paths.
  - Effect: consumes Oracle / Guardian health signals and can block buybacks under unhealthy conditions or explicit Guardian stop.
  - Behaviour: controlled via configuration; legacy-compatible mode remains available when enforcement is disabled.

- **A03 – Rolling Window Cap**
  - Parameters: window duration and maximum cumulative share of treasury within that window.
  - Effect: prevents many individually small buybacks from exceeding a configured cumulative limit.
  - Behaviour: when active, a new buyback may revert if the rolling sum for the current window would exceed the configured cap.

Phase A deliverables are:

- On-chain logic and tests in `contracts/core/BuybackVault.sol` and `foundry/test/BuybackVault.t.sol`.
- Status & governance docs:
  - `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md`
  - `docs/governance/buybackvault_parameter_playbook_phaseA.md`
- Telemetry & indexer integration:
  - `docs/integrations/buybackvault_observer_guide.md`
  - `docs/indexer/indexer_buybackvault.md`

Phase A is considered **functionally complete** and configurable. Phase B focuses on **refining telemetry and tests**, not on adding new features.

---

## 2. Objectives of Phase B

Phase B has three main goals:

1. **Telemetry Refinement**
   - Ensure that every relevant buyback outcome (success or failure due to A01–A03) is:
     - Observable via events and/or reason codes.
     - Unambiguous for indexers and monitoring systems.
     - Mapped consistently to the documentation in integrations and indexer guides.

2. **Test Expansion**
   - Extend test coverage to:
     - Cover boundary behaviour for all Phase-A parameters.
     - Demonstrate that Reason Codes / events line up with documented semantics.
     - Guard against regressions when parameter combinations change.

3. **Operational Clarity**
   - Provide enough examples and checks so that:
     - Governance can safely adjust parameters without guesswork.
     - Operators can correlate on-chain events to dashboards and alerts.
     - Auditors can quickly assess whether buyback safety is configured as intended.

Phase B **does not** introduce new on-chain safety mechanisms; it tightens the visibility and confidence around the existing ones.

---

## 3. Telemetry Workstream

### 3.1 Targets

Phase B will review and refine telemetry around:

- **Per-Op Cap (A01)**
  - Confirm that exceeding the per-op cap:
    - Reverts with the expected error.
    - Is reported with the documented Reason Code (e.g. `BUYBACK_TREASURY_CAP_SINGLE`) where applicable.
- **Health Gate (A02)**
  - Confirm that:
    - Oracle/health failures lead to the expected revert (`BUYBACK_ORACLE_UNHEALTHY`).
    - Guardian stops lead to the expected revert (`BUYBACK_GUARDIAN_STOP`).
    - Legacy-compatible mode preserves v0.51 behaviour when enforcement is disabled.
- **Rolling Window Cap (A03)**
  - Confirm that exceeding the window cap:
    - Reverts with the expected error.
    - Is reported with the documented Reason Code (e.g. `BUYBACK_TREASURY_CAP_WINDOW`) where applicable.

### 3.2 Planned Actions

- Cross-check implementation against:
  - `docs/integrations/buybackvault_observer_guide.md`
  - `docs/indexer/indexer_buybackvault.md`
  - `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md`
  - `docs/governance/buybackvault_parameter_playbook_phaseA.md`
- Align naming and spelling:
  - Reason Codes.
  - Event names and indexed fields.
- Identify and document any gaps, such as:
  - Missing Reason Codes for certain edge cases.
  - Ambiguous events that could benefit from additional fields.

---

## 4. Test Workstream

### 4.1 Coverage Goals

Phase B expands the test suite with the following focus:

1. **Boundary Tests for Phase-A Parameters**
   - A01:
     - Cap set to zero (disabled).
     - Cap set to a small percentage (e.g. 1%).
     - Behaviour exactly at the boundary vs. just above.
   - A02:
     - Health gate disabled vs. enabled.
     - Transitions between healthy/unhealthy oracle states.
     - Guardian stop toggling on/off and its effect on buybacks.
   - A03:
     - Rolling window with cap disabled vs. enabled.
     - Window crossing transitions (end-of-window behaviour).
     - Multiple buybacks filling the window up to the exact limit.

2. **Reason-Code Assertions**
   - Where Reason Codes are exposed in events or revert messages:
     - Assert that the expected code is emitted for:
       - Per-Op cap violations.
       - Rolling window cap violations.
       - Oracle unhealthy.
       - Guardian stop.
     - Ensure that no conflicting or misleading codes are emitted.

3. **Scenario-Based Regression Tests**
   - Compose multi-step scenarios combining:
     - Health gate changes.
     - Per-Op and window caps.
   - Verify that:
     - The resulting sequence of successful and failing buybacks matches expectations.
     - Telemetry (events / Reason Codes) fully explains the observed outcomes.

### 4.2 Suggested Test Locations

- Extend existing tests in `foundry/test/BuybackVault.t.sol` where reasonable.
- Add focused Phase-B specific tests in a new test file if needed, e.g.:
  - `foundry/test/BuybackVault_PhaseB_Telemetry.t.sol`
- Keep test files structured and labelled so that:
  - Phase-A core behaviour is easy to identify.
  - Phase-B telemetry-focused tests are clearly separated.

---

## 5. Milestones & Tasks

The following sub-tasks are suggested for DEV-11 Phase B:

- **B01 – Telemetry Audit & Alignment**
  - Review existing implementation against docs.
  - Fix naming inconsistencies and missing Reason Codes.
  - Update documentation where implementation is already correct.

- **B02 – Parameter Boundary Test Expansion**
  - Implement boundary tests for A01–A03 parameters.
  - Ensure that legacy-compatible profiles from the governance playbook are test-covered.

- **B03 – Scenario & Regression Tests**
  - Add multi-step scenario tests combining:
    - Health gate toggling.
    - Per-Op cap and rolling window cap.
  - Document the intended scenario flows in short comments above the tests.

Each milestone should:

- Include Foundry tests that run as part of the standard test suite.
- Avoid introducing new on-chain features or external dependencies.
- Produce at least one entry in `logs/project.log` summarising the change.

---

## 6. Non-Goals of Phase B

Phase B explicitly does **not** aim to:

- Introduce new strategies or additional safety layers in `BuybackVault`.
- Change the economic behaviour of existing Phase-A features.
- Modify the governance process or parameter set beyond clarifying telemetry.

Those topics are reserved for potential future phases (e.g. Phase C or separate DEV tracks).

---

## 7. Definition of Done for Phase B (High-Level)

Phase B can be considered complete when:

1. Telemetry around A01–A03 is:
   - Consistent with documented Reason Codes and events.
   - Sufficient for operators, indexers, and auditors to understand every blocked buyback.

2. The test suite:
   - Covers all relevant parameter boundaries and typical scenarios.
   - Guards against regressions in Phase-A behaviour and Reason-Code semantics.

3. Documentation:
   - References Phase B where applicable.
   - Clearly differentiates between Phase-A feature set and Phase-B telemetry/test refinements.

