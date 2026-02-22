# DEV-9 / DEV-10 Sync – Infra & Integrations (r1)

**Scope of this report**

This document provides a high-level sync between:

- **DEV-9** – Infrastructure & CI (docker, workflows, docs build),
- **DEV-10** – Integrations & Developer Experience (external guides),

for the 1kUSD Economic Core.

It is meant for architects, reviewers and coordinators who want a single
snapshot of how infra and integrations work together **without** changing any
on-chain logic.

---

## 1. DEV-9 – Infrastructure & CI (r2 snapshot)

**Primary owner:** DEV-9  
**Scope:** CI, docs build, docker baseline, infra documentation.

### 1.1 Delivered items (selection)

- Stabilised CI around:
  - Foundry test workflows,
  - MkDocs-based docs builds,
  - release-status checks.
- Introduced:
  - a **manual docker baseline build** workflow, based on
    `docker/Dockerfile.baseline`,
  - a **manual docs linkcheck** workflow (non-blocking, dispatch-only).
- Relaxed overly strict docs settings:
  - switched from `mkdocs build --strict` to `mkdocs build` in CI,
  - kept legacy/non-nav docs buildable without blocking the pipeline.
- Documented:
  - `DEV9_Status_Infra_r1.md` / `DEV9_Status_Infra_r2.md`,
  - `DEV9_Backlog.md` with Zone A/B/C separation,
  - `DEV9_Operator_Guide.md` for running the manual workflows.

### 1.2 Boundaries

DEV-9 **did not**:

- touch any contracts or Economic Layer logic,
- modify protocol behaviour,
- introduce automatic deploys or release pipelines.

Infra work is intentionally **supportive** and **reversible**, keeping the
Economic Core stable while making CI and tooling more usable.

---

## 2. DEV-10 – Integrations & Developer Experience (r1 snapshot)

**Primary owner:** DEV-10  
**Scope:** external-facing documentation for integrators, no code changes.

### 2.1 Delivered items (r1)

- Created a dedicated **Integrations & Developer Guides** area:
  - `docs/integrations/index.md`
  - linked from `docs/index.md`.
- Added four deep integration guides:
  - `psm_integration_guide.md`
  - `oracle_aggregator_guide.md`
  - `guardian_and_safety_events.md`
  - `buybackvault_observer_guide.md`
- Produced a status report:
  - `docs/dev/DEV10_Status_Integrations_r1.md`
- Established a DEV-10 backlog:
  - `docs/dev/DEV10_Backlog.md` (r1 done, r2+ ideas tracked).

### 2.2 Focus and boundaries

DEV-10 focuses on **how to safely integrate** with the Economic Core:

- how to call public contracts,
- how to interpret events and states,
- how to monitor and operate integrations.

DEV-10 explicitly **does not**:

- change contracts,
- modify Economic Layer behaviour,
- alter CI, docker or release workflows.

All work is **documentation-only** and aligned with:

- Economic Layer v0.51.0,
- BuybackVault StrategyEnforcement Phase 1 design,
- existing Security & Risk documentation.

---

## 3. How DEV-9 and DEV-10 fit together

From an architectural perspective:

- **DEV-9** prepares and stabilises the *infrastructure*:
  - CI is less noisy and more predictable,
  - manual workflows exist for docker builds and link checks,
  - infra docs and operator guides make these tools reproducible.
- **DEV-10** builds on this stable base to improve *developer experience*:
  - external teams get structured guides for integrating with:
    - PSM,
    - Oracle Aggregator,
    - Guardian / Safety events,
    - BuybackVault observers.
  - internal status and backlogs for integrations are clearly documented.

Both layers:

- stay strictly within their Tabuzonen,
- do not modify on-chain logic,
- are safe to adopt in audits and reviews as supporting material.

---

## 4. Recommended reading order for reviewers

For architects, auditors or coordinators who want to understand the
Infra + Integrations layer, a suggested reading path is:

1. **Infra / CI (DEV-9)**
   - `docs/dev/DEV9_Status_Infra_r2.md`
   - `docs/dev/DEV9_Backlog.md`
   - `docs/dev/DEV9_Operator_Guide.md`

2. **Integrations / DevEx (DEV-10)**
   - `docs/integrations/index.md`
   - `docs/integrations/psm_integration_guide.md`
   - `docs/integrations/oracle_aggregator_guide.md`
   - `docs/integrations/guardian_and_safety_events.md`
   - `docs/integrations/buybackvault_observer_guide.md`
   - `docs/dev/DEV10_Backlog.md`
   - `docs/dev/DEV10_Status_Integrations_r1.md`

This report (`DEV9_Dev10_Sync_Infra_Integrations_r1.md`) is intended as
a compact bridge between these two clusters.

---

## 5. Next steps & future extensions

Potential future work (subject to Architect/Owner approval):

- **DEV-9 (Infra/CI):**
  - expanding CI hardening (Foundry pin rollout, cache tuning),
  - optional non-blocking docker builds for PRs,
  - refined docs linkcheck policies (strict vs relaxed subsets).

- **DEV-10 (Integrations):**
  - r2 content deepening per guide:
    - concrete examples,
    - event schemas,
    - suggested dashboards and alerting rules,
  - optional code snippets and end-to-end integration walkthroughs.

None of these items are active by default; they must be scheduled explicitly
and remain coordinated with:

- Economic Layer versioning,
- Security & Risk documentation,
- governance and release processes.
