#!/bin/bash
set -e

echo "== DEV-9 28: add DEV9_Status_Infra_r2.md =="

DOC="docs/dev/DEV9_Status_Infra_r2.md"
mkdir -p "$(dirname "$DOC")"

cat <<'EOD' > "$DOC"
# DEV-9 Infra Status – r2

## 1. Scope

This document is a follow-up to \`DEV9_Status_Infra_r1.md\`.
It summarizes DEV-9 work up to patches **DEV-9 21–27**, focusing on:

- CI hardening (Foundry CLI flags)
- Docs build behavior (MkDocs strict vs non-strict)
- Manual tooling (docker baseline + docs linkcheck)
- Developer/operator ergonomics

Core contracts / economic logic remain **unchanged**.

---

## 2. Summary of DEV-9 changes since r1

### 2.1 CI / Foundry

- **DEV-9 21 – forge install flag fix**
  - Removed deprecated \`--no-commit\` flag from \`forge install\` in CI workflows.
  - Aligns with current Foundry CLI behavior and fixes failing CI runs caused solely by this flag.

### 2.2 Docs / MkDocs / Linkcheck

- **DEV-9 23 / 24 – docs linkcheck & dev docs overview**
  - Wired the manual docs linkcheck workflow into the DEV-9 documentation flow.
  - Ensured \`docs/dev\` and related DEV-9 planning files are discoverable and referenced.

- **DEV-9 25 / 26 – MkDocs strict mode relax**
  - Relaxed \`mkdocs build --strict\` to \`mkdocs build\` in docs-build workflows.
  - Rationale:
    - The repo intentionally contains many non-nav / archival docs (reports, logs, specs).
    - Strict mode caused CI failures due to missing \`nav\` entries and legacy links.
    - For now, build stability is favored over strict nav enforcement.
  - Future work (separate ticket):
    - Re-introduce stricter checks in a **dedicated** docs/linkcheck workflow with
      clear strict vs relaxed areas.

### 2.3 Operator usability & documentation

- **DEV-9 19 / 20 – DEV9_Operator_Guide + fix**
  - Added \`docs/dev/DEV9_Operator_Guide.md\` explaining how to:
    - Run the baseline Docker image build workflow.
    - Run the docs linkcheck workflow.
    - Interpret DEV-9-related CI workflows.
  - Fixed:
    - Script permissions for \`dev9_19_operator_guide.sh\`.
    - Missing log entry for DEV-9 19 in \`logs/project.log\`.

- **DEV-9 27 – Backlog sync**
  - Updated \`DEV9_Backlog.md\` with a concise summary of DEV-9 work from 19–25.
  - Ensures the backlog matches the actual state of CI, docs, and tooling.

---

## 3. Current CI / tooling picture (high level)

- **Foundry CI**
  - CLI flags are now compatible with current Foundry versions.
  - At least one workflow explicitly pins a known-good Foundry version.
  - No behavioral changes to tests themselves.

- **Docs build (MkDocs)**
  - \`mkdocs build\` is used (non-strict).
  - The docs tree still contains many legacy / archive files that are intentionally
    not present in the \`nav\` configuration.
  - Future strictness should be handled via **dedicated linkcheck workflows**, not
    via hard \`--strict\` in the main docs build.

- **Docs linkcheck workflow**
  - Exists as a **manual** workflow, triggered via \`workflow_dispatch\`.
  - Scope: focus on \`docs/\` and evolve towards strict vs relaxed areas.
  - Does not block PRs or releases at this stage.

- **Docker baseline**
  - Baseline Dockerfile and manual build workflow are present and documented.
  - No automatic Docker builds in PR or release flows yet.

---

## 4. Open items & recommendations

1. **Foundry version pinning rollout (Block B1)**
   - Extend version pinning to all Foundry-related workflows.
   - Keep behavior identical, only add/adjust the \`version\` field.
   - Requires Architect/Owner confirmation before touching more workflows.

2. **Linkcheck policy strict/relaxed (Block B2)**
   - Implement the strict vs relaxed policy described in
     \`DEV9_Linkcheck_Workflow_v1.md\` / \`DEV9_MkDocs_Linkcheck_Plan.md\`.
   - Keep:
     - Security/risk/governance/indexer/architecture docs as **strict**.
     - Reports/logs/releases/dev-history as **relaxed** (warnings only).
   - This should be done in a separate ticket, once the current non-strict baseline
     has proven stable.

3. **Docker CI integration (Block B3)**
   - Optionally add a non-blocking Docker build to PR workflows.
   - Recommendation:
     - Create a dedicated workflow for PR builds instead of altering the manual one.
   - Only after Architect/Owner approval.

4. **Monitoring / indexer implementation (Zone C)**
   - Out of scope for DEV-9.
   - Implementation should be handled by a dedicated role (e.g. DEV-10 Monitoring),
     likely in a separate repo or service.
   - DEV-9’s monitoring plan and indexer notes remain the design reference.

---

## 5. TL;DR for Architects / Coordinators

- DEV-9 has:
  - Fixed CI breakages caused by outdated Foundry flags.
  - Relaxed MkDocs strict mode to stabilize docs builds.
  - Established manual workflows for Docker and docs linkcheck.
  - Documented operator flows and synced the internal backlog.

- No on-chain logic or economic behavior has been modified.

- The system is now in a state where:
  - CI is less noisy and more compatible with current tooling.
  - Documentation for infra/CI is easier to navigate.
  - Future hardening (B1/B2/B3) can be enabled in controlled, explicit steps.

EOD

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 28] ${timestamp} Added DEV9_Status_Infra_r2.md" >> "$LOG_FILE"

echo "== DEV-9 28 done =="
