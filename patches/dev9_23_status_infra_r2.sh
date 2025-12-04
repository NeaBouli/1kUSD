#!/bin/bash
set -e

echo "== DEV-9 23: add DEV9_Status_Infra_r2.md =="

mkdir -p docs/reports

cat <<'MD' > docs/reports/DEV9_Status_Infra_r2.md
# DEV-9 Status Report – Infra & CI (r2)

This is a follow-up status report for DEV-9 on the 1kUSD project.
It summarizes the work after r1, mainly around docs, CI helpers and
operator-facing tooling.

## 1. Scope recap

DEV-9 is responsible for:

- Infra / CI hardening around Foundry, MkDocs and GitHub Actions.
- Docker baseline image for local tooling (no production image).
- Documentation and operator guides.
- No changes to contracts/ or economic logic.

All work is constrained to:

- .github/workflows/
- docker/
- docs/
- scripts/
- logs/project.log
- patches/dev9_XX_*.sh

## 2. New documents and helpers since r1

### 2.1 DEV-9 Operator Guide

File: `docs/dev/DEV9_Operator_Guide.md`

Content:

- How to run:
  - `docker-baseline-build.yml` (manual build of docker/Dockerfile.baseline).
  - `docs-linkcheck.yml` (manual docs linkcheck workflow).
- How to interpret CI runs:
  - Where to find failing jobs.
  - How to map errors back to specific workflows.

Purpose:

- Give future operators and infra devs a one-stop guide on how to
  use the DEV-9 tooling without reading all patch scripts.

### 2.2 DEV-9 Backlog overview

File: `docs/dev/DEV9_Backlog.md`

Content:

- A living backlog for DEV-9, grouped into:
  - CI hardening (Foundry, caching).
  - Linkcheck and docs quality.
  - Docker / infra improvements.
  - Monitoring / indexer preparation.
- Each item has a rough status:
  - DONE / READY / PENDING ARCHITECT / IDEA.

Purpose:

- Make DEV-9's remaining ideas and partially planned work explicit.
- Provide a handover-friendly list for future infra roles.

### 2.3 GH CLI Cheatsheet

File: `docs/dev/DEV9_GH_CLI_CheatSheet.md`

Content:

- Practical `gh` commands for:
  - Listing failed runs (`gh run list` with status/branch filters).
  - Viewing run details and logs (`gh run view <ID> --log`).
  - Filtering by workflow name (e.g. "Foundry Tests CI", "📘 Deploy Docs").
- Typical debugging loop:
  - List failures for a branch.
  - Inspect the most recent failing run.
  - Identify the failing job and error.
  - Only then prepare a small patch script and commit.

Purpose:

- Capture the actual CI debugging workflow used during DEV-9.
- Make it easier for future devs to understand and reuse this pattern.

## 3. CI workflows added or adjusted in this phase

### 3.1 Manual docs linkcheck workflow

File: `.github/workflows/docs-linkcheck.yml`

Key properties:

- Trigger: `workflow_dispatch` only (manual in GitHub UI).
- Job: `linkcheck` on `ubuntu-latest`.
- Steps:
  - `actions/checkout@v4`
  - A placeholder / minimal linkcheck step on `docs/`
    (initially allowed to be very simple and non-blocking).

Purpose:

- Provide a **manual** linkcheck entry point that does not affect
  other workflows or PRs.
- Basis for future strict/relaxed linkcheck policy (to be implemented
  in a later DEV-9 / DEV-X block with Architect approval).

### 3.2 Docker baseline build workflow (for context)

File: `.github/workflows/docker-baseline-build.yml` (from earlier DEV-9 work)

- Trigger: `workflow_dispatch` (manual).
- Builds `docker/Dockerfile.baseline` into a local image.
- No pushes to any registry, no automatic use in other workflows.

Purpose:

- Allow local / manual validation of the baseline Docker image.
- Keep Docker CI strictly opt-in and non-intrusive.

## 4. Logging and reproducibility

Each DEV-9 patch:

- Lives under `patches/dev9_XX_*.sh`.
- Is intended to be:
  - Small,
  - Re-runnable (idempotent where possible),
  - Logged via `logs/project.log`.

New entries include:

- `[DEV-9 19] Added DEV9_Operator_Guide.md`
- `[DEV-9 20] Fixed DEV-9 19 script permissions and log entry`
- `[DEV-9 22] Added DEV9_GH_CLI_CheatSheet.md`
- `[DEV-9 23] Added DEV9_Status_Infra_r2.md` (this report)

This keeps the project history traceable and allows reconstruction of
the infra changes step by step.

## 5. Handover notes

For future infra / CI devs (DEV-10, DEV-11, ...):

1. Read:
   - `docs/reports/DEV9_Status_Infra_r1.md`
   - `docs/reports/DEV9_Status_Infra_r2.md` (this file)
   - `docs/dev/DEV9_Operator_Guide.md`
   - `docs/dev/DEV9_Backlog.md`
   - `docs/dev/DEV9_GH_CLI_CheatSheet.md`

2. Check CI:
   - Look at `.github/workflows/` to see current Foundry / docs setup.
   - Use the GH CLI cheatsheet for inspecting runs.

3. Coordinate any changes to:
   - Foundry version pinning rollout.
   - Linkcheck strict/relaxed policies.
   - Docker integration into PR CI.
   - Monitoring/indexer implementation.

All of the above should be done in new DEV blocks with explicit
Architect approval, following the same patch+log model.
MD

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 23] ${timestamp} Added DEV9_Status_Infra_r2.md" >> "$LOG_FILE"

echo "== DEV-9 23 done =="
