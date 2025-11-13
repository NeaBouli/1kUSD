#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-41 Patch 5: Add DEV41 report, index entry and status section =="

REPORT="docs/reports/DEV41_ORACLE_REGRESSION.md"
INDEX="docs/index.md"
STATUS="docs/STATUS.md"

# 1) DEV-41 Report anlegen (falls noch nicht vorhanden)
if [ ! -f "$REPORT" ]; then
  cp -n "$REPORT" "${REPORT}.bak.dev41p5" 2>/dev/null || true

  cat > "$REPORT" <<'RMD'
# DEV-41 — Oracle Regression Stability Report

## Scope

DEV-41 focuses on restoring and hardening the oracle and watcher test harness:

- OracleWatcher regression tests
- OracleAggregator constructor and dependency wiring
- ZERO_ADDRESS() revert root-cause and remediation
- Inheritance cleanup between OracleRegression_Base and OracleRegression_Watcher
- RefreshState / updateHealth behavior alignment with real contract semantics

## Changes

1. **Base test harness (OracleRegression_Base)**
   - Ensured that `mockSafety`, `mockRegistry`, and `mockAggregator` are created once and wired in a deterministic order.
   - Removed shadowing declarations and promoted shared fields into the base test layer.
   - Normalised constructor calls to use interface-typed arguments instead of raw `address(...)` casts.

2. **Watcher regression suite (OracleRegression_Watcher)**
   - Made the watcher tests rely on the base harness instead of re-deploying local instances.
   - Removed all shadowing fields (`watcher`, `safety`, `aggregator`, `registry`) from the child test.
   - Ensured that `setUp()` in the child uses the already initialised base state.

3. **ZERO_ADDRESS root-cause**
   - Original failing pattern: passing `address(0)` as the registry into the `OracleAggregator` constructor from the watcher regression test.
   - This violated constructor invariants and triggered `ZERO_ADDRESS()` reverts on setup.
   - Fix: route all watcher tests through the base harness, which always initialises registry, safety, and aggregator consistently.

4. **refreshState() behavior**
   - The original regression assertion assumed that `refreshState()` must not alter the health state.
   - In the current design, `refreshState()` is explicitly meant to re-evaluate oracle and safety state.
   - The test has been updated to assert that health reflects the propagated oracle/safety status after `refreshState()`.

## Outcome

- All oracle-related regression tests are green again.
- The watcher suite now reflects the intended behavior of `OracleWatcher` and `OracleAggregator`.
- Future changes to aggregator wiring and safety/registry dependencies can be implemented in the base harness with minimal risk of silent regressions.

RMD
  echo "✓ Created $REPORT"
else
  echo "Report $REPORT already exists, skipping creation."
fi

# 2) docs/index.md – DEV-41 Eintrag ergänzen
if [ -f "$INDEX" ]; then
  cp -n "$INDEX" "${INDEX}.bak.dev41p5" || true

  # Einfachen Abschnitt am Ende anhängen, um nichts Bestehendes zu zerstören
  cat >> "$INDEX" <<'IMD'

---

## DEV-41 — Oracle Regression Stability

- **Report:** `docs/reports/DEV41_ORACLE_REGRESSION.md`  
- Scope: OracleWatcher regression, OracleAggregator wiring, ZERO_ADDRESS root-cause analysis, refreshState behavior alignment, all oracle-related tests green.

IMD

  echo "✓ Updated $INDEX with DEV-41 section."
else
  echo "WARNING: $INDEX not found, skipping index update."
fi

# 3) docs/STATUS.md – DEV-41 Statusblock anhängen
if [ -f "$STATUS" ]; then
  cp -n "$STATUS" "${STATUS}.bak.dev41p5" || true

  cat >> "$STATUS" <<'SMD'

---

## DEV-41 — Oracle Regression (Watcher/Aggregator)

- **Status:** ✅ Completed  
- **Scope:**  
  - Fix ZERO_ADDRESS() reverts in oracle regression tests  
  - Normalize OracleAggregator constructor usage (admin, safety, registry)  
  - Clean inheritance and field ownership between OracleRegression_Base and OracleRegression_Watcher  
  - Align `refreshState()` regression test with actual health update semantics  
- **Report:** `docs/reports/DEV41_ORACLE_REGRESSION.md`

SMD

  echo "✓ Updated $STATUS with DEV-41 status section."
else
  echo "WARNING: $STATUS not found, skipping status update."
fi

echo "== DEV-41 Patch 5 complete =="
