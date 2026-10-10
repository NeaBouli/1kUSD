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
