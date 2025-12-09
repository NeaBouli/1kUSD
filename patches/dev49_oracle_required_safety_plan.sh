#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# 1) DEV-Doc für OracleRequired / PSM_ORACLE_MISSING Plan
cat << 'EOF_MD' > docs/dev/DEV49_OracleRequired_SafetyPlan_r1.md
# DEV-49 – OracleRequired Safety Plan (BUYBACK_ORACLE_REQUIRED / PSM_ORACLE_MISSING)

**Role:** Architecture / DEV-11 / DEV-9  
**Scope:** 1kUSD Economic Layer – PSM & BuybackVault oracle dependency model  
**Status:** r1 – planning / docs-only (no contracts changed yet)

---

## 1. Purpose

This document defines how 1kUSD must behave when **oracles are missing or misconfigured**, and how the new reason codes

- `BUYBACK_ORACLE_REQUIRED`
- `PSM_ORACLE_MISSING`

fit into the existing safety and telemetry model.

It is a **planning document** for future DEV-49 work (and related DEV-11 / DEV-9 steps).  
No Solidity changes are implied by this r1 version; it is the canonical reference for upcoming implementation.

---

## 2. Scope & non-goals

**In scope**

- Oracle dependency model for:
  - PegStabilityModule (PSM)
  - BuybackVault (A02 OracleGate)
  - OracleAggregator / Watcher / Guardian
- Behavioural expectations when:
  - no price feed is configured,
  - health is unhealthy,
  - strict vs legacy modes are active.
- Planned usage of:
  - `BUYBACK_ORACLE_REQUIRED`
  - `PSM_ORACLE_MISSING`
  - together with existing `BUYBACK_ORACLE_UNHEALTHY`.

**Out of scope (for this r1)**

- Concrete Solidity patches in `PegStabilityModule` or `BuybackVault`.
- CI / workflow changes.
- Full test details (these belong into the existing Phase B telemetry/test plan and future DEV-49 test specs).

---

## 3. Oracle dependency matrix (conceptual)

1kUSD is **not oracle-free**. The system assumes:

- A valid price feed is mandatory for the PSM.
- Oracle/health information is mandatory for strict buyback safety.
- Guardian / safety signals may additionally gate operations.

Conceptually:

| Component              | What it needs from oracle stack                            | Can run without price feed? | Notes                                     |
|------------------------|------------------------------------------------------------|-----------------------------|-------------------------------------------|
| PegStabilityModule     | Price feed (e.g. KAS/1kUSD) for mint/redeem limits & math | **No**                      | Stale/diff checks may be disabled, feed not |
| BuybackVault (A02)     | Health / guardian signals via `oracleHealthModule`        | In *legacy mode* only       | In strict mode: buybacks must fail-close  |
| OracleAggregator/Watcher | External prices, health computation                     | No (by definition)          | Upstream infra                            |
| Guardian / Safety      | Status flags, pause switches                              | Can be inactive, but if used must be respected | Integrated but separate concern |

Key points:

- It is allowed to **relax** stale/diff health checks in some modes.
- It is **not allowed** to run the PSM without *any* price feed.
- BuybackVault strict mode must treat a missing oracle/health module as a **hard error**, not as “silent legacy behaviour”.

---

## 4. Reason codes & error semantics

### 4.1 Existing / planned codes

We distinguish three layers of oracle-related signalling:

1. **Unhealthy oracle / health gate**

   - `BUYBACK_ORACLE_UNHEALTHY`
   - Thrown by BuybackVault when:
     - an oracle/health module is configured and enforced,
     - that module reports an unhealthy state.
   - Semantics:
     - “There is an oracle and it currently says: *do not buy back*.”

2. **Oracle required but missing (buybacks)**

   - `BUYBACK_ORACLE_REQUIRED` (new)
   - Planned behaviour:
     - In **strict buyback safety mode**, the BuybackVault **must not** operate without a configured oracle/health module.
   - Typical trigger:
     - `oracleHealthGateEnforced == true`
     - but `oracleHealthModule == address(0)` or equivalent misconfiguration.
   - Semantics:
     - “In this configuration, an oracle/health module is mandatory. None is present.”

3. **Oracle missing for PSM**

   - `PSM_ORACLE_MISSING` (new)
   - Planned behaviour:
     - PegStabilityModule must detect if no valid price feed is registered / resolvable.
   - Typical trigger:
     - No price feed configured in the parameter registry,
     - or a sentinel condition where the feed address / config is clearly invalid.
   - Semantics:
     - “Operating the PSM without a price feed is not a supported mode; fail-close.”

### 4.2 Relation to generic errors

- `ZERO_ADDRESS`
  - Signals generic parameter misuse (e.g. setter called with `address(0)`).
  - Should be reserved for pure argument validation, not for semantic “oracle missing” conditions in strict modes.
