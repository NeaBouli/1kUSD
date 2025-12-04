# DEV-9 Foundry CI Hardening Plan

This document outlines DEV-9's proposal for hardening the Foundry-based
CI workflows in the 1kUSD project. It is *planning only* and does not
change any CI workflows by itself.

All changes described here are proposals and MUST be approved by the
Architect before any workflow YAML is modified.

## Context

The 1kUSD project uses Foundry for Solidity testing and tooling. Multiple
GitHub Actions workflows exist that interact with Foundry (e.g. format,
tests, combined CI).

DEV-9's responsibility is to improve stability and reproducibility of
these workflows, without touching the Solidity contracts or economic
layer logic.

## Goals

- Make CI runs more deterministic (less dependent on "whatever Foundry
  version is current" at runtime).
- Reduce flaky behavior caused by toolchain updates or cache changes.
- Keep job definitions readable and maintainable.
- Avoid changes to protocol logic or test semantics.

Non-goals:

- No changes to contracts/ or protocol logic.
- No changes to the underlying economic layer or parameters.
- No addition of new, complex infra (self-hosted runners, external
  services) without a separate design and approval.

## Proposed Hardening Steps (High-level)

1. **Foundry Version Pinning**

   - Introduce explicit version pinning for the Foundry toolchain in
     Foundry-related workflows (e.g. foundry-test.yml, forge-ci.yml,
     foundry.yml).
   - Prefer a stable, tagged Foundry release over an unpinned nightly.
   - Make the pinned version visible and easy to update (e.g. single
     env variable or single action configuration).

2. **Caching Strategy**

   - Use GitHub Actions caching for:
     - Foundry toolchain artifacts (if not handled by the selected
       Foundry action).
     - Relevant build/test artifacts where it materially speeds up CI.
   - Keep cache keys simple and tied to:
     - Foundry version
     - OS / job matrix entries
     - Optionally, lockfile hashes (for dependencies) where appropriate.
   - Avoid overly aggressive cache reuse that might hide issues.

3. **Job Structure & Separation**

   - Ensure that formatting (fmt), unit tests, and possibly lint/static
     analysis are clearly separated jobs or steps, so a failure is easy
     to attribute.
   - Make sure Foundry-related jobs:
     - Run on a consistent OS image (e.g. ubuntu-latest).
     - Share a consistent strategy for setting up Foundry.

4. **Error Reporting & Logs**

   - Ensure that Foundry commands are invoked with useful flags for CI
     (e.g. verbose where needed, but without excessive noise).
   - Consider capturing artifacts in case of failure (e.g. junit-style
     reports) if the project already uses such patterns.

## Implementation Approach (Proposal)

DEV-9 proposes the following sequence for implementing CI hardening:

1. **Inventory & Documentation**
   - DONE: DEV9_Workflows_Inventory.md lists all workflows.
   - This document (DEV9_Foundry_CI_Plan.md) captures the plan.

2. **Minimal Version Pinning in One Workflow**
   - Select one Foundry-related workflow (e.g. foundry-test.yml) as the
     initial candidate.
   - Introduce a minimal, explicit Foundry version pin (e.g. via a
     standard Foundry setup action and a version input).
   - Verify that CI runs remain green.

3. **Rollout to Additional Workflows**
   - Apply the same pinning pattern to other Foundry-related workflows,
     if they exist and are active.
   - Keep the version definition centralized as much as possible.

4. **Introduce/Refine Caching**
   - Add caches for Foundry artifacts where this clearly improves CI
     runtime without harming determinism.
   - Monitor for issues and adjust cache keys as needed.

5. **Optional Enhancements**
   - If the Architect approves, additional small improvements can be
     made, such as:
     - More structured test reporting.
     - Clearer matrix definitions.
     - Better separation of formatting vs testing steps.

## Coordination & Approval

- DEV-9 will not modify any CI workflows in a breaking way without a
  dedicated patch and clear communication.
- Each workflow change will be encapsulated in its own dev9_XX patch
  script and referenced in logs/project.log.
- If at any point a workflow becomes flaky or unstable after a change,
  DEV-9 will propose a rollback or adjustment in coordination with the
  Architect.

---

## DEV-9 30 – Foundry version rollout

To keep Foundry CI behaviour consistent across workflows, DEV-9 30 introduced
a canonical Foundry toolchain version and rolled it out to all relevant
workflows.

**Canonical source:**

- `.github/workflows/foundry.yml`
  - The version configured here is treated as the single source of truth.

**Rollout targets:**

- `.github/workflows/buybackvault-strategy-guard.yml`
- `.github/workflows/forge-ci.yml`
- `.github/workflows/foundry-test.yml`

A helper script (`patches/dev9_30_foundry_version_rollout.sh`) synchronises
the `version:` field in any workflow that uses `foundry-rs/foundry-toolchain`
with the canonical value from `foundry.yml`.

### Operational notes

- When changing the Foundry version, update **only** `foundry.yml` first.
- Then re-run the rollout script to propagate the version to other workflows.
- This keeps CI deterministic and avoids drift between different Foundry-based
  jobs.

Future hardening (e.g. cache tuning, matrix cleanups) should build on this
canonical version model rather than introducing ad-hoc pins.

---

## Foundry CI – cache & matrix plan (DEV-9 32, docs-only)

This section defines how DEV-9 intends to evolve Foundry-related CI
(cache and matrix behaviour) **without** changing workflows yet.

### Goals

- keep test runtimes reasonable and predictable,
- avoid flakiness due to toolchain drift or inconsistent caching,
- minimise redundant jobs while preserving useful coverage,
- keep the setup easy to understand for future DEV roles and auditors.

### Current state (r2)

- A canonical Foundry toolchain version is defined in:
  - `.github/workflows/foundry.yml`
- Other workflows using `foundry-rs/foundry-toolchain` are pinned to the same
  version via:
  - `patches/dev9_30_foundry_version_rollout.sh`
- Caching and matrix definitions are still in their original, pre-hardening
  state.

### Planned approach (future DEV-9 tickets)

1. **Cache strategy (docs first)**

   DEV-9 will:

   - document which directories/files are candidates for caching
     (e.g. toolchain installs, build artefacts, test outputs),
   - define simple rules for when cache keys should change
     (e.g. Foundry version bumps, major dependency changes),
   - ensure that any future cache configuration is:
     - deterministic,
     - easy to invalidate,
     - clearly tied to the canonical Foundry version.

   No cache-related YAML changes are active yet.

2. **Matrix simplification**

   DEV-9 will:

   - review existing Foundry-related jobs and matrices,
   - identify redundant or overlapping combinations,
   - propose a reduced set that still covers:
     - mainnet-style scenarios,
     - regression suites,
     - BuybackVault strategy guard specifics.

   Any reduction will be documented first, then implemented in a dedicated
   DEV-9 ticket (Zone B, with explicit Architect/Owner approval).

3. **Rollout process**

   When changes move beyond documentation:

   - each change will be backed by:
     - a DEV-9 ticket (e.g. DEV-9 3X),
     - an update in `DEV9_Backlog.md`,
     - a short note in `DEV9_Foundry_CI_Plan.md`,
   - YAML changes will be kept minimal and reversible,
   - before/after behaviour will be described in commit messages and reports.

This section is intentionally descriptive only. It does not introduce any
active CI changes beyond what is already live in r2.
