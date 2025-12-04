# DEV-9 Infrastructure Status – Report r2 (DEV-9 11–20)

## 1. Scope

This report summarizes the second block of DEV-9 work on branch
`dev9/docker-infra`, roughly covering patches **DEV-9 11–20**.

DEV-9's mandate remains unchanged:

- No changes to Economic Layer contracts or core protocol logic.
- Focus on:
  - CI / workflows hygiene,
  - docs build & linkcheck foundations,
  - local Docker tooling,
  - operator-facing documentation.
- All changes are implemented via small, reproducible patch scripts
  under `patches/` and logged in `logs/project.log`.

For the exact chronological log, see the corresponding entries around
`[DEV-9 11]` … `[DEV-9 20]` in `logs/project.log`.

---

## 2. Work Summary (DEV-9 11–20)

### 2.1 Documentation & Planning

- **DEV-9 11 – Status Report r1**
  - Added `docs/reports/DEV9_Status_Infra_r1.md`.
  - Captures the initial DEV-9 work (onboarding, infra plan, workflows
    inventory, Foundry CI plan, Docker baseline, MkDocs/linkcheck
    planning, monitoring plan).
  - Serves as the main reference for infra-related decisions around
    DEV-9 01–10.

- **DEV-9 12 – Linkcheck Policy Plan**
  - Added `docs/dev/DEV9_Linkcheck_Workflow_v1.md`.
  - Describes how a docs linkcheck process should behave:
    - separation of **strict** vs **relaxed** areas,
    - focus on `docs/` only,
    - internal links are expected to be strict,
    - external links should not break CI.
  - Planning-only document; does not change any CI behavior by itself.

- **DEV-9 13 – DEV-Docs README**
  - Added `docs/dev/README.md` to explain the purpose of the `docs/dev/`
    directory:
    - DEV onboarding and coordination docs for infra/CI work,
    - overview of the DEV-9-specific documents,
    - intended usage by Architects and future DEV roles.

- **DEV-9 14 – DEV-9 Backlog**
  - Added `docs/dev/DEV9_Backlog.md`.
  - Introduces a small backlog for infra-related tasks:
    - categorizes items by readiness (READY / PENDING ARCHITECT / IDEA),
    - keeps CI/Docker/linkcheck/monitoring topics visible and structured.

### 2.2 Workflows & Tools

- **DEV-9 15 – Manual Docs Linkcheck Workflow**
  - Added `.github/workflows/docs-linkcheck.yml`.
  - Key properties:
    - Trigger: `workflow_dispatch` (manual only).
    - Scope: runs in `docs/`.
    - Uses a simple linkcheck step (based on lychee-action or equivalent).
    - Does **not** modify existing CI workflows or enforce link policies.
  - Purpose:
    - Provide a non-blocking, manually-invoked linkcheck entrypoint for
      future refinement (e.g. strict/relaxed policies) without risking
      current builds.

- **DEV-9 18 (internal) – Coordination with Existing Docs CI**
  - DEV-9 ensured that the new docs-linkcheck workflow is:
    - clearly separate from the existing docs-build / Pages workflows,
    - non-intrusive (no new push/PR triggers),
    - ready to be integrated into broader CI strategy once the Architect
      approves stricter linkcheck behavior.

> Note: The exact patch numbers and wording for some intermediate steps
> are documented in `logs/project.log`. This report groups them into
> coherent themes rather than reproducing every tiny change.

### 2.3 Operator-Facing Documentation

- **DEV-9 19 – DEV-9 Operator Guide**
  - Added `docs/dev/DEV9_Operator_Guide.md`.
  - Provides a concise guide for operators / maintainers on how to:
    - run the manual Docker baseline build workflow,
    - run the manual docs-linkcheck workflow,
    - interpret DEV-9-related CI pieces.
  - Target audience:
    - Architects, Co-Architects,
    - infra/CI maintainers taking over from DEV-9,
    - anyone needing to operate the infra tooling without reading the
      entire DEV history.

- **DEV-9 20 – Bookkeeping Fix for DEV-9 19**
  - Added `patches/dev9_20_fix_dev9_19.sh`.
  - Ensured that:
    - `patches/dev9_19_operator_guide.sh` is executable (for reproducibility),
    - the missing `[DEV-9 19]` log entry was added to `logs/project.log`,
      if not already present.
  - This was a pure bookkeeping / reproducibility fix; no functional
    changes to docs or workflows.

---

## 3. Current Infra Picture after DEV-9 20

After DEV-9 20, the infra-related picture is:

- **Docs & Plans**
  - DEV-9 has:
    - onboarding & infra plan docs,
    - workflows inventory,
    - Foundry CI plan,
    - MkDocs/linkcheck plan,
    - monitoring plan,
    - DEV-9 backlog,
    - status reports r1 & r2,
    - operator guide.

- **Workflows**
  - A manual **Docker baseline build** workflow exists for local tooling.
  - A manual **Docs Linkcheck** workflow exists for future policy work.
  - One Foundry test workflow is version-pinned (as per DEV-9 06).
  - Existing docs-build / Pages workflows remain as defined by previous
    DEV roles (e.g. DEV-7, DEV-93, DEV-94).

- **Logs & Reproducibility**
  - Every DEV-9 change is:
    - implemented as a patch script under `patches/`,
    - logged in `logs/project.log` with a `[DEV-9 XX]` entry.
  - DEV-9 20 explicitly cleaned up bookkeeping for DEV-9 19.

---

## 4. Recommendations / Next Steps (for Architects)

Based on DEV-9 11–20, the following steps are good candidates for
future activation (subject to Architect approval):

1. **Foundry CI Hardening Rollout**
   - Align all Foundry workflows on a pinned version.
   - Introduce caching where appropriate.
   - Keep changes minimal and well-documented.

2. **Linkcheck Policy Implementation**
   - Use `DEV9_Linkcheck_Workflow_v1.md` as the canonical design.
   - Implement strict vs relaxed behavior in CI:
     - strict for security / risk / governance / architecture core docs,
     - relaxed (warnings only) for historical reports / logs / releases.

3. **Docker in CI (Optional, Non-Blocking)**
   - Keep the manual Docker workflow as the baseline.
   - Optionally add a non-blocking PR workflow that builds the baseline
     image for early detection of Dockerfile issues.

4. **Monitoring / Indexer Work**
   - Treat monitoring/indexer as a separate DEV role / repo.
   - Use `DEV9_Monitoring_Plan.md` + indexer specs as starting point.

DEV-9 should not activate these items on their own; they require
explicit Architect-level decisions.

---

## 5. Meta

This report is intended to be read together with:

- `docs/reports/DEV9_Status_Infra_r1.md`
- `docs/dev/DEV9_Onboarding.md`
- `docs/dev/DEV9_InfrastructurePlan.md`
- `docs/dev/DEV9_Backlog.md`
- `docs/dev/DEV9_Operator_Guide.md`

Together, they give a coherent picture of DEV-9's work and how future
infra/CI roles can safely extend it.
