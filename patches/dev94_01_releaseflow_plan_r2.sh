#!/bin/bash
set -e

echo "== DEV-94 01: add DEV94_ReleaseFlow_Plan_r2 skeleton =="

# 1) Ensure dev docs directory exists
mkdir -p docs/dev

# 2) Write DEV94 Release Flow plan skeleton
cat <<'EOD' > docs/dev/DEV94_ReleaseFlow_Plan_r2.md
# DEV-94 Release Flow Plan (r2)

## 1. Current state (as of v0.51.x)

This section describes what already exists in the repository for releases
and status tracking.

### 1.1 Release status script

- Script: `scripts/check_release_status.sh`
- Purpose:
  - Verify that key status and report files are present and non-empty before
    creating a release tag.
- Currently checked documents (non-exhaustive, but canonical set):
  - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
  - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
  - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
  - `docs/reports/DEV87_Governance_Handover_v051.md`
  - `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
  - `docs/reports/DEV93_CI_Docs_Build_Report.md`

### 1.2 Reports and block documentation

- Economic and strategy reports:
  - Economic Layer status (v0.51.x)
  - BuybackVault economic layer (DEV60–72)
  - Strategy enforcement (DEV74–76)
  - Governance handover (DEV87)
- Security & Risk / Sync:
  - Dev7/Dev8 security sync report (DEV89)
  - CI & docs build report (DEV93)
- Block-level report:
  - `docs/reports/BLOCK_DEV9_DEV10_Infra_Integrations_r1.md`
    (Infra & Integrations block, DEV-9 / DEV-10)

### 1.3 CI and local helpers

- CI:
  - Foundry workflow with pinned toolchain version.
  - Docs-build workflows using `mkdocs build` (no `--strict`).
  - Optional docs linkcheck workflow (manual, not gating).
- Local helper:
  - `patches/dev9_34_dev_ci_smoketest.sh`:
    - Runs `forge test`
    - Runs `mkdocs build`
    - Executes `scripts/check_release_status.sh`
    - No contract or configuration changes (local smoke test only).

## 2. Target release flow (high-level)

This section defines the intended release flow for v0.51.x and follow-up
versions (v0.52.x, etc.). It is descriptive and does not yet prescribe
exact CI YAML or tagging automation.

### 2.1 Roles and responsibilities (to be refined)

- Architect / Lead Maintainer:
  - Owns the decision that a given state of `main` is release-ready.
  - Confirms that economic and security reports are up-to-date.
- DEV-94 / Release Steward:
  - Ensures the release checklist is followed.
  - Runs or verifies `scripts/check_release_status.sh`.
  - Coordinates with DEV-7, DEV-8, DEV-9, DEV-10 for missing reports.
- Technical Maintainers:
  - Ensure Foundry tests are green on the target commit.
  - Ensure `mkdocs build` is green.
  - Confirm that any required integration docs or changelogs are present.

### 2.2 Suggested pre-release checklist (manual, local)

Before creating a release tag (e.g. `v0.51.1`, `v0.52.0`), the Release
Steward should:

1. Ensure the working tree is clean on `main`:
   - `git checkout main`
   - `git pull origin main`
   - `git status` → no local changes.
2. Run the local dev CI smoketest (optional but recommended):
   - `bash patches/dev9_34_dev_ci_smoketest.sh`
   - Verify:
     - All Foundry tests pass.
     - `mkdocs build` succeeds.
     - `scripts/check_release_status.sh` reports all OK.
3. Review the key reports:
   - EconomicLayer and BuybackVault status.
   - Strategy enforcement and governance handover.
   - Security & Risk / CI / Docs reports.
4. Confirm that block-level reports (e.g. DEV-9/DEV-10 block report) are
   present for major infra or integration changes.

If any of the above fails or is incomplete, the release should be blocked
until the missing item is addressed (new report, fixed test, docs update).

### 2.3 Tagging principles (to be refined)

- Tags should be created from `main` only, on commits where:
  - All tests and docs builds are green.
  - `scripts/check_release_status.sh` is clean.
  - Required reports have been updated or explicitly confirmed as still valid.
- Tag naming examples:
  - `v0.51.0` – Major economic layer / protocol release (already cut).
  - `v0.51.1` – Minor infra / docs / CI refinement, no protocol changes.
  - `v0.52.0` – Next major protocol release (requires new status reports).

The exact branching and tagging strategy (e.g. release branches vs. direct
tags from `main`) can be refined in later DEV-94 steps.

## 3. Open questions and DEV-94 backlog (r2)

This section collects questions and follow-up tasks for DEV-94 and related
roles. It is intentionally not binding but acts as a backlog.

### 3.1 Open questions

- Should release tags always be created from `main`, or do we want
  dedicated `release/*` branches?
- Which roles are allowed to create and push tags?
  - Architect only?
  - Release Steward?
  - A small set of maintainers?
- How strict should CI be around release tags?
  - Require all workflows to pass?
  - Allow optional / informational workflows?

### 3.2 Potential next steps (future DEV-94 tickets)

- DEV-94 02+: Align CI workflows with the manual release flow:
  - Optional job that runs `scripts/check_release_status.sh` on tag pushes.
  - Optional job that prints a compact release status summary into logs.
- DEV-94 03+: Introduce a lightweight `RELEASE_NOTES` or `CHANGELOG`
  convention for protocol-relevant changes.
- DEV-94 04+: Document a step-by-step "How to cut a release tag" guide
  for new maintainers, based on the plan in this document.

### 3.3 Out of scope for r2

The following items are explicitly **out of scope** for this r2 plan and
should be handled in separate DEV-blocks:

- New economic features or parameter changes.
- BuybackVault strategy extensions or advanced enforcement logic.
- Indexer / monitoring / telemetry implementations.
- Governance UI or DAO frontends.

This document is deliberately descriptive and conservative. It captures the
current state and the intended direction for the release flow without
introducing new CI complexity or protocol changes.
EOD

# 3) Append log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-94 01] ${timestamp} Added DEV94_ReleaseFlow_Plan_r2 skeleton (release flow current/target/backlog)" >> "$LOG_FILE"

echo "== DEV-94 01: DEV94_ReleaseFlow_Plan_r2 skeleton created =="
