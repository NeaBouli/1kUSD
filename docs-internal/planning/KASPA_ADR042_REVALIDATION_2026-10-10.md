# ADR-042 Revalidation Against SilverScript v1 and rusty-kaspa v2.1.0

Status: **Documentation prepared for review — not G3 acceptance**
Date: **2026-10-10**
Ticket: [`1K-P1-017` / #131](https://github.com/NeaBouli/1kUSD/issues/131)
Parent decision: [`ADR-042`](../adr/ADR-042-kaspa-toccata-execution-architecture.md) (Accepted 2026-08-16, unchanged)
Related: [`KASPA_POC_ACCEPTANCE_PLAN.md`](KASPA_POC_ACCEPTANCE_PLAN.md),
[`KASPA_THREAT_MODEL.md`](../core/KASPA_THREAT_MODEL.md)
Prepared by: **Claude Code (worker)**; lead and integrator: **Codex Sol**; decision owner: **Gio**

## 1. Purpose and limits

This note checks whether ADR-042's accepted singleton control/reserve design still
holds against already-gathered, dated upstream evidence. It records the
dispositions, the acceptance checks, and the decisions that remain open.

It does **not** re-approve or replace ADR-042, authorize a PoC, adopt a toolchain,
choose a license, or claim PoC readiness, runtime compatibility, audit status, or
production fitness. No code, build, install, scanner, RPC, wallet, key, signing,
transaction, or spending action was performed.

## 2. Evidence basis

| Source | Date / window | Scope | Status |
|---|---|---|---|
| T-008 evidence report `KASPA_REVALIDATION_2026-10-10.md` (finalized at `ab2fdb6`; published separately through the dependent planning PR) | upstream reads 2026-10-09 21:27–21:55Z | read-only GitHub releases, tagged files, API compare, `docs.kaspa.org` | worker evidence; full matrix not independently re-verified |
| T-015 independent source review | 2026-10-09 22:20–22:30Z | five central source propositions | 4 PASS; 1 MSRV wording correction applied |
| Node tag resolution for this note | 2026-10-09T23:20Z, one GitHub API GET | `refs/tags/v2.1.0` of `kaspanet/rusty-kaspa` | lightweight tag → commit (below) |

This note did not repeat the research. Any fact not in these sources is marked
**UNVERIFIED**. Source observations are dated and are not a promise of current
upstream compatibility.

## 3. Result

1. No verified upstream fact invalidates the singleton control/reserve design.
   **Disposition: ADR-042 decision unchanged.**
2. ADR-042's own reconsideration trigger ("Silverscript, transaction-v1,
   covenant, or fee semantics change materially") is met by the SilverScript v1
   language/ABI changes and by node script-unit accounting. The required
   response is revalidation (this note) plus added acceptance checks, not a new
   architecture.
3. Several premises are stale. The main ones: the compiler no longer names a
   network, compiler and node versions differ, and the official Toccata docs
   predate v1.
4. The PoC boundary is preserved without change: one singleton control/reserve
   state; synthetic, zero-value collateral; at most `10,000` synthetic 1kUSD
   units and 100 live boxes; no shard, fan-out, based app, hybrid, vProgs
   runtime, user lane, or real bridge.

## 4. Candidate toolchain manifest — NON-ADOPTED

Every row is a **candidate observed at the dated source**. None is adopted, and
no pin choice is made here.

| Component | Candidate identity | Adoption | Notes |
|---|---|---|---|
| SilverScript compiler | tag `v1.0.0` → `3ed973335b59269293564805cc2c58a14595ec03` | NON-ADOPTED | only non-prerelease; `master` identical at research time; upstream security policy still calls it experimental and supports latest `master` only |
| Compiler's `kaspa-*` dependency | git rev `a41a333b08848f41bf737b72592e463a6011b8ac` | NON-ADOPTED | unreleased node revision, ancestor of v2.1.0; upstream switch to v2.1.0 (PR #257) open at research time |
| Node | `rusty-kaspa` tag `v2.1.0` → `01b532e8b553523216471682649693af92f0fd16` | NON-ADOPTED | lightweight tag resolved 2026-10-09T23:20Z |
| Rust toolchain | upstream MSRV `1.94.0` | exact toolchain **UNSELECTED** | MSRV is a minimum, not a reproducibility pin |
| Transaction builder / SDK | — | **UNSELECTED** | required by ADR-042 toolchain policy |
| Network | Testnet-10 (node v2.1.0 `TESTNET_PARAMS`, suffix 10) | not selected for execution | see D1; genesis/liveness NOT VERIFIED |
| License metadata | SilverScript: ISC (crate/LICENSE metadata at tag) | metadata only | node license UNVERIFIED here; no compatibility or legal conclusion (DEC-005 stays open) |
| Zelcore tools/snippets | exact source, version, license **unknown** | unadopted | needs exact pointer, version, license text and separate provenance assessment |

Verification status of manifest properties:

| Property | Status |
|---|---|
| Compiler ↔ node compatibility (`a41a333b` build vs v2.1.0 node) | NOT VERIFIED |
| Upstream advisory → fix-commit mapping for the compiler candidate | NOT VERIFIED |
| Network identity, genesis, activation on live chain, liveness | NOT VERIFIED |
| Compiler binary/source/artifact/bytecode hashes | NOT RUN |
| Script-unit, compute/storage mass, fee measurements | NOT RUN |
| Two-machine reproduction, indexer replay | NOT RUN |

No row above holds a zero, placeholder hash, or PASS value. The candidate
revisions are not described as safe or unsafe in general. The question is
whether they are acceptable as a 1kUSD project pin.

## 5. D1–D15 dispositions

Status enum: `unchanged` · `wording-delta` · `acceptance-check` · `owner-decision`.
Each row has exactly one disposition. "Blocked proof" names the execution
evidence that does not exist yet. The basis column refers to the evidence report
§2–§4 (window 2026-10-09 21:27–21:55Z) unless stated otherwise.

| # | Topic | Disposition | Dated source basis | Blocked execution proof |
|---|---|---|---|---|
| D1 | Compiler repo no longer recommends Testnet-10 | `wording-delta` | README change history to v1.0.0; node v2.1.0 params | pre-execution network/genesis/liveness check — NOT RUN |
| D2 | Release is not "supported stable"; fixes on latest `master` only | `owner-decision` | tagged `SECURITY.md` vs v1.0.0 release notes | pin and advisory-tracking policy — UNSELECTED |
| D3 | Template hash / dispatch tag / identity format changed | `acceptance-check` | v1 changelog range (hash hardening, BLAKE3) | independent recomputation on two clean machines — NOT RUN |
| D4 | Covenant declaration modes (singleton, termination opt-in, N:M) | `acceptance-check` | `docs/DECL.md` at v1.0.0 | strict-singleton and bearer N:M tests — NOT RUN |
| D5 | Upstream KCC20-shaped example vs custom bearer boxes | `owner-decision` | KCC20 book at v1.0.0 (example, not a found KIP) | none until decided |
| D6 | Portable ABI artifacts, `check_consistency` | `acceptance-check` | v1 ABI/artifact changes | manifest against v1 schema + consistency result — NOT RUN |
| D7 | Runtime-dependent initial state rejected; resource limits | `acceptance-check` | v1 limits/initial-state changes | compile-time genesis + rejected limit-violating variant — NOT RUN |
| D8 | Undefined behaviour may not fail reliably | `acceptance-check` | `UNDEFINED-BEHAVIOUR.md` at v1.0.0 | explicit guard + negative test per guard — NOT RUN |
| D9 | Temporal values with explicit DAA/time domains | `owner-decision` | v1 temporal builtins | freshness-domain choice; boundary tests after decision — NOT RUN |
| D10 | Hash/signature builtins changed | `owner-decision` | v1 crypto/introspection changes | report hash/signature scheme (#106-adjacent) — UNSELECTED |
| D11 | Strict typing, explicit conversions | `acceptance-check` | v1 type/evaluation changes | rounding/decimals vectors — NOT RUN |
| D12 | Node script-unit accounting vs compiler built on pre-v2.1.0 rev | `acceptance-check` | v2.1.0 release notes; compiler `Cargo.toml`; PR #255/#257 open | on-node measurement and skew record — NOT RUN |
| D13 | KIP-24/25 still unmerged | `unchanged` | KIP PRs #41/#42 open at research time | n/a; a merge stays a review trigger |
| D14 | Official Toccata docs predate v1 | `wording-delta` | `docs.kaspa.org` pages still on pre-v1 syntax | n/a; pinned repo tag is authoritative |
| D15 | Published critical compiler advisory without patched-version metadata | `acceptance-check` | upstream advisory metadata (details deliberately not reproduced) | fix-commit mapping vs adopted pin — NOT VERIFIED |

Wording deltas (D1, D14) are recorded as an append-only note on ADR-042. The
accepted decision text is not rewritten.

## 6. Testnet-10 rationale

- **Old rationale (ADR-042, 2026-08-13):** the SilverScript repository
  recommended Testnet-10. That recommendation is gone in v1.0.0.
- **Current documentary basis:** node `v2.1.0` defines Testnet-10 as its testnet
  parameter set. This is a **node parameter fact**, not a compiler
  recommendation and not runtime proof.
- **Not established:** network liveness, faucet, current node versions on the
  network, and genesis/activation on the live chain. These need a later,
  separately permitted pre-execution check. The PoC plan's existing "revalidated
  immediately before execution" rule still applies.

## 7. Acceptance-check deltas (to the PoC plan; nothing executed)

The existing gates stay as they are: ≥20% compute and storage mass headroom,
debugger plus real-node validation, two-machine source-to-bytecode reproduction,
two independent indexer replays, and the High/Medium review exit. The appended
plan addendum adds:

- **Manifest:** exact compiler commit, dependency rev, node commit, exact Rust
  toolchain, builder/SDK, and network/genesis. Each is recorded as adopted only
  after an owner pin decision.
- **Routes:** bootstrap, mint, transfer split/merge/change, redeem, Guardian
  pause, and governance resume/epoch advance. Each runs on the adopted node and
  measures script units and mass.
- **Negative tests:** zero or two control successors, termination path,
  foreign template, wrong dispatch tag, a limit-violating genesis variant, one
  negative per UB-sensitive guard, and rounding off-by-one at each decimals
  boundary.
- **ABI/hash:** v1 artifact schema, `check_consistency` result, and template
  hash, dispatch tag and covenant ID recomputed independently by compiler and
  indexer.
- **Skew/advisory:** the compiler/node version skew is recorded. The advisory
  fix mapping must be verified against the adopted pin before execution.
  Otherwise execution stops.

## 8. Pending owner decisions (none taken here)

| Decision | Source rows | Owner |
|---|---|---|
| Compiler/node pin and advisory-tracking policy (v1.0.0 with skew vs later upstream alignment) | D2, D12, D15 | Gio |
| KCC20-shaped interface vs custom bearer-box format | D5 | Gio (architecture) |
| Oracle report hash, signature builtin, freshness time domain | D9, D10 | Gio (#106) |
| Exact Rust toolchain and builder/SDK | §4 | Gio |
| Toolchain license compatibility (DEC-005) | §4 | Gio (legal) |
| Zelcore provenance, if ever proposed | §4 | Gio |

Fees, governance, collateral, language/ABI choice, and token economics are not
touched.

## 9. Gates and next step

- **G3 remains open.** Closing this documentation task does not close G3. G3
  needs independent review of this note, Codex lead verification, and Gio's
  acceptance.
- **Codex Security: NOT RUN.** For this docs-only delta it is N/A. A future scan
  needs explicit approval of destination, transmitted code, exclusions, and cost
  limit. It does not replace operator, specialist, runtime, or UI gates.
- **Next offline proposal (queued, not authorized):** a bounded, offline,
  reproducible singleton-transition compile proof. It would use one minimal
  contract with only `nonce`/`paused`, with no value, oracle, keys, or network.
  It would target D3, D4, D6, and D7 and would need its own ticket, threat model,
  and owner approval after G3.
- No professional audit, scan PASS, PoC-readiness, or production claim follows
  from this note.
