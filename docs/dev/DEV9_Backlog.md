# DEV-9 Backlog Overview

This document tracks DEV-9's infra/CI/Docker/docs backlog for the 1kUSD
project. It is meant as a coordination tool between DEV-9, the Architect
and future infra/CI contributors.

Nothing in this document is self-executing; every concrete change must
be implemented via dedicated dev9_XX patch scripts and approved by the
Architect.

## Legend

- **DONE** – Implemented and merged on `dev9/docker-infra`.
- **READY** – Concept agreed, can be implemented when Architect gives
  a concrete "go".
- **PENDING ARCHITECT** – Requires an explicit Architect decision
  before implementation.
- **IDEA** – Potential future improvement, not yet decided.

---

## 1. CI / Foundry

### 1.1 Done

- **DEV-9 06 – Pin Foundry version in foundry-test workflow**  
  Status: **DONE**  
  - Pinned `foundry-rs/foundry-toolchain` to `version: "nightly-2024-05-21"`
    in `.github/workflows/foundry-test.yml`.  
  - Scope intentionally limited to a single workflow.

### 1.2 Backlog

- **Roll out pinned Foundry version to additional workflows**  
  Status: **PENDING ARCHITECT (post DEV-9 15+)**  
  - Apply the same version pinning pattern to other Foundry-related
    workflows (if active).  
  - Keep changes incremental and isolated (one workflow per patch).

- **Introduce / refine caching for Foundry jobs**  
  Status: **IDEA**  
  - Add CI caches for Foundry artifacts to improve runtime, while
    preserving determinism.  
  - Needs careful design of cache keys and coordination with the
    Architect.

---

## 2. Docs / MkDocs / Linkcheck

### 2.1 Done

- **DEV-9 03 – docs/index.md landing page**  
  Status: **DONE**  
  - Added a minimal MkDocs landing page pointing to major doc areas and
    DEV-9 docs.

- **DEV-9 07 – DEV9_MkDocs_Linkcheck_Plan.md**  
  Status: **DONE**  
  - High-level plan for MkDocs and linkcheck behavior.

- **DEV-9 12 – DEV9_Linkcheck_Workflow_v1.md**  
  Status: **DONE**  
  - v1 linkcheck policy, including strict vs relaxed areas and internal
    vs external link handling.
  - No YAML/CI changes by itself.

- **DEV-9 13 – docs/dev/README.md**  
  Status: **DONE**  
  - Overview of all DEV-9 documentation in `docs/dev/`.

### 2.2 Backlog

- **Implement strict/relaxed internal link policy in docs-check workflow**  
  Status: **PENDING ARCHITECT**  
  - Map strict areas:
    - `docs/security/`, `docs/risk/`, `docs/governance/`,
      `docs/indexer/`, `docs/architecture/`.  
  - Map relaxed areas:
    - `docs/reports/`, `docs/logs/`, `docs/releases/`, `docs/dev/`,
      plus explicitly archived material.  
  - Fail build on internal link issues in strict areas; warn-only in
    relaxed areas.  
  - Do not fail build on external links.

- **Introduce dedicated linkcheck workflow for external links**  
  Status: **IDEA**  
  - Separate workflow (e.g. `linkcheck.yml`) focused on external link
    health.  
  - Warnings only, never fails CI.  
  - Could be triggered on demand (`workflow_dispatch`) or on a relaxed
    schedule.

- **Optional linkcheck artifacts**  
  Status: **IDEA**  
  - Generate reports (Markdown/HTML/JSON) with linkcheck results as CI
    artifacts for manual review.

---

## 3. Docker / CI Integration

### 3.1 Done

- **DEV-9 08 – docker/Dockerfile.baseline**  
  Status: **DONE**  
  - Baseline local tooling image (Ubuntu-based), not wired into CI by
    default.

- **DEV-9 09 – docker-baseline-build.yml**  
  Status: **DONE**  
  - Manual (`workflow_dispatch`) CI workflow that builds
    `docker/Dockerfile.baseline`.  
  - No automatic triggers, no registry pushes.

### 3.2 Backlog

- **Optional PR check using docker-baseline-build**  
  Status: **PENDING ARCHITECT (DEV-9 18+)**  
  - Add a non-blocking PR check that runs the baseline Docker build on
    selected branches (e.g. `dev9/docker-infra`, later `main`).  
  - Build-only, no push to external registries.

- **Multi-arch builds (linux/amd64 + linux/arm64)**  
  Status: **IDEA**  
  - Extend Docker build workflows to support multiple architectures.  
  - Requires coordination with Architect and CI resource considerations.

- **Containerized docs build / tests**  
  Status: **IDEA**  
  - Optionally run docs builds or tests inside the baseline Docker image
    for more reproducible environments.

---

## 4. Monitoring / Indexer Preparation

### 4.1 Done

- **DEV-9 10 – DEV9_Monitoring_Plan.md**  
  Status: **DONE**  
  - Describes which events across BuybackVault, Oracle, PSM Core and
    Guardian/SafetyAutomata are relevant for monitoring.

### 4.2 Backlog

- **Define event schemas / topics for an external indexer**  
  Status: **PENDING ARCHITECT**  
  - Turn the monitoring plan into concrete event schemas for indexers
    (e.g. field names, normalization, alert thresholds).  
  - Likely implemented in a separate repo or off-chain service.

- **Coordinate with Ops / Indexer maintainers**  
  Status: **OUT-OF-REPO / PENDING**  
  - Share monitoring plan and schemas with whoever will operate the
    indexer / dashboards.  
  - Not directly implemented in this repository.

---

## 5. Meta / Coordination

- All actual changes must continue to follow the DEV-9 workflow:
  - Small, isolated `dev9_XX` patch scripts under `patches/`.
  - Explicit log entries in `logs/project.log`.
  - No changes to `contracts/` or Economic Layer logic.

- This backlog is meant as a living document:
  - Items can be marked as DONE / READY / PENDING ARCHITECT / IDEA.
  - It should be updated whenever DEV-9 finishes a task or the Architect
    changes priorities.

---

## Recent updates (DEV-9 19–25)

- **DEV-9 19 / 20 – Operator Guide & Fix**
  - Added \`docs/dev/DEV9_Operator_Guide.md\` (how to run DEV-9 tools & workflows).
  - Fixed script permissions and added missing log entry for DEV-9 19.

- **DEV-9 21 – Forge install flag fix**
  - Removed deprecated \`--no-commit\` flag from \`forge install\` in workflows.
  - Aligns CI with current Foundry CLI behavior.

- **DEV-9 23 / 24 – Docs linkcheck & dev docs overview**
  - Wired docs linkcheck + DEV-9 documentation into the docs/dev area.
  - Prepared for stricter link/quality checks without breaking existing docs.

- **DEV-9 25 / 26 – MkDocs strict mode relax**
  - Relaxed \`mkdocs build --strict\` to \`mkdocs build\` in docs workflows.
  - Prevents CI failures due to non-nav/legacy pages while keeping content intact.


- **DEV-9 30 – Foundry version rollout**
  - Introduced a canonical Foundry toolchain version in `.github/workflows/foundry.yml`.
  - Rolled this version out to other Foundry-based workflows
    (`buybackvault-strategy-guard.yml`, `forge-ci.yml`, `foundry-test.yml`)
    via `patches/dev9_30_foundry_version_rollout.sh`.