- Oracle-related reason codes
  - Are **semantic**, not low-level validation errors.
  - Should be used where a configuration *could in principle be valid* but violates mandatory oracle assumptions for a given mode.

---

## 5. Configuration modes (conceptual)

The following modes are used across docs and governance playbooks.

### 5.1 LEGACY_COMPAT (PSM + BuybackVault)

Goal: reproduce v0.51 behaviour as closely as possible while still acknowledging that a price feed is required.

- PSM:
  - Price feed **must** be configured.
  - Stale/diff checks may be set to relaxed values (e.g. large `maxStale`, `maxDiffBps`).
  - `PSM_ORACLE_MISSING` **must never fire** in a correct LEGACY_COMPAT setup.
- BuybackVault:
  - `oracleHealthGateEnforced = false`
  - `oracleHealthModule` may be `address(0)`.
  - No `BUYBACK_ORACLE_UNHEALTHY` / `BUYBACK_ORACLE_REQUIRED` reverts in normal operation.

### 5.2 STRICT_BUYBACK_SAFETY (BuybackVault)

Goal: enable strong safety for buybacks without changing core PSM semantics.

- PSM:
  - Same as LEGACY_COMPAT regarding mandatory price feed.
- BuybackVault:
  - `oracleHealthGateEnforced = true`
  - `oracleHealthModule` must be a valid module implementing `IOracleHealthModule`.
  - Misconfigurations:
    - If enforcement is on and module is unset:
      - Planned: revert with `BUYBACK_ORACLE_REQUIRED`.
    - If module reports unhealthy:
      - revert with `BUYBACK_ORACLE_UNHEALTHY`.

### 5.3 MISCONFIG_FAIL_CLOSE (PSM + BuybackVault)

This is not a separate “governance profile”, but the **expected behaviour under misconfiguration**:

- PSM:
  - If no price feed can be resolved:
    - planned behaviour: revert with `PSM_ORACLE_MISSING` for all mint/redeem operations.
  - Operators must treat this as a **configuration bug**, not as a runtime condition to be tolerated.
- BuybackVault:
  - If strict mode is enabled but a module is missing:
    - planned behaviour: revert buybacks with `BUYBACK_ORACLE_REQUIRED`.
  - If strict mode is disabled:
    - behaviour falls back to LEGACY_COMPAT, but this should be an explicit governance choice.

---

## 6. Forward-looking test & implementation plan (high level)

Concrete tests and code changes will be specified in:

- existing `DEV11_PhaseB_Telemetry_TestPlan_r1.md`, and
- future DEV-49 test specs and Solidity patches.

At a high level, we expect:

1. **PSM / OracleRegression tests**
   - Test that:
     - with no registered price feed, PSM calls revert with `PSM_ORACLE_MISSING`,
     - with a valid price feed, usual mint/redeem tests still pass.

2. **BuybackVault strict-mode tests**
   - Test that:
     - strict mode with missing module reverts with `BUYBACK_ORACLE_REQUIRED`,
     - strict mode with healthy module allows buybacks,
     - strict mode with unhealthy module reverts with `BUYBACK_ORACLE_UNHEALTHY`.

3. **Integration / invariant tests**
   - Cross-module checks that:
     - LEGACY_COMPAT is reachable via configuration,
     - STRICT_BUYBACK_SAFETY behaves deterministically and fail-close on misconfig.

---

## 7. Status & next steps

- This document is **docs-only**, intended as:
  - architectural reference for DEV-11, DEV-49 and DEV-9,
  - input for governance and release planning (DEV-87, DEV-94),
  - baseline for future tests.
- Next concrete steps will be:
  - extend the telemetry/test plan with concrete DEV-49 test cases,
  - introduce the new reason codes in Solidity in a controlled, well-tested patch series.

EOF_MD

# 2) Report-Index-Eintrag anhängen (falls noch nicht vorhanden)
if ! grep -q 'DEV49_OracleRequired_SafetyPlan_r1' docs/reports/REPORTS_INDEX.md; then
  cat << 'EOF_IDX' >> docs/reports/REPORTS_INDEX.md

- [DEV49_OracleRequired_SafetyPlan_r1](../dev/DEV49_OracleRequired_SafetyPlan_r1.md) – Planning document for BUYBACK_ORACLE_REQUIRED / PSM_ORACLE_MISSING and oracle dependency model.
EOF_IDX
fi

# 3) Log-Eintrag
echo "[DEV-49] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add OracleRequired safety plan (BUYBACK_ORACLE_REQUIRED / PSM_ORACLE_MISSING)" >> logs/project.log

echo "== DEV-49: OracleRequired safety plan written =="
