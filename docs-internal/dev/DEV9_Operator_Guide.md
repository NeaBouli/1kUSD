# DEV-9 Operator Guide

This document explains how to operate the DEV-9–related tooling without
changing any contracts or economic logic. It is intended for:
- repository maintainers,
- CI operators,
- future DEV roles taking over infra/CI responsibilities.

DEV-9 strictly stays within infra/docs scope.

---

## 1. Local basics (quick recap)

Recommended local setup:

- Python 3 with a virtual environment:
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate
  pip install -r requirements.txt  # if present
Foundry installed (see the official Foundry docs) if you want to
reproduce CI tests locally.

Docker installed if you want to build the baseline dev image locally.

DEV-9 never changes the Economic Layer (contracts/ logic). All steps
below are about tooling and documentation.

2. Foundry tests – relation to CI
2.1 Local Forge tests (minimal)
You can run the basic tests locally with:

bash
Code kopieren
forge test
For CI reference, look at:

.github/workflows/foundry-test.yml

DEV-9 pinned the Foundry version in one workflow as a reference
(e.g. nightly-2024-05-21). Any rollout to additional workflows must be
done in dedicated tickets and with Architect approval.

2.2 CI failures (high level)
As of DEV-9 18, CI failures on main and dev9/docker-infra are
documented in:

docs/dev/DEV9_CI_Failure_Notes.md

DEV-9 does not adjust those workflows in that patch; the file is
purely descriptive.

3. Docker baseline image
DEV-9 added a local tooling image and a manual CI workflow.

3.1 Dockerfile
The baseline Dockerfile lives at:

docker/Dockerfile.baseline

This image is intended for local use (tests, docs, experiments). It is
not a release image and not wired into automatic deploys.

3.2 Manual CI workflow: Docker baseline build
Workflow file:

.github/workflows/docker-baseline-build.yml

It is intentionally manual-only:

Trigger: workflow_dispatch (no push / pull_request)

How to run it in GitHub:

Go to the repository on GitHub.

Open the Actions tab.

Select workflow “Docker baseline build”.

Click “Run workflow” (usually on the default branch).

Wait for the job build-baseline to finish.

This workflow just runs:

bash
Code kopieren
docker build -f docker/Dockerfile.baseline -t 1kusd-dev:baseline .
No images are pushed to any registry by DEV-9.

4. Docs linkcheck workflow (manual)
DEV-9 added a manual docs linkcheck workflow as a first step.

Workflow file:

.github/workflows/docs-linkcheck.yml

Properties:

Trigger: workflow_dispatch only.

Scope: checks links under docs/.

Uses a linkcheck action (e.g. lycheeverse/lychee-action).

Does not modify any other workflows.

How to run it:

Go to Actions in the GitHub UI.

Select “Docs Linkcheck”.

Click “Run workflow”.

Inspect the logs:

This is non-blocking and only runs when triggered manually.

Future DEV roles may refine strict vs relaxed policies; DEV-9
documents the plan in:

docs/dev/DEV9_Linkcheck_Workflow_v1.md

docs/dev/DEV9_MkDocs_Linkcheck_Plan.md

5. MkDocs build & Pages (high level)
The docs system is based on MkDocs with a curated mkdocs.yml.

Useful commands:

Local docs build:

bash
Code kopieren
mkdocs build
Manual Pages deploy (from the repo root):

bash
Code kopieren
mkdocs gh-deploy --force --no-history
Important:

The CI docs build may run in --strict mode and can fail if:

documents referenced in nav are missing,

or certain warnings are elevated to errors.

DEV-9 does not change the strictness in the initial patches; the
current behavior is documented and future changes must be coordinated
with the Architect.

6. Patch & logging conventions (recap)
For all DEV-9 changes:

Each change is introduced via a small patch script under:

patches/dev9_XX_*.sh

The script:

performs file modifications (e.g. via cat <<'EOF' > file),

appends a single log line to:

logs/project.log

Example log format:

text
Code kopieren
[DEV-9 19] 2025-12-04T00:00:00Z Added DEV9_Operator_Guide.md
The log file is the canonical history of infrastructure changes.

7. Scope guard for future operators
Future DEV roles reusing this guide should respect the original
constraints:

No direct modifications to:

contracts/

Economic Layer core logic

BuybackVault core behavior (beyond already approved tickets)

CI/Docs/Docker changes must stay incremental and well-documented.

Larger behavior changes (deploys, releases, strategy toggles) require
explicit Architect-level approval.

DEV-9’s work is designed to make operating the project safer and more
transparent, without changing protocol economics.
