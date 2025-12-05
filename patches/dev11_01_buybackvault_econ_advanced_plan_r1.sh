#!/bin/bash
set -e

echo "== DEV-11 01: add BuybackVault & Economic Layer Advanced Plan r1 (docs-only) =="

# 1) Ensure dev directory exists
mkdir -p docs/dev

# 2) Write DEV-11 planning doc (skeleton)
cat <<'EOD' > docs/dev/DEV11_BuybackVault_EconomicAdvanced_Plan_r1.md
# DEV-11 – BuybackVault & Economic Layer Advanced (Plan r1)

## 1. Scope & constraints

This document defines the **planning scope** for advanced buyback and
economic-layer features beyond the current v0.51 / v0.52 baseline.

Scope:

- Describe potential advanced behaviour for the BuybackVault and the
  wider economic layer.
- Focus on **concepts and phases**, not on Solidity implementation.
- Target version line: **v0.52+**, leaving v0.51 as the reference baseline.

Constraints:

- **No contract or CI changes** are introduced by DEV-11.
- v0.51 release notes and reports remain valid and unchanged.
- StrategyEnforcement and any advanced mechanisms must be designed as
  *extensions*, not retroactive rewrites of existing behaviour.

This document is a living plan. Future DEV-11 tickets may refine, split
or extend the ideas captured here.

## 2. Current state summary (short)

At the time of this plan:

- The **v0.51 economic layer** and BuybackVault behaviour are defined and
  documented in existing architecture and release reports.
- A first phase of buyback strategy ("Phase 1") is described in the
  BuybackVault strategy documents, including:

  - which assets are eligible for buybacks,
  - how flows are structured between vaults and PSM,
  - the basic safety expectations.

- StrategyEnforcement has been introduced conceptually as a way to
  validate certain protocol actions (including buybacks) against a set
  of rules, with Guardian and Governance roles already defined elsewhere.

DEV-11 builds on this state and prepares **advanced phases** without
changing the meaning of existing v0.51 behaviour.

## 3. Advanced goals (high-level)

DEV-11 is motivated by the need for more **expressive** and **observable**
buyback behaviour, while keeping safety and peg stability central.

High-level goals include:

- More expressive buyback strategies:

  - ability to encode time windows, budgets and per-asset rules,
  - clearer distinction between "normal" and "stress" regimes.

- Stronger and more explicit safety bounds:

  - caps on treasury usage over defined windows,
  - clear invariants that can be reasoned about in audits and reports.

- Better observability:

  - design buyback behaviour so that indexers and dashboards can explain
    *why* an operation was allowed, limited or rejected.

- Governance clarity:

  - clear hooks for Governance and Guardian to adjust parameters,
  - explicit documentation of who can change what and under which
    conditions.

These goals are aspirational; DEV-11 does not commit to a final design
in a single step, but defines a structured path.

## 4. Potential phases (conceptual)

To keep complexity manageable, DEV-11 assumes that advanced behaviour
will be introduced in **phases**, for example:

- **Phase A – StrategyEnforcement hardening**

  - use StrategyEnforcement to encode explicit bounds on buyback volume,
    treasury usage and basic market-safety constraints,
  - clarify activation / deactivation rules and Guardian controls.

- **Phase B – Telemetry & events**

  - introduce or refine events and reason codes so that off-chain systems
    can reconstruct buyback decisions,
  - define minimal data that indexers and dashboards should expect.

- **Phase C – Multi-asset / multi-collateral planning (concept only)**

  - explore how buyback logic could evolve in a world with multiple
    collateral assets, markets or venues,
  - stay strictly at the planning level; no commitment to a specific
    multi-asset design in DEV-11.

The exact naming and scope of these phases can be revisited by the
architects; DEV-11 uses this structure to organise future tickets and
discussions.

## 5. Open questions & dependencies

DEV-11 deliberately collects open questions instead of resolving them
all at once. Examples:

- Which metrics (treasury ratios, peg health, oracle health) should act
  as hard gates for advanced buybacks?
- How much configurability should be on-chain parameters vs. rarely
  changed, audited logic?
- Which external monitoring / dashboard stack is assumed, and what is
  the minimum telemetry they need?
- How should responsibilities between Governance, Guardian and Operator
  roles be split for:

  - changing parameters,
  - activating or deactivating advanced modes,
  - reacting to stress scenarios?

Dependencies:

- Existing economic-layer docs (economic overview, PSM & BuybackVault).
- Existing reports on StrategyEnforcement and guardian/oracle behaviour.
- Future DEV-11 tickets that will define:

  - a detailed Phase A spec (StrategyEnforcement hardening),
  - a telemetry and events outline,
  - implementation prompts for a dedicated Solidity developer.

This Plan r1 is a starting point. It should be refined in collaboration
with architects and economic reviewers before any implementation work
begins.
EOD

# 3) Link from docs/INDEX.md under a DEV-11 / Advanced section

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

# 4) Append log entry

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-11 01] ${timestamp} Added DEV11_BuybackVault_EconomicAdvanced_Plan_r1 planning doc (docs-only, no contract changes)" >> "$LOG_FILE"

echo "== DEV-11 01: BuybackVault & Economic Layer Advanced Plan r1 created (docs-only) =="
