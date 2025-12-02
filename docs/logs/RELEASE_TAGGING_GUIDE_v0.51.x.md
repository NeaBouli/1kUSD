# 1kUSD – Release Tagging Guide (v0.51.x baseline)

This document describes a **manual, conservative release flow** for the
1kUSD Economic Layer around the v0.51.x baseline.

It focuses on:

- keeping the Economic Layer / BuybackVault contracts stable,
- making sure status/reports/docs are in a good shape,
- avoiding surprise changes in CI / Docker / Pages.

---

## 1. Preconditions

Before tagging a new release (e.g. `v0.51.1`):

1. **Working tree clean**

   ```bash
   git status
No uncommitted changes (apart from local experiments you don't intend
to push).

On the correct branch (usually main).

Tests green

bash
Code kopieren
forge test -vv
All suites should pass.

Economic Layer, PSM, Guardian, BuybackVault & StrategyGuard tests
are already wired into the current test set.

Docs buildable (CI + local)

CI: the Docs Build workflow badge in README.md shows green:

Workflow: .github/workflows/docs-build.yml

Action: mkdocs build on push / pull_request to main.

Optional local check:

bash
Code kopieren
mkdocs build
2. Status / Report files check
Before tagging, run the local helper script:

bash
Code kopieren
scripts/check_release_status.sh
This script verifies that the key status/report files are present and
non-empty, including:

docs/reports/PROJECT_STATUS_EconomicLayer_v051.md

docs/reports/DEV60-72_BuybackVault_EconomicLayer.md

docs/reports/DEV74-76_StrategyEnforcement_Report.md

docs/reports/DEV87_Governance_Handover_v051.md

docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md

docs/reports/DEV93_CI_Docs_Build_Report.md

If everything is present, the script prints:

All required status/report files are present and non-empty.
You can safely proceed to create a release tag (from this perspective).

If not, fix the missing/empty files before tagging.

3. Tagging a new release
Assuming all preconditions are satisfied:

Decide on the version, e.g.:

v0.51.1 – minor Infra/Docs improvements

v0.52.0 – would be used once StrategyEnforcement is activated in
production (future work, governance decision).

Create an annotated tag locally:

bash
Code kopieren
VERSION="v0.51.1"
git tag -a "$VERSION" -m "1kUSD Economic Layer $VERSION"
Push the tag:

bash
Code kopieren
git push origin "$VERSION"
Create a GitHub Release for the tag:

Go to the GitHub Releases page.

Select the tag (e.g. v0.51.1).

Use the prepared release text (e.g. from docs/releases/ or your
mini-release notes), referencing:

the Economic Layer baseline,

the optional StrategyEnforcement Phase-1 guard,

Docs/CI changes (e.g. DEV-93 docs-build workflow).

4. GitHub Pages / Docs
Pages deployment remains manual:

Make sure main is up to date and includes all release-related docs.

Run:

bash
Code kopieren
mkdocs gh-deploy --force --no-history
Confirm that the site is reachable at:

https://NeaBouli.github.io/1kUSD/

Important:

Pages content is not strictly tied to tags; it reflects the state of the
branch you deployed from (usually main).

The release tag documents a code/docs snapshot; Pages is a view
on a certain commit you choose to deploy.

5. Relation to DEV-Reports
This flow is designed to be consistent with:

DEV60-72_BuybackVault_EconomicLayer.md

DEV74-76_StrategyEnforcement_Report.md

PROJECT_STATUS_EconomicLayer_v051.md

DEV87_Governance_Handover_v051.md

DEV89_Dev7_Sync_EconomicLayer_Security.md

DEV93_CI_Docs_Build_Report.md

The idea:

Economic Layer v0.51.0 is the stable baseline.

StrategyEnforcement Phase-1 is implemented, tested and documented, but
remains an opt-in guard until the DAO decides to enable it.

CI and docs-build guard against drift in tests and docs.

6. Future refinements (separate tickets)
Potential future improvements to this flow:

CI workflow triggered on release tags, which:

runs a light regression test set,

verifies that key status reports are present and reference the tag.

Automation around Pages:

tagging a release could optionally trigger a build and deploy of the
docs for that tag into a versioned docs space.

These remain out of scope for the current v0.51.x baseline and should
be implemented as small, separate Infra tasks when needed.
