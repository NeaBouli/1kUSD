#!/bin/bash
set -e

echo "== DEV-11 01: add BuybackVault & Economic Layer Advanced Plan r1 (docs-only) =="

# 1) Ensure dev docs directory exists
mkdir -p docs/dev

# 2) Write planning document
cat <<'EOD' > docs/dev/DEV11_BuybackVault_EconomicAdvanced_Plan_r1.md
# DEV-11 – BuybackVault & Economic Layer Advanced (Plan r1)

## 1. Scope & constraints

This document captures a **planning-only** view for advanced
BuybackVault and Economic Layer features beyond the current v0.51 / v0.52
baseline.

Scope:

- Describe possible **advanced buyback strategies** and economic
  extensions at a conceptual level.
- Align these ideas with existing components:
  - Economic Layer v0.51 baseline
  - StrategyEnforcement (v0.52 preview)
  - Guardian / Safety and Oracle stack
- Produce a **roadmap-style outline** that future implementation roles
  (e.g. Solidity dev tickets) can follow.

Constraints:

- Economic Layer v0.51 is treated as a **frozen baseline** in this plan.
- No changes to existing contracts or deployed semantics are introduced
  by this document.
- StrategyEnforcement v0.52 is considered an **opt-in feature preview**,
  not the default production mode yet.
- DEV-11 is **docs-only**:
  - no Solidity modifications,
  - no CI / workflow changes,
  - no new releases or tags.

Goal:

- Provide a clear, architect-level view of where BuybackVault and the
  broader Economic Layer could evolve next, without touching code.

## 2. Current state summary (short)

This section is a compact pointer to the existing state of the Economic
Layer and BuybackVault, so that DEV-11 does not re-invent definitions.

Key references (non-exhaustive):

- `docs/architecture/economic_layer_overview.md`
  - High-level picture of the Economic Layer around the PSM, Oracle
    stack, Guardian/Safety, and Vaults.
- `docs/architecture/buybackvault_strategy_phase1.md`
  - Phase 1 buyback strategy design, including basic execution rules,
    triggers, and interactions with the PSM.
- Reports:
  - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
  - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
  - and related v0.51 / v0.52 release documents.

Current state (very short summary):

- v0.51 defines the **baseline** Economic Layer with a working PSM,
  Oracle Aggregator, Guardian/Safety automata and BuybackVault.
- BuybackVault Phase 1 has a defined strategy and execution path, but is
  intentionally conservative and focused on safety and clarity.
- StrategyEnforcement v0.52 adds a preview mechanism for more structured
  enforcement around strategies and parameter changes, but is not yet
  the default production mode.
- Indexer / monitoring / telemetry aspects are partially documented but
  not fully exploited for advanced strategy design.

DEV-11 builds **on top of this baseline**, without contradicting or
rewriting the existing specs.

## 3. Advanced goals (high-level)

The term "Advanced" in this context is **not** about making the system
more magical or opaque. It is about:

- Increasing **expressivity** of buyback strategies while preserving
  safety and observability.
- Making BuybackVault behaviour **better observable** for off-chain
  indexers, dashboards and governance decision makers.
- Preparing the Economic Layer for possible **multi-asset / multi-
  collateral** scenarios in future versions (concept-only at this stage).
- Clarifying the **governance hooks** around who may adjust strategies,
  limits and schedules, and under which safety constraints.

Concrete high-level goals that DEV-11 should outline:

1. **Strategy expressivity**
   - Support for more nuanced buyback patterns:
     - time-windowed execution (e.g. only in certain blocks / epochs),
     - weighted distribution over multiple venues / assets,
     - configurable intensity or throttling of buybacks.
2. **Telemetry & observability**
   - Clear event model for:
     - planned vs executed buyback actions,
     - state transitions in BuybackVault strategies,
     - any deviations from the planned schedule (e.g. Guardian
       overrides, safety halts).
3. **Future multi-asset awareness (conceptual)**
   - How BuybackVault might conceptually deal with:
     - multiple collateral assets,
     - multiple target assets,
     - cross-PSM / cross-vault coordination.
4. **Governance clarity**
   - Clear responsibilities and permissions:
     - which roles may set or update strategies,
     - which parameters are "economic" vs "technical",
     - how StrategyEnforcement and Guardian interact with those
       decisions.

DEV-11 does **not** implement these goals, but should outline them in a
way that later DEV-blocks can translate into concrete specs and
contracts.

## 4. Potential phases for Advanced work

This section sketches a possible phased approach for future DEV-blocks
beyond DEV-11. Exact naming and ticket numbers are intentionally kept
open.

### Phase A – StrategyEnforcement activation & safety bounds

Focus:

- Decide how and when StrategyEnforcement v0.52 becomes:
  - enabled for BuybackVault-related parameters, and/or
  - required for certain strategy changes.
- Define **safety bounds** around:
  - what kind of strategy changes are allowed without deep review,
  - what requires explicit governance decisions,
  - how Guardian can intervene.

Questions for Phase A (to be detailed later):

- Should there be a notion of "staged" strategy deployment (preview →
  active → archived)?
- How do we log and expose strategy changes for later audits?
- Which minimal checks must always pass before a new strategy becomes
  active?

