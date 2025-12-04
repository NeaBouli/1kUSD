# 1kUSD Developer Quickstart

This document is a high-level onboarding guide for developers who want to
work on the 1kUSD repository. It explains how to set up a local environment,
how to run tests and docs, and how to follow the patch-based workflow used
in this project.

It complements the more detailed DEV-9 and DEV-10 documents as well as the
architecture and reports sections.

---

## 1. Repository & local setup

**Repository**

- GitHub: \`NeaBouli/1kUSD\`
- Typical local path: \`~/Desktop/1kUSD\`
- Default branch for stable code: \`main\`
- Feature branches are created per DEV role (e.g. \`dev9/docker-infra\`,
  \`dev8/security-risk-layer\`, etc.).

**Core dependencies (local)**

You will typically need:

- Git & GitHub CLI (\`gh\`),
- Python + virtualenv (for helper scripts, if used),
- Foundry (forge, cast),
- MkDocs (for documentation builds).

Exact versions are documented or pinned in the workflows and scripts.

---

## 2. Basic commands

From the repo root:

- **Run Foundry tests locally**

  ```bash
  forge test
(Some CI jobs may use additional flags; see the Foundry-related workflows
and DEV-9 docs for details.)

Build the documentation

bash
Code kopieren
mkdocs build
This should complete successfully without failing the build, even if MkDocs
emits warnings about pages not in the `nav` or legacy links.

Run GitHub CLI commands

For example, to list recent CI runs on a branch:

bash
Code kopieren
gh run list --branch YOUR_BRANCH_NAME --limit 5
Some workflows are designed to be triggered manually with
`workflow_dispatch`; see the DEV-9 operator guide for details.

3. Patch-based contribution model
The 1kUSD project uses a patch script + log entry workflow instead of
ad-hoc edits. The typical pattern:

Create a patch script under `patches/`:

filename usually encodes DEV role and ticket, e.g.
`patches/dev9_21_fix_forge_install_flag.sh`,

script is executable and idempotent where possible.

Script structure

A typical script:

bash
Code kopieren
#!/bin/bash
set -e

echo "== DEV-XX YY: short description =="

# perform changes (cat > file, sed, mkdir, etc.)

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-XX YY] ${timestamp} Short log message" >> "$LOG_FILE"

echo "== DEV-XX YY done =="
Execute the patch locally

bash
Code kopieren
bash patches/devXX_YY_whatever.sh
Stage, commit, push

bash
Code kopieren
git add <changed files>
git commit -m "devXX-YY: short description"
git push origin YOUR_BRANCH
The log entry in `logs/project.log` is mandatory: it provides a
chronological record of changes across DEV roles and tickets.

4. Scope boundaries & DEV roles
Work is typically organised by DEV roles (DEV-7, DEV-8, DEV-9, DEV-10, …),
each with a constrained scope.

Examples:

DEV-7 / DEV-9 – Infrastructure, CI, Docker, Docs build:

may touch workflows, Dockerfiles, docs,

must not change Economic Layer logic.

DEV-8 – Security & Risk documentation:

only writes docs under `docs/security`, `docs/risk`, etc.,

no contract changes.

DEV-10 – Integrations & Developer Experience:

writes integration guides under `docs/integrations`,

adds indexes / syncing reports,

does not touch contracts or CI workflows.

General rule:

If your role is documentation- or infra-only, avoid:

`contracts/`,

core economic logic,

automatic deploys or release pipelines.

Scope and taboos are usually described in the relevant DEV docs under
`docs/dev/`.

5. Key documentation entry points
If you are new to the project, recommended reading order:

Top-level README

overall purpose of 1kUSD,

CI / release badges,

links into docs and reports.

Architecture & economic layer

`docs/architecture/economic_layer_overview.md`

BuybackVault strategy / enforcement docs.

Reports & status

`docs/reports/REPORTS_INDEX.md` for an overview of:

Economic Layer v0.51.0 status,

BuybackVault & StrategyEnforcement reports,

Governance & CI docs reports.

Infra / CI (DEV-9)

`docs/dev/DEV9_Status_Infra_r2.md`

`docs/dev/DEV9_Backlog.md`

`docs/dev/DEV9_Operator_Guide.md`

Integrations & DevEx (DEV-10)

`docs/integrations/index.md`

PSM / Oracle / Guardian / BuybackVault integration guides,

`docs/dev/DEV10_Status_Integrations_r1.md`,

`docs/dev/DEV10_Backlog.md`.

6. Working with CI & docs
Docs build

The Docs Build workflow mirrors `mkdocs build`.

Warnings about pages not in `nav` or legacy links are expected and
are not blockers after strict mode was relaxed.

Manual workflows

Some workflows (e.g. docker baseline build, docs link check) are designed
to be triggered manually via GitHub Actions UI or `gh workflow run`.
See the DEV-9 operator guide for concrete names and usage.

CI failures

If CI fails on a feature branch:

first reproduce locally (`forge test`, `mkdocs build`),

then inspect the failing workflow and logs,

coordinate with the relevant DEV role (e.g. DEV-9 for infra, DEV-10 for
integrations).

7. When to talk to the architects
For most documentation or infra tasks, you can proceed as long as you stay
within your DEV role’s scope and the patch-based model.

You should escalate or sync with the architects when:

changes might affect Economic Layer behaviour,

new external dependencies / tools are introduced,

CI / deploy semantics change (e.g. new mandatory checks, release gates),

docs & specs diverge from actual on-chain behaviour.

For cross-cutting topics, check the relevant reports under
`docs/reports/` and reference them in your patches and commit messages.

This Quickstart is intentionally high-level. For more role-specific details,
consult the DEV-9 and DEV-10 documents, as well as any future DEV role
onboarding docs under `docs/dev/`.

---


---

## Dev CI smoketest (optional)

If you want to run a small local healthcheck that mirrors parts of the CI,
you can use the helper script:

```bash
patches/dev9_34_dev_ci_smoketest.sh
This script will, if available:

run `forge test`,

run `mkdocs build`,

execute `scripts/check_release_status.sh`.

It does not change contracts or configuration; it is only a convenience
helper for contributors before pushing patches.
