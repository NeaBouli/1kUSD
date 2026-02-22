# DEV-94 – How to cut a release tag (v0.51.x)

## 1. Scope & audience

This document is a practical step-by-step guide for **maintainers / owners**
of the 1kUSD repository who need to cut a **release tag** for the
`v0.51.x` line.

It builds on the high-level description in
`DEV94_ReleaseFlow_Plan_r2.md` and focuses on concrete commands and a
repeatable flow. It does **not** change CI, contracts, or the economic
layer; it only describes how to use the existing release tooling.

## 2. Prerequisites

Before you start, make sure:

- You have a working local checkout of the repository.
- You can run the same tooling as CI:

  - `forge` for tests
  - `mkdocs` for docs build
  - `bash` for helper scripts

- You are on the **`main`** branch and your working tree is clean:

```bash
git checkout main
git status
# should show: "nothing to commit, working tree clean"
The release you want to tag belongs to the Economic Layer v0.51.x
baseline (no protocol-breaking changes beyond that scope).

For more context on the release flow and required reports, see:

DEV94_ReleaseFlow_Plan_r2.md

docs/reports/PROJECT_STATUS_EconomicLayer_v051.md

docs/reports/REPORTS_INDEX.md

3. Step 1 – Local pre-release checks
Before creating any tag, run the following checks locally and ensure they
all succeed.

3.1 Update main
bash
Code kopieren
git checkout main
git pull --ff-only origin main
The --ff-only flag ensures you are on top of the remote main without
creating merge commits.

3.2 Run Foundry tests
bash
Code kopieren
forge test
All tests MUST pass. If there are failures, investigate and fix them
before proceeding. Do not tag a release from a failing test state.

3.3 Build documentation
bash
Code kopieren
mkdocs build
This checks that the documentation is internally consistent and that the
MkDocs configuration is valid. The command should complete without
errors.

3.4 Run the release status check script
bash
Code kopieren
scripts/check_release_status.sh
This script verifies that required status and report documents for the
current economic / governance / security state are present and non-empty.
It should end with a message similar to:

All required status/report files are present and non-empty.
You can safely proceed to create a release tag (from this perspective).

If the script fails or reports missing files, fix those issues before
tagging.

4. Step 2 – Tag naming and semantics
For the current baseline, tags follow the pattern:

v0.51.x

where:

0.51 identifies the Economic Layer baseline (v0.51),

x is an integer patch-level (e.g. 0, 1, 2, ...).

Examples:

v0.51.0 – first public tag on the v0.51 baseline

v0.51.1 – patch release (docs, infra, integrations, minor fixes)

v0.51.2 – next patch release, and so on

When choosing the next tag:

Check existing tags:

bash
Code kopieren
git tag --list "v0.51.*" | sort -V
Pick the next free patch number (for example, if v0.51.0 and
v0.51.1 exist, the next one is v0.51.2).

5. Step 3 – Creating and pushing the tag
Once all pre-release checks are green and you have decided on the next
tag name (v0.51.x), you can create and push the tag.

5.1 Create the tag locally
Make sure you are on main and at the commit you want to tag:

bash
Code kopieren
git checkout main
git pull --ff-only origin main
Then create the tag (replace v0.51.1 with your chosen tag):

bash
Code kopieren
git tag v0.51.1
You can optionally add an annotated tag with a message:

bash
Code kopieren
git tag -a v0.51.1 -m "1kUSD v0.51.1 – infra/docs/integrations updates"
5.2 Push the tag to origin
Push the tag to the remote repository:

bash
Code kopieren
git push origin v0.51.1
After this step, GitHub will show the tag under the repository's "Tags"
view, and any CI workflows configured to run on tags may be triggered.

6. Step 4 – Post-tag checks
After pushing the tag, monitor:

CI status for the tag (if applicable):

Ensure that Foundry tests and docs builds (and any release-status
checks wired into CI) are green for the tagged commit.

Release documentation:

Confirm that status reports and economic layer documents referenced
by scripts/check_release_status.sh are still valid for this tag.

Communication:

If you announce the release, include:

the tag name (v0.51.x),

a brief summary of what changed since the previous tag,

any relevant links to reports in docs/reports/ and DEV-94 docs.

If CI fails for the tag, treat the tag as invalid until the issues
have been understood. Avoid announcing the release until CI is green.

7. TL;DR checklist
Use this quick checklist when cutting a release tag for the v0.51.x line:

 On main, clean working tree (git status clean)

 git pull --ff-only origin main completed successfully

 forge test passed locally

 mkdocs build completed without errors

 scripts/check_release_status.sh reported all required reports present

 Tag name chosen according to v0.51.x pattern and available

 Tag created on main at the intended commit

 Tag pushed to origin

 CI for the tag is green (tests/docs/release-status as applicable)

 Optional: release announcement prepared with references to reports
## OracleRequired docs gate (v0.51+)

For all v0.51+ release tags, the release manager MUST:

1. Run `./scripts/check_release_status.sh` and ensure it exits with code 0.
2. Check that the output includes the OracleRequired docs gate summary lines:
   - `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
   - `DEV94_Release_Status_Workflow_Report.md`
   - `BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`
   - `DEV11_OracleRequired_Handshake_r1.md`
   - `GOV_Oracle_PSM_Governance_v051_r1.md`
3. Treat any non-zero exit code or `[ERROR] OracleRequired release gate` output
   as a **hard block** for cutting a v0.51+ tag. Fix the underlying reports
   before proceeding.

This OracleRequired docs gate complements the economic/test status checks
but does not replace them.

