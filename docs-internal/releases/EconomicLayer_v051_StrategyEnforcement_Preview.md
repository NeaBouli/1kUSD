# Release Note – Economic Layer v0.51.0 + BuybackVault StrategyEnforcement (Phase 1 Preview)

## 1. Overview

This document summarizes the current status of the **Economic Layer v0.51.0**
and the new **BuybackVault StrategyEnforcement (Phase 1)** feature.

- **Economic Layer v0.51.0 (Baseline)**  
  Stable core including:
  - PegStabilityModule (PSM) with fees, spreads, limits and core flows.
  - Oracle layer (aggregator, watcher, health gates).
  - Guardian / SafetyAutomata integration.
  - BuybackVault core (fund / withdraw / executeBuyback).

- **BuybackVault StrategyEnforcement – Phase 1 (v0.52.x Preview)**  
  An *optional* policy guard on top of the existing BuybackVault logic.
  It is fully implemented and tested, but **disabled by default** and treated
  as a **preview feature** for v0.52.x.

As long as `strategiesEnforced == false`, the protocol behaves exactly like
the v0.51.0 baseline.

---

## 2. What changed in BuybackVault

### 2.1 Two-layer design

The BuybackVault now has a two-layer strategy design:

1. **StrategyConfig (v0.51.0 baseline)**

   - Storage: `StrategyConfig[] strategies`
   - DAO-managed configuration:
     - `asset` (buyback target token)
     - `weightBps` (weight in basis points)
     - `enabled` (boolean)
   - Event:
     - `event StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled);`
   - Purpose: configuration + telemetry. No hard enforcement.

2. **StrategyEnforcement Phase 1 (v0.52.x Preview)**

   New elements:

   - Flag:
     - `bool public strategiesEnforced;` (default: `false`)
   - Setter (DAO-only):
     - `setStrategiesEnforced(bool enforced)`
   - Event:
     - `event StrategyEnforcementUpdated(bool enforced);`

   Behaviour in `executeBuyback()` **when enforcement is ON**:

   - If `strategies.length == 0`:
     - Revert with `NO_STRATEGY_CONFIGURED()`.
   - If there is no enabled strategy for the vault asset:
     - Revert with `NO_ENABLED_STRATEGY_FOR_ASSET()`.

When `strategiesEnforced == false`, none of these additional checks are applied
and the behaviour matches v0.51.0.

---

## 3. Tests & CI

### 3.1 Test coverage

The following test suites cover the new behaviour:

- `BuybackVaultTest`  
  - Baseline behaviour (funding, withdrawals, executeBuyback, strategy config).
  - Constructor and invariant checks.

- `BuybackVaultStrategyGuardTest`  
  - Focused on the StrategyEnforcement Phase 1 logic:
    - `testExecuteBuybackRevertsWhenEnforcedAndNoStrategies()`
    - `testExecuteBuybackRevertsWhenEnforcedAndNoEnabledStrategyForAsset()`
    - `testExecuteBuybackSucceedsWhenEnforcedAndStrategyForAssetExists()`
    - plus the existing BuybackVault tests to ensure parity.

All tests pass with `forge test -vv`, together with the rest of the Economic
Layer (PSM, Oracles, Guardian, etc.).

### 3.2 CI integration

A dedicated workflow for the strategy guard tests exists:

- `.github/workflows/buybackvault-strategy-guard.yml`

Infra/CI integration is further documented in:

- `docs/logs/DEV78_Infra_CI_StrategyRisk_Docs_Checklist.md`
- `docs/logs/DEV79_Infra_CI_Inventory.md`
- `docs/logs/DEV79_Dev7_Infra_CI_Docker_Pages_Plan.md`

These documents are **read-only** baselines for future infra tickets.

---

## 4. Documentation links

The design and governance aspects of StrategyEnforcement are documented in:

- **Architecture**
  - `docs/architecture/buybackvault_strategy_phase1.md`
  - `docs/architecture/economic_layer_overview.md`
    - Section on “StrategyEnforcement – Phase 1 (v0.52.x Preview)”.

- **Governance**
  - `docs/governance/parameter_playbook.md`
    - How to treat `strategiesEnforced` as a DAO-controlled parameter.
    - Operational guidance for enabling/disabling the guard.

- **Indexer / Monitoring**
  - `docs/indexer/indexer_buybackvault.md`
    - Mapping of:
      - `strategiesEnforced`
      - `StrategyEnforcementUpdated`
      - `NO_STRATEGY_CONFIGURED`
      - `NO_ENABLED_STRATEGY_FOR_ASSET`
    - Interpretation of reverts as **policy-driven blocks**, not protocol bugs.

- **Status / Reports**
  - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
  - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
  - `docs/reports/DEV87_Governance_Handover_v051.md`
  - `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`

---

## 5. Backward compatibility

- With `strategiesEnforced == false`:
  - BuybackVault behaviour is identical to the v0.51.0 baseline.
  - No additional revert paths become active.
  - All previously-documented invariants and safety guarantees remain valid.

- Enabling StrategyEnforcement Phase 1 is an **opt-in governance action**:
  - The DAO explicitly calls `setStrategiesEnforced(true)`.
  - Monitoring should be updated to:
    - Track the flag value.
    - Alert on `StrategyEnforcementUpdated` events.
    - Surface policy-driven reverts in dashboards.

---

## 6. Recommended rollout

### Phase A – Baseline deployment (v0.51.0)

- Deploy the Economic Layer with:
  - `strategiesEnforced == false`.
- Use the docs and reports to:
  - Align governance, risk, and security teams.
  - Integrate indexer/monitoring views.

### Phase B – Governance review (towards v0.52.x)

- Conduct a dedicated review using:
  - `DEV74-76_StrategyEnforcement_Report.md`
  - `PROJECT_STATUS_EconomicLayer_v051.md`
  - Security & Risk docs:
    - `docs/security/audit_plan.md`
    - `docs/security/bug_bounty.md`
    - `docs/risk/proof_of_reserves_spec.md`
    - `docs/risk/emergency_depeg_runbook.md`
    - `docs/testing/stress_test_suite_plan.md`

- Define:
  - Preconditions for enabling `strategiesEnforced`.
  - Monitoring and alerting requirements.
  - Rollback plan (simply setting `strategiesEnforced` back to `false`).

### Phase C – Optional activation (v0.52.x)

- Treat `setStrategiesEnforced(true)` as:
  - A separate governance parameter vote.
  - A change that must be reflected in:
    - Release notes.
    - Status reports.
    - Dashboards.

---

## 7. Summary

- **Economic Layer v0.51.0** is the stable, mainnet-ready baseline.
- **StrategyEnforcement Phase 1** is:
  - fully implemented,
  - fully tested,
  - fully documented,
  - but kept **opt-in** to avoid altering baseline behaviour unintentionally.
- Governance, Risk, Security and Infra teams now have all artefacts required
  to decide *if and when* this guard should be activated in production.