### Phase B – Telemetry & indexer-focused events

Focus:

- Design an event and data model that allows off-chain indexers and
  dashboards to:
  - reconstruct buyback execution history,
  - understand the current and past strategies,
  - detect anomalies or unexpected patterns.

Examples of potential event categories:

- Strategy lifecycle events:
  - created, updated, activated, deactivated.
- Execution events:
  - planned vs executed amounts,
  - partial executions due to limits or market conditions,
  - failure / revert reasons (where applicable).
- Oversight events:
  - Guardian interventions,
  - emergency halts,
  - parameter freezes.

Goal of Phase B:

- Make BuybackVault behaviour **transparent enough** that it can be
  monitored and explained to governance, integrators and external
  stakeholders.

### Phase C – Multi-asset / multi-collateral aware planning (concept-only)

Focus:

- Conceptually explore how the Economic Layer and BuybackVault could
  evolve in a world where:
  - more than one collateral asset is supported,
  - more than one "target" asset for buybacks exists,
  - there may be multiple PSM instances or vaults.

Constraints for Phase C:

- DEV-11 should treat this as a **forward-looking concept**, not a
  near-term implementation plan.
- Any multi-asset design must:
  - respect the existing v0.51 / v0.52 invariants,
  - not compromise safety for speculative complexity,
  - clearly document assumptions about governance capacity and
    operational overhead.

Output from Phase C (for later DEV-blocks):

- A list of potential models (e.g. "portfolio-style" buybacks, priority
  lists, or threshold-based diversification).
- Pros/cons at a high level, without committing to a specific path.

## 5. Open questions & dependencies

This section collects open questions and explicit dependencies on other
documents or DEV-blocks. It is expected to grow as DEV-11 matures.

### 5.1 Open questions

Examples (to be refined):

- **Time-based strategies**
  - Do we allow on-chain time-based / epoch-based strategy changes?
  - If yes, how do we prevent abusive or overly complex schedules?
- **Guardian vs strategy autonomy**
  - How strong should Guardian's override powers be regarding
    BuybackVault behaviour?
  - Should Guardian be able to force a "safe default" strategy in case
    of anomalies?
- **Granularity of parameters**
  - Which parameters are expected to be adjusted often (e.g. thresholds,
    frequency)?
  - Which parameters should be considered static or rarely changed?
- **Interaction with governance processes**
  - What kind of governance process (off-chain / on-chain) do we assume
    for adopting new strategy templates?
  - How are risk assessments and economic analysis fed back into
    strategy updates?

### 5.2 Dependencies

DEV-11 depends conceptually on:

- Existing architecture docs and reports:
  - Economic Layer overview
  - BuybackVault Phase 1 design
  - StrategyEnforcement reports and release notes
- Future DEV-blocks for:
  - formalising StrategyEnforcement activation policies,
  - defining telemetry events and indexer integration,
  - exploring multi-asset models in more detail.

This Plan r1 does **not** attempt to settle those dependencies. Instead,
it provides a structured, architect-level view that later DEV-blocks can
turn into concrete specifications and implementations.
EOD

# 3) Link from docs/INDEX.md (Economic Layer – Future / Advanced)

INDEX_FILE="docs/INDEX.md"
if [ -f "$INDEX_FILE" ]; then
  if ! grep -q "DEV11_BuybackVault_EconomicAdvanced_Plan_r1" "$INDEX_FILE"; then
    cat <<'EOT' >> "$INDEX_FILE"

## Economic Layer – Future / Advanced (DEV-11)

- [DEV11_BuybackVault_EconomicAdvanced_Plan_r1](dev/DEV11_BuybackVault_EconomicAdvanced_Plan_r1.md) – Planning document for advanced buyback and economic layer features beyond v0.51/v0.52 (docs-only).
EOT
  else
    echo "docs/INDEX.md already links DEV11_BuybackVault_EconomicAdvanced_Plan_r1"
  fi
else
  echo "docs/INDEX.md not found, skipping index link."
fi

# 4) Optional cross-link from buybackvault_strategy_phase1.md

STRAT_FILE="docs/architecture/buybackvault_strategy_phase1.md"
if [ -f "$STRAT_FILE" ]; then
  if ! grep -q "DEV11_BuybackVault_EconomicAdvanced_Plan_r1" "$STRAT_FILE"; then
    cat <<'EOS' >> "$STRAT_FILE"

---

_For planned advanced phases beyond StrategyEnforcement v0.52, see  
`docs/dev/DEV11_BuybackVault_EconomicAdvanced_Plan_r1.md` (DEV-11 planning document, docs-only, no contract changes)._
EOS
  else
    echo "buybackvault_strategy_phase1.md already references DEV11 plan"
  fi
else
  echo "buybackvault_strategy_phase1.md not found, skipping cross-link."
fi

# 5) Append log entry

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-11 01] ${timestamp} Added DEV11_BuybackVault_EconomicAdvanced_Plan_r1 planning doc (no contract changes)" >> "$LOG_FILE"

echo "== DEV-11 01: BuybackVault & Economic Layer Advanced Plan r1 created (docs-only) =="
