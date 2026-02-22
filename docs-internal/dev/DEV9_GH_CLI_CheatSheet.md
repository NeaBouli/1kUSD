# DEV-9 – GitHub CLI Cheatsheet (CI & Workflows)

This note collects practical `gh` commands used during DEV-9
to inspect CI runs and workflows for the 1kUSD repo.

## 1. Basic listing of failed runs

List recent **failed** runs across all branches:

```bash
gh run list --repo NeaBouli/1kUSD --status failure --limit 50
Limiters you can add:

--branch main

--branch dev9/docker-infra

--status failure|success|in_progress

Example (only failures on dev9/docker-infra):

bash
Code kopieren
gh run list --repo NeaBouli/1kUSD \
  --branch dev9/docker-infra \
  --status failure \
  --limit 20
2. Inspect a specific run
From gh run list you get an ID column.
Use it to view details or logs:

bash
Code kopieren
gh run view <RUN_ID>
gh run view <RUN_ID> --log
If --log fails with “log not found”, it usually means:

the job finished extremely quickly, or

the selected workflow run has no attached log (e.g. it was skipped).

3. Filter by workflow
To focus on a specific workflow name (e.g. Foundry Tests CI):

bash
Code kopieren
gh run list --repo NeaBouli/1kUSD \
  --workflow "Foundry Tests CI" \
  --status failure \
  --limit 20
For the docs build workflow (📘 Deploy Docs):

bash
Code kopieren
gh run list --repo NeaBouli/1kUSD \
  --workflow "📘 Deploy Docs" \
  --status failure \
  --limit 20
Note: workflow names must match exactly what you see under the
Actions tab in GitHub.

4. Typical DEV-9 CI debugging loop
List failures for the branch you care about:

bash
Code kopieren
gh run list --repo NeaBouli/1kUSD \
  --branch dev9/docker-infra \
  --status failure \
  --limit 20
Pick the most relevant run ID (usually the newest).

Inspect logs:

bash
Code kopieren
gh run view <RUN_ID> --log
Identify the failing job (e.g. “Foundry Tests CI”, “📘 Deploy Docs”)
and look at the error message (e.g. mkdocs strict warning, forge CLI error).

Only after the problem is understood:

prepare a small patch script under patches/,

run it locally,

git add only the relevant files,

commit & push from the feature branch.

5. Manual workflow dispatch (from the UI)
For workflows that are manual-only (on: workflow_dispatch), like:

docker-baseline-build.yml

docs-linkcheck.yml

Use the GitHub Actions UI:

Go to Actions in the repo.

Select the workflow, e.g. Docs Linkcheck.

Click “Run workflow”.

Choose the branch (e.g. dev9/docker-infra) if asked.

Watch the run and, if needed, fetch details via gh run list / gh run view.

This file is intentionally DEV-9-specific and can be extended by future
infra devs (DEV-10, DEV-11, …) if they adopt the same gh-based workflow
debugging pattern.
