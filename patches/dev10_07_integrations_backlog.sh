#!/bin/bash
set -e

echo "== DEV-10 07: create DEV10_Backlog.md for integrations work =="

BACKLOG_FILE="docs/dev/DEV10_Backlog.md"

mkdir -p "docs/dev"

cat <<'EOD' > "$BACKLOG_FILE"
# DEV-10 Backlog – Integrations & Developer Experience

This backlog tracks work owned by DEV-10 around integrations and developer
experience for the 1kUSD Economic Core.

DEV-10 is **documentation-only**:

- no contract changes,
- no changes to Economic Layer logic,
- no CI/Docker modifications,
- focus on guides, examples and integration patterns.

---

## 1. Scope & Principles

- Keep external integrators focused on:
  - how to call public contracts safely,
  - how to interpret events and states,
  - how to monitor and operate integrations.
- Avoid:
  - duplicating architecture specs,
  - introducing protocol behaviour changes via docs.

---

## 2. Completed (r1)

- DEV-10 01 – Integrations docs skeleton & index
- DEV-10 02 – PSM Integration Guide (v1)
- DEV-10 03 – Oracle Aggregator Integration Guide (v1)
- DEV-10 04 – Guardian & Safety Events Integration Guide (v1)
- DEV-10 05 – BuybackVault Observer Integration Guide (v1)
- DEV-10 06 – DEV10_Status_Integrations_r1.md

---

## 3. Planned – r2 (content deepening)

These items are **not started** yet and require explicit Architect/Owner go.

### 3.1 PSM Integration Guide (r2)

- Add concrete examples for:
  - swap flows (collateral → 1kUSD, 1kUSD → collateral),
  - handling limits and reverts.
- Provide suggested UX patterns for:
  - displaying fees/spreads,
  - explaining swap failures to end-users.

### 3.2 Oracle Aggregator Guide (r2)

- Add example call patterns (read-only clients, indexers).
- Document typical stale/diff scenarios with timelines.
- Provide suggestions for:
  - retries,
  - fallback behaviour,
  - alerting thresholds.

### 3.3 Guardian & Safety Events Guide (r2)

- Add example event schemas for indexers.
- Provide recommended severity mapping for key events.
- Outline runbook templates for operators.

### 3.4 BuybackVault Observer Guide (r2)

- Add example dashboards / KPIs:
  - buyback frequency,
  - funding vs. execution,
  - strategy-level views.
- Suggest alert rules for abnormal patterns.

---

## 4. Possible future items (r3+)

These are **ideas only**, not commitments:

- Code snippets for common client stacks (where appropriate).
- Example indexer configurations (schemas, queries).
- End-to-end walkthroughs:
  - “Integrating a front-end swap widget with the PSM”
  - “Building a minimal monitoring stack for BuybackVault”.

All future work must stay aligned with:

- Economic Layer versioning (v0.51.0, StrategyEnforcement Phase 1),
- Security & Risk documentation,
- Governance decisions recorded in the reports section.
EOD

# Log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 07] ${timestamp} Created DEV10_Backlog.md for integrations & DevEx work" >> "$LOG_FILE"

echo "== DEV-10 07 done =="
