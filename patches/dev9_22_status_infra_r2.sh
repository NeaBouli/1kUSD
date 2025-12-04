#!/bin/bash
set -e

echo "== DEV-9 22: add DEV9_Status_Infra_r2.md =="

mkdir -p docs/reports

cat <<'MD' > docs/reports/DEV9_Status_Infra_r2.md
# DEV-9 Infra / CI Status Report – r2

## 1. Scope

This report summarizes DEV-9 work on infrastructure, CI and docs
support **after** the initial r1 status, focusing on:

- Foundry CI hygiene
- Docs / linkcheck workflows
- DEV-9 operator guidance
- Minor bookkeeping fixes

Core protocol logic (Economic Layer, PSM, BuybackVault, Guardian) is
still **out of scope** for DEV-9 and remains untouched.

---

## 2. New Deliverables since r1

### 2.1 DEV9_Monitoring_Plan.md

- Documented which protocol events are relevant for:
  - BuybackVault execution & strategy enforcement
  - Oracle health and price updates
  - PSM core flows and limits
  - Guardian / SafetyAutomata rule violations
- Clarified that actual monitoring/indexer implementation is **out of
  this repo** and expected in a separate service or repo.

### 2.2 DEV9_Linkcheck_Workflow_v1.md

- Defined a **v1 policy** for docs link checking:
  - Separation between:
    - **Strict** areas (high-integrity docs such as security/risk/
      governance/indexer/architecture).
    - **Relaxed** areas (historical reports, logs, releases, dev notes).
  - External links are intended to be **non-fatal** (warnings only).
- This is a **planning document only** and does not change CI by itself.

### 2.3 docs/dev/README.md

- Added a small README for `docs/dev/` explaining:
  - Purpose of DEV-9 documents.
  - How architects and future dev roles can use this directory.
  - Pointers to key planning files and status reports.

### 2.4 DEV9_Backlog.md

- Introduced a structured backlog for DEV-9 work:
  - **Done**: initial onboarding, infra plan, workflows inventory,
    Foundry CI plan, linkcheck plan, monitoring plan, baseline Docker
    setup, manual docker build workflow, initial status report (r1),
    operator guide, forge CLI hygiene.
  - **Planned / Pending Architect**: rollout of Foundry version pinning,
    strict vs relaxed linkcheck policy in CI, optional Docker CI in PRs,
    concrete monitoring/indexer implementations.
- Backlog is explicitly meant as a **living document**.

### 2.5 Manual Docs Linkcheck Workflow

- Added `.github/workflows/docs-linkcheck.yml`:
  - Trigger: `workflow_dispatch` (manual only).
  - Current behavior: non-blocking linkcheck entry point for `docs/`,
    intended as a base for later strict/relaxed policies.
- Does **not** affect existing CI behavior for main or PRs.

### 2.6 DEV9_Operator_Guide.md

- New operator-facing guide under `docs/dev/DEV9_Operator_Guide.md`:
  - How to:
    - Run the **baseline Docker build** workflow.
    - Run the **docs linkcheck** workflow.
    - Interpret Foundry CI runs and failures.
  - Emphasizes that these workflows are:
    - Currently **manual**.
    - Scoped to infra/tests/docs only.
    - Not deploying contracts or changing on-chain state.

### 2.7 DEV-9 19 / 20 Bookkeeping Fix

- DEV-9 19 initially produced a syntax error in the patch script, but:
  - The **docs file** was created correctly.
  - The script and log entry were later fixed by DEV-9 20:
    - `patches/dev9_19_operator_guide.sh` made executable.
    - Missing `[DEV-9 19]` log line added in an idempotent way.
- Ensures reproducibility and consistent logging.

### 2.8 Forge CLI Flag Hygiene (DEV-9 21)

- Removed deprecated `--no-commit` flag from `forge install` invocations
  in CI workflows:
  - Modern forge versions no longer accept `--no-commit`.
  - Omitting the flag keeps the previous, desired behavior
    (dependencies added without auto-commit).
- This change:
  - Fixes a **hard CI error** for Foundry workflows.
  - Does **not** alter any on-chain logic or tests, only the install
    step.

---

## 3. Current Risk & CI Status

- **On-chain logic**:
  - Still untouched by DEV-9.
  - Economic Layer v0.51.0 (and BuybackVault StrategyEnforcement
    preview) remains as defined by previous DEV roles and the Architect.

- **CI (Foundry)**:
  - `forge install` step no longer fails due to deprecated flags.
  - Version pinning is present in at least one workflow; broader rollout
    is planned but requires explicit Architect/Owner approval.

- **Docs / MkDocs / Linkcheck**:
  - MkDocs builds and linkcheck behavior for main remain governed by
    DEV-7/93/94 decisions.
  - DEV-9 added:
    - A manual docs-linkcheck workflow.
    - Planning documents for strict/relaxed areas.
  - No automatic enforcement of strict/relaxed policies has been wired
    into CI yet.

- **Docker**:
  - Baseline Dockerfile and manual CI workflow exist.
  - Still **manual-only**, no PR/auto builds; future integration is
    explicitly marked as backlog.

---

## 4. Recommended Next Steps (for Architect / Co-Architect)

1. **Decide on Foundry pinning rollout**:
   - Approve or adjust DEV-9's plan for pinning Foundry versions across
     all relevant workflows (B1 in DEV9_Backlog).

2. **Decide on linkcheck strict/relaxed rollout**:
   - Approve a staged approach where:
     - Strict linkcheck is applied only to high-integrity docs.
     - Relaxed mode is used for historical/archived areas.
   - Map this policy into the manual docs-linkcheck workflow first.

3. **Clarify scope for Docker in CI**:
   - Decide if/when a non-blocking Docker build should be added to PR CI
     (B3 in DEV9_Backlog).

4. **Create a dedicated Monitoring / Indexer role**:
   - For example: DEV-10 Monitoring Engineer
   - Based on DEV9_Monitoring_Plan, BuybackVault reports, and security
     docs.

DEV-9 remains focused on **infra, CI and docs support**, without
changing core protocol behavior, until further instructions are given.
MD

# 2) Log-Eintrag
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 22] ${timestamp} Added DEV9_Status_Infra_r2.md" >> "$LOG_FILE"

echo "== DEV-9 22 done =="
