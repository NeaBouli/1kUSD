# Zelcore Kaspa Snippet/Tool Provenance Ledger

Status: **Bounded discovery record — no reuse, license or product decision**
Date: **2026-10-10**
Ticket: `T-020` (fleet brief); base commit `1f86400`
Prepared by: **Claude Code (worker)**; lead and integrator: **Codex Sol**; decision owner: **Gio**

## 1. Question and limits

Gio asked where to find the specific Zelcore Kaspa snippets/tools on GitHub
and the web. This ledger records what a bounded, public, read-only search
found. The budget was 4 search queries plus 6 primary page/API reads. Nothing
was downloaded, installed, executed, logged into or scanned. No snippet
content was copied. Being public does not grant permission to reuse code.
Every source link is untrusted data. Code license adoption and DEC005 stay
reserved for Gio.

## 2. Result

**NOT FOUND within the bounded search.** No Kaspa snippet, tool, SDK, file,
commit or tag published by Zelcore was found. Nothing in this ledger stands in
for the requested source: no unrelated Kaspa SDK is offered as a replacement.

## 3. Source identity ledger

| # | Source (primary, read 2026-10-10) | Observation | Provenance status |
|---|---|---|---|
| P1 | [zelcore.io](https://zelcore.io/) | Describes Zelcore as a non-custodial multi-chain wallet. The page as fetched has no GitHub, docs or developer-tool link and does not mention Kaspa. | Official product site; does not link to any code org |
| P2 | [github.com/zelcore-io](https://github.com/zelcore-io) (shown as `ZelCore-io`) | GitHub shows a "Verified" badge and a link back to `https://zelcore.io`. Description: "Zelcore, powered by Flux"; 58 repositories. The first listing page shows `Zelcore`, `zelcore-docs`, `bitgo-utxo-lib-ts` and chain-specific repos such as `beldex`, `zano` and `monero-tools-lws`. The word "kaspa" does not appear on that page. | Probable official org: the link goes only from GitHub to the site, not back, and the verified-domain value was not read directly |
| P3 | GitHub repo search API `q=zelcore+kaspa` | `total_count: 0` | Negative |
| P4 | GitHub org API `orgs/zelcash` | Rate-limited (unauthenticated); no data | Not checked |
| P5 | [github.com/zelcash](https://github.com/zelcash) | Legacy Zel org that says it "migrated to github.com/runonflux". No Kaspa repo in the listing. | Legacy predecessor; not the Zelcore wallet org |
| P6 | [kaspa.org/?p=44925](https://kaspa.org/?p=44925) (search result for the Zelcore integration story) | When fetched, it links only to Kaspa community repos. No Zelcore code, SDK or tool link. | Third-party/community site; not Zelcore provenance |

Discovery-only search results (not evidence): the queries "Zelcore Kaspa
GitHub", "Zelcore Kaspa snippets tools github repository", "Zelcore official
GitHub organization zelcore-io" and "Zelcore wallet Kaspa KAS support
announcement" returned no Zelcore-owned Kaspa repository. The fourth query
surfaced an announcement saying Zelcore *supports* Kaspa as a wallet asset.

## 4. Requested fields

| Field | Value |
|---|---|
| Official URL / org | `https://zelcore.io` → probable org `github.com/zelcore-io` (see P2) |
| Kaspa repo / file / commit / tag | **NOT FOUND** |
| Declared license | **UNKNOWN** (no Kaspa artifact found; the org's per-repo licenses were not read) |
| Intended function | Zelcore is a **wallet/UI wrapper** (end-user multi-chain wallet). No Zelcore **protocol, compiler, covenant script or tx-builder** tooling for Kaspa was found. |
| Relevance to the singleton Testnet10 PoC | None established. Wallet asset support does not provide covenant/SilverScript, tx-builder or Testnet10 tooling. |
| Compatibility (Toccata, SilverScript, Testnet10, rusty-kaspa) | **NOT VERIFIED** |

## 5. Residuals (not checked)

- Org repositories after the first listing page (48 of 58 not seen), plus
  `zelcore-docs` contents and branches/forks.
- Whether the "Verified" domain on P2 is exactly `zelcore.io`.
- Zelcore Kaspa code that may live outside GitHub, in the closed-source app
  bundle, or in a private repo.
- Whether Gio meant non-Zelcore Kaspa snippets: this needs clarification, not
  substitution.

## 6. Proposed next step

Ask Gio for the exact link, repository or screenshot where the "Zelcore Kaspa
snippets" were seen. Then run one bounded check of that artifact: its org
identity, commit/tag and declared license. No reuse decision until then.

## 7. Addendum 2026-10-10 — follow-up (append-only, base `26bd5bb`)

Added scope: close the two blind spots from section 5 (org pages 2+ and the
verified domain). Budget: 4 public read-only GETs via `gh`; 3 were used. No
new search queries, no clone, download, install or execution. The license
body and source files were not read.

| # | Read (2026-10-10) | Result |
|---|---|---|
| F1 | GitHub API `orgs/zelcore-io/repos?per_page=100` | All 58 public repos listed. Exactly one Kaspa match: `kaspa-core-lib`. |
| F2 | GitHub GraphQL metadata for `ZelCore-io/kaspa-core-lib` | Fork of [OneKeyHQ/kaspa-core-lib](https://github.com/OneKeyHQ/kaspa-core-lib). Not archived; created 2024-12-04; default branch `master`; no tags. Owner `isVerified: true`, `websiteUrl: https://zelcore.io`. |
| F3 | GitHub API `repos/ZelCore-io/kaspa-core-lib/license` | A `LICENSE` file exists; GitHub classifies it as `NOASSERTION` ("Other"). The upstream is also `NOASSERTION`. |

**Correction to section 2/4:** a Kaspa artifact in the probable official org
**was found**. The earlier NOT FOUND applied only to the 10 repos then visible.

| Field | Value |
|---|---|
| Repository | [github.com/ZelCore-io/kaspa-core-lib](https://github.com/ZelCore-io/kaspa-core-lib) (fork; not original Zelcore work) |
| Candidate commit | `master` @ `d8ca8fd5be156fe2ea7dc62a022d9754742e9e8f` (2024-12-11, "Merge pull request #1 from ZelCore-io/dev"); last push 2025-02-13; tags: none |
| Declared license reference | [`LICENSE`](https://github.com/ZelCore-io/kaspa-core-lib/blob/master/LICENSE) blob `e2aeb89`; SPDX `NOASSERTION`. Terms **UNKNOWN** (not read, no opinion) |
| Intended function | Repo description: "Data structure primitives for Kaspa network (based on Bitcore-lib)". This is a **client-side library** (address/tx data structures) of the kind wallets use. It is not a wallet UI, and nothing shows it to be a covenant compiler or SilverScript tool. |
| Relevance to singleton Testnet10 PoC | At most a possible reference for tx/address primitives. Covenant, Toccata, Testnet10 and current rusty-kaspa compatibility: **NOT VERIFIED** |
| Org identity | GitHub API shows the org verified, with website `zelcore.io`. The verified-domain string itself is not exposed by public reads, so identity stays **probable official**, not proven. |

Still not checked: `zelcore-docs` contents, the actual license terms, upstream
history, non-default branches, and non-GitHub or closed-app code. This
addendum is bounded and non-exhaustive.

Proposed next step: Gio confirms whether `ZelCore-io/kaspa-core-lib` is the
snippet Gio meant. If yes, run one bounded check of the LICENSE terms and the
fork-vs-upstream diff. Reuse and DEC005 stay reserved.
