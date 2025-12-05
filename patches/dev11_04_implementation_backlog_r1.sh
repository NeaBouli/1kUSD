#!/bin/bash
set -e

echo "== DEV-11 04: add implementation backlog for Solidity track (docs-only) =="

# 1) Ensure dev directory exists
mkdir -p docs/dev

# 2) Write implementation backlog skeleton
cat <<'EOD' > docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md
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
EOD

# 3) Link backlog from docs index (if present)
INDEX_FILE="docs/INDEX.md"
if [ -f "$INDEX_FILE" ]; then
  if ! grep -q "DEV11_Implementation_Backlog_SolidityTrack_r1" "$INDEX_FILE"; then
    cat <<'EOT' >> "$INDEX_FILE"

- [DEV11_Implementation_Backlog_SolidityTrack_r1](dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md) – High-level backlog for a future Solidity implementation track based on DEV-11 planning docs.
EOT
  else
    echo "docs/INDEX.md already links DEV11 implementation backlog"
  fi
else
  echo "docs/INDEX.md not found, skipping index link."
fi

# 4) Append log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-11 04] ${timestamp} Added DEV11_Implementation_Backlog_SolidityTrack_r1 (docs-only, no contract changes)" >> "$LOG_FILE"

echo "== DEV-11 04: Implementation backlog for Solidity track created (docs-only) =="
