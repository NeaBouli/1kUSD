# DEV-96 – CI Hardening Notes (Non-Invasive)

**Scope:**  
This document summaries CI hardening options for the 1kUSD repo without changing
the protocol logic, contracts, or the existing manual release / pages flow.

It is a **plan-only / documentation-only** artifact – no CI behaviour is changed
by this DEV step. Future DEV tickets can selectively implement the measures
described here.

---

## 1. Current CI Surface (after DEV-93 / DEV-95)

- Foundry tests:
  - Existing workflows run `forge test` against the Economic Layer, including:
    - PSM / Limits / Oracle / Guardian regression suites
    - BuybackVault + StrategyEnforcement guard tests
- Docs build:
  - `.github/workflows/docs-build.yml` runs:
    - `mkdocs build`
  - Result is visible via a Docs Build badge in `README.md`.
- Status / release checks:
  - `scripts/check_release_status.sh` can be run locally before tagging:
    - Confirms that key status / report files are present and non-empty:
      - `PROJECT_STATUS_EconomicLayer_v051.md`
      - `DEV60-72_BuybackVault_EconomicLayer.md`
      - `DEV74-76_StrategyEnforcement_Report.md`
      - `DEV87_Governance_Handover_v051.md`
      - `DEV89_Dev7_Sync_EconomicLayer_Security.md`
      - `DEV93_CI_Docs_Build_Report.md`

No Docker / multi-arch CI is active yet.  
Pages deploy is still handled via the existing `gh-pages` flow (manual or simple workflow).

---

## 2. Low-Risk Hardening Ideas (Not Yet Active)

The following measures are **not implemented yet** – they are candidates for
future DEV tickets (e.g. `DEV-97`, `DEV-98`, …):

### 2.1 Foundry CI Stabilisation

Goals:

- Keep CI fast and reproducible.
- Avoid accidental changes in the Foundry toolchain.

Options:

1. **Pin Foundry version** (recommended):
   - Use a fixed version via the setup action, e.g.:
     - `foundry-rs/foundry-toolchain@<pinned-version>`
   - Document the chosen version in:
     - `docs/logs/DEVxx_Foundry_Version_Pinning.md`

2. **Use a dedicated CI profile**:
   - Run tests with:
     - `FOUNDRY_PROFILE=ci forge test`
   - Keep any heavier fuzz / invariant tests behind a separate workflow
     (optional nightly job).

None of this is wired yet – this file only records the preferred direction.

---

### 2.2 Caching

Goals:

- Reduce CI runtime.
- Avoid re-downloading toolchains & dependencies.

Potential steps (future work):

- Add `actions/cache` for:
  - Foundry artifacts (e.g. `~/.foundry`, `~/.forge`)
  - `lib/` dependencies (if used heavily)
- Keep caches keyed by:
  - `foundry.toml` hash
  - `remappings.txt` (if present)
  - relevant `package.json` / lockfiles (if/when JS tooling enters the repo)

These changes require careful, separate DEV tickets and MUST NOT be mixed
with protocol changes.

---

## 3. Concurrency & Pages / Docs

GitHub Pages currently cancels lower-priority jobs when multiple deploys queue
up. To avoid race conditions and noisy CI failures in the future, the following
options are available (not yet implemented):

1. **Add explicit concurrency groups** to docs / pages workflows:
   - e.g.:
     ```yaml
     concurrency:
       group: docs-${{ github.ref }}
       cancel-in-progress: true
     ```
   - Ensure this is only applied to non-critical preview flows.

2. **Split build vs. deploy**:
   - Keep `mkdocs build` as a mandatory CI step (already done via `docs-build.yml`).
   - Trigger actual `gh-pages` deploys only:
     - on tagged releases, or
     - via a manual `workflow_dispatch`.

Currently, only the safe `mkdocs build` step is enforced in CI.
Pages deploy remains manual / existing-flow-driven.

---

## 4. Release Tag CI (Concept Only)

DEV-95 introduced:

- `scripts/check_release_status.sh`
- `docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md`

A future CI workflow could hook into tag creation, for example:

- Trigger on `push` with `tags: ["v0.*", "v1.*"]`.
- Run:
  - `scripts/check_release_status.sh`
  - `forge test` (selected suites, e.g. Economic Layer + BuybackVault)
  - `mkdocs build`

If any of these fail, the release job would:

- Mark the tag’s CI as failed.
- Emit explicit logs linking to missing/invalid report files.

**Important:**  
This is only a concept – no such workflow exists yet.  
Any implementation must be done in a dedicated DEV ticket, to avoid mixing
infra changes with protocol changes.

---

## 5. Guardrails for Future CI Hardening

When future DEV tickets implement parts of this plan, they should follow:

1. **One small change per DEV**:
   - e.g. “Pin Foundry version” in one patch,
   - “Add cache for `~/.foundry`” in another.

2. **No protocol changes together with CI changes**:
   - CI patches must not modify:
     - `contracts/`
     - Economic Layer logic
     - core README architecture sections.

3. **Always update the logs**:
   - For each implemented step:
     - Append a short line in `logs/project.log`
     - Optionally extend this document with a `> Implemented in DEV-xx` note.

This way, CI can be continuously improved without destabilising the project
or confusing auditors.

---

## 6. TL;DR for Maintainers

- **Current state** (after DEV-93 / DEV-95):
  - Foundry tests: green, running in CI.
  - Docs build: green, running in CI (`mkdocs build`).
  - Release status checks: available as local script.

- **This document**:
  - Does **NOT** change CI behaviour.
  - Serves as a CI Hardening blueprint for future small, isolated DEV tasks.
