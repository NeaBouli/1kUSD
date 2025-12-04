# DEV-9 CI Failure Notes (main & dev9/docker-infra)

This document summarizes the current CI failures observed on
`main` and `dev9/docker-infra` branches. It is **descriptive only**:
no workflows are changed by DEV-9 18.

## 1. Foundry Tests CI – `forge install` failure

**Branches affected:**  
- `main`  
- `dev9/docker-infra` (inherits same workflows)

**Symptom (from GitHub Actions logs):**

- Job: **Foundry Tests CI / Run Foundry Tests (push)**
- Step: `forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit`
- Error: `error: unexpected argument '--no-commit' found`

**Interpretation by DEV-9:**

- The Foundry CLI version used in CI does **not** support the
  `--no-commit` flag.
- As a result, the `forge install` step fails before any tests run.

**Status for DEV-9:**

- DEV-9 does **not** modify this behavior in DEV-9 18.
- Fix options (for a future ticket, outside this patch) could include:
  - Adjusting the `forge install` arguments to match the pinned
    Foundry version.
  - Or removing the `forge install` step if dependencies are already
    vendored in `lib/` and tracked in git.

## 2. Docs Build – `mkdocs build --strict` failures

**Branches affected:**  
- `main`  
- `dev9/docker-infra` (same workflows)

**Symptom (from GitHub Actions logs):**

- Job: **📘 Deploy Docs / build-deploy (push)**
- Step: `mkdocs build --strict`
- Warnings:
  - Many pages under `docs/` exist but are not included in the `nav`
    configuration (e.g. `docs/README.md`, `docs/INDEX.md`, multiple
    `architecture/`, `logs/`, `reports/`, `releases/`, `specs/` files).
  - Several documents contain links to `../index.md`, but `index.md`
    is not found among documentation files.
- Result: `Aborted with 10 warnings in strict mode!` → exit code 1.

**Interpretation by DEV-9:**

- `mkdocs build --strict` treats these warnings as **build failures**.
- The repository intentionally contains many non-nav docs (logs,
  reports, specs), which is compatible with strict mode only if:
  - `nav` and file layout are fully aligned, or
  - strictness is relaxed or scoped.

**Status for DEV-9:**

- DEV-9 18 **does not change**:
  - `mkdocs.yml`
  - any docs workflow
  - the strictness settings
- The behavior is only documented here as a known CI status.

## 3. Scope Statement for DEV-9

- DEV-9’s mandate is **infra/CI planning and minimal hardening**:
  - Introduce pinned Foundry version in one workflow.
  - Add manual-only helper workflows (e.g. Docker baseline build,
    docs linkcheck).
  - Prepare plans for linkcheck and monitoring.
- Large-scale CI fixes (especially for `main`) require Architect
  approval and may be handled by dedicated roles (e.g. DEV-7, DEV-93,
  DEV-94).

DEV-9 18 is therefore **purely informational**:
it records the state of failing CI runs to make future fixes easier and
safer, without touching any workflows in this patch.
