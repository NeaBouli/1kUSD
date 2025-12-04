#!/bin/bash
set -e

echo "== DEV-9 07: Create DEV9_MkDocs_Linkcheck_Plan.md =="

# 1) Ensure docs/dev directory exists
mkdir -p docs/dev

# 2) Write MkDocs + linkcheck plan
cat <<'EOD' > docs/dev/DEV9_MkDocs_Linkcheck_Plan.md
# DEV-9 MkDocs & Linkcheck Plan

This document captures DEV-9's high-level plan for hardening the
documentation build and link-check flows for the 1kUSD project, without
making any immediate changes to CI workflows.

All changes described here are *proposals* and MUST be approved by the
Architect before any workflow YAML is modified.

## Context

The repository uses MkDocs for documentation and additional tooling to
validate links and documentation structure. Several workflows in
`.github/workflows/` are related to docs and link checking, for example:

- `docs-build.yml`
- `docs-check.yml`
- `docs.yml`
- `linkcheck.yml`
- `pages.yml`
- `_global_disable_docs.yml` (control / emergency switch)
- Potentially other workflows that interact with MkDocs or docs artifacts.

The goal is to keep documentation builds stable and useful, while
avoiding over-strict checks that block development without providing
real value.

## Goals

- Ensure that `mkdocs build` runs reliably in CI.
- Reduce noisy or flaky link-check failures.
- Keep link-related policies transparent and documented.
- Avoid breaking the existing docs navigation without explicit approval.

Non-goals:

- No changes to protocol logic or contracts.
- No heavy restructuring of the docs tree in a single step.
- No automatic deployment changes without a separate, explicit ticket.

## Proposed Strategy

1. **Inventory & Baseline**

   - Confirm which workflows actually run MkDocs and/or linkcheck tools
     (e.g. `docs-build.yml`, `docs-check.yml`, `linkcheck.yml`).
   - For each workflow, identify:
     - Trigger conditions (push, PR, tags, paths).
     - Which commands are executed (e.g. `mkdocs build`, custom scripts).

2. **Define Linkcheck Policy**

   - Separate *internal* vs. *external* links:
     - Internal links (within this repo/site) should ideally be strict.
     - External links may be flaky (network issues, temporary outages).
   - Consider:
     - Allowing soft-fail / warnings for external links.
     - Potential whitelists/blacklists for known-problematic domains.

3. **Scope of Enforcement**

   - Focus strict link checking on:
     - Core docs (e.g. `docs/ARCHITECTURE.md`, `docs/STATUS.md`,
       key design and security docs).
   - Allow more relaxed policies for:
     - Historical reports and archived docs in `docs/reports/`,
       `docs/logs/`, etc.
   - Optionally introduce a "quarantine" pattern where problematic
     legacy docs are still available, but excluded from strict checks.

4. **Failure Modes**

   - Define what causes a CI failure vs. what results in a warning:
     - Broken internal links in core docs -> CI fail.
     - Broken external links or legacy docs -> warning only, or
       separate non-blocking job.
   - Ensure that the policy is documented here and reflected in
     workflow names/descriptions.

5. **Incremental Implementation**

   DEV-9 proposes the following incremental approach:

   - Step 1 (planning only):
     - This document (DEV9_MkDocs_Linkcheck_Plan.md).
   - Step 2 (single workflow adjustment):
     - Pick one workflow (e.g. `docs-check.yml`) and adjust it to:
       - Make linkcheck behavior explicit (internal vs external).
       - Avoid breaking existing behavior unless clearly desired.
   - Step 3 (rollout / harmonization):
     - Align other docs-related workflows with the agreed policy.
   - Step 4 (optional enhancements):
     - Add artifacts / reports for linkcheck results (e.g. html or
       markdown summaries) if useful.

## Open Questions for the Architect

- Which categories of docs should be "strict" vs "relaxed"?
  - Example:
    - Strict: architecture, security, risk, governance, SDK docs.
    - Relaxed: historical reports, archived drafts, logs.
- Should external link failures cause a CI fail or just a warning?
- Should there be a separate, non-blocking linkcheck workflow for
  external links?

DEV-9 will await explicit guidance on these points before modifying any
docs-related workflow YAML files.
EOD

# 3) Log message
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 07] ${timestamp} Added DEV9_MkDocs_Linkcheck_Plan.md" >> "$LOG_FILE"

echo "== DEV-9 07 done =="
