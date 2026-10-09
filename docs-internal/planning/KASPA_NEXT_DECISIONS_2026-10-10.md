# Kaspa PoC — Next Owner Decisions and Upstream Delta

Status: **Decision packet for review — no decision taken, not G3 acceptance**
Date: **2026-10-10**
Ticket: [`1K-P1-017` / #131](https://github.com/NeaBouli/1kUSD/issues/131)
Base note: [`KASPA_ADR042_REVALIDATION_2026-10-10.md`](KASPA_ADR042_REVALIDATION_2026-10-10.md) (M4, unchanged)
Related: [`ADR-041`](../adr/ADR-041-kaspa-primary-product-track.md),
[`ADR-042`](../adr/ADR-042-kaspa-toccata-execution-architecture.md) (Accepted, unchanged),
[`KASPA_POC_ACCEPTANCE_PLAN.md`](KASPA_POC_ACCEPTANCE_PLAN.md),
[`DECISIONS.md`](../../docs/agent-bridge/DECISIONS.md)
Prepared by: **Claude Code (worker)**; lead and integrator: **Codex Sol**; decision owner: **Gio**

## 1. Scope and map position

Planning hop only: accepted singleton ADR-042 → candidate evidence →
**reserved owner decisions (this packet)** → future G3/PoC scope. No execution
hop, no architecture change. Nothing here adopts a toolchain, pin, license,
interface, or oracle scheme. No build, install, RPC, wallet, transaction,
scanner, or spending action was performed. Every listed upstream item is
**public upstream state**. None of it is 1kUSD adoption or runtime evidence.

## 2. Upstream delta since the M4 observations

M4 window: 2026-10-09 21:27–21:55Z, node tag resolved 23:20Z (base note §2).
This check: seven unauthenticated public reads, **2026-10-09 23:51:05–23:51:31Z**
(local date 2026-10-10). The gap is about two hours, so a null delta is expected
and proves nothing about later state.

| Item | Observed now | vs M4 |
|---|---|---|
| [SilverScript latest release](https://github.com/kaspanet/silverscript/releases/tag/v1.0.0) | `v1.0.0`, published 2026-09-09T16:48:31Z, not prerelease | unchanged |
| SilverScript tag `v1.0.0` ref | commit `3ed973335b59269293564805cc2c58a14595ec03` | unchanged |
| [rusty-kaspa latest release](https://github.com/kaspanet/rusty-kaspa/releases/tag/v2.1.0) | `v2.1.0`, published 2026-09-22T13:55:36Z, not prerelease | unchanged (commit `01b532e8…` from base note §4, not re-read) |
| [SilverScript PR #257](https://github.com/kaspanet/silverscript/pull/257) "Switch Rusty Kaspa dependencies to crates.io v2.1.0" | `open`, not merged, last updated 2026-10-06T10:39:05Z | unchanged |
| [KIP-24 / PR #41](https://github.com/kaspanet/kips/pull/41) | `open`, not merged | unchanged (D13) |
| [KIP-25 / PR #42](https://github.com/kaspanet/kips/pull/42) | `open`, not merged | unchanged (D13) |
| [docs.kaspa.org Toccata agent brief](https://docs.kaspa.org/toccata/agent-brief) | HTTP 200. Describes tx v1, `compute_budget`, covenant bindings. No SilverScript version or page date found | **UNKNOWN** whether D14 changed; page has no version marker |

**Result: no observed delta within read scope.** These items were not re-read
and keep their base-note status: the compiler `kaspa-*` dependency rev
`a41a333b…`, the MSRV `1.94.0`, the advisory metadata (D15), the node license,
and Testnet-10 parameters.

## 3. Candidate relation (public upstream, non-adopted)

- Compiler `v1.0.0` (`3ed97333…`) is built against unreleased node rev
  `a41a333b…`. That rev is an ancestor of node `v2.1.0` (`01b532e8…`). The
  alignment PR #257 is still open. **Skew persists. Compatibility is NOT
  VERIFIED.**
- Upstream `SECURITY.md` supports only the latest `master`, not the `v1.0.0`
  tag (D2). The advisory → fix-commit mapping against any candidate is **NOT
  VERIFIED** (D15).
- Rust: `1.94.0` is the upstream **MSRV**, a minimum. It is not a
  reproducibility pin. The exact toolchain is **UNSELECTED**.
- Network liveness, genesis, activation, and node versions in the field: **NOT
  VERIFIED**. No live-network proof exists.

## 4. Decision rows (options, proposals only)

Each "proposed" line is a worker recommendation for Gio. It is **not** a decision.

**R1 — Compiler/node pin and advisory-tracking policy** (D2, D12, D15)
- Options: (a) pin `v1.0.0` and record the skew; (b) wait for a `master`
  commit or release that includes #257 or later alignment, then pin it;
  (c) track `master` continuously.
- Tradeoff: (a) is reproducible but sits outside upstream support and keeps
  the skew. (b) gets aligned dependencies but has no date and needs a fresh
  check. (c) has the best fix coverage but no reproducibility.
- Proposed: (b) as the target pin policy. Allow (a) only for the offline
  compile proof, with the skew recorded. Reject (c) for any PoC run.
- Evidence prerequisites: an advisory → fix-commit mapping for the chosen
  commit, and a compiler↔node compatibility record.
- Smallest next ticket: a read-only advisory/fix mapping check for the
  candidate commits. No build and no reproduction.

**R2 — Token interface** (D5)
- Options: (a) a KCC20-shaped interface following the upstream example;
  (b) a custom minimal bearer-box format.
- Tradeoff: (a) may help wallet and indexer familiarity, but it is an example,
  not a KIP. (b) has a smaller audit surface and maps directly to ADR-042
  drivers 1–3 and 7.
- Proposed: (b) for the PoC. Revisit (a) only if a KIP-level standard exists.
- Evidence prerequisites: a mapping of each format to the conservation, N:M,
  and reconstructibility checks in the PoC addendum.
- Smallest next ticket: a docs-only interface comparison note (architecture
  review, no code).

**R3 — Oracle report hash, signature builtin, freshness time domain** (D9, D10, [#106](https://github.com/NeaBouli/1kUSD/issues/106))
- Options: the hash and signature come from the v1 builtins; the freshness
  domain is either a DAA score or a block-time value.
- Tradeoff: a DAA score is consensus-native, but its mapping to wall-clock
  staleness is approximate. Block time is intuitive but has a weaker ordering
  guarantee.
- Proposed: decide the domain first, inside #106. The hash/signature choice
  follows from the #106 threat-model delta. Oracle trust stays protected.
- Evidence prerequisites: a #106 threat-model delta and builtin semantics at
  the pinned compiler (depends on R1).
- Smallest next ticket: a #106 threat-model delta for the domain choice
  (docs only).

**R4 — Exact Rust toolchain and builder/SDK** (base note §4)
- Options: (a) the exact MSRV `1.94.0`; (b) the exact toolchain that upstream
  CI uses at the pinned commits; (c) the latest stable at the time of the
  decision.
- Tradeoff: (a) is the minimum and may be untested upstream. (b) is the best
  reproduction match but is UNKNOWN until R1. (c) drifts.
- Proposed: (b), recorded only after R1. Choose the builder/SDK from the
  pinned node tag's crates. No third-party SDK.
- Evidence prerequisites: R1 decided, and the upstream toolchain file or CI
  version at those commits.
- Smallest next ticket: after R1, read the upstream toolchain/CI metadata at
  the pinned commits (read-only).

**R5 — Toolchain license compatibility** ([`DEC-005`](../../docs/agent-bridge/DECISIONS.md), open)
- Options: as listed in DEC-005 (GPL-3.0 / AGPL-3.0 / documented per-file
  model). Compiler metadata says ISC. The node license is UNVERIFIED.
- Tradeoff: this is a legal question outside the worker's competence. No
  compatibility conclusion is drawn.
- Proposed: keep DEC-005 open. Use upstream only as external tools, and vendor
  or copy no upstream code until legal review.
- Evidence prerequisites: the node license text at the candidate tag, plus
  legal review.
- Smallest next ticket: record the license metadata at the pinned tags
  (read-only), then hand off to legal.

**R6 — Optional Zelcore provenance**
- Options: (a) do not use; (b) assess, once an exact source, version, and
  license are supplied.
- Tradeoff: no Zelcore artifact is identified. Any assessment now would be
  speculation.
- Proposed: (a) until someone proposes an exact pointer.
- Evidence prerequisites: an exact repository/package, version/commit, license
  text, and a separate provenance review.
- Smallest next ticket: none until a concrete proposal exists.

## 5. Preserved boundaries and separate gates

- Unchanged: one singleton control/reserve state; synthetic zero-value
  collateral; at most `10,000` synthetic units and 100 live boxes; ≥20% compute
  and storage mass headroom. No shard, fan-out, based app, hybrid, vProgs,
  user lane, or real bridge.
- **G3 remains open.** It needs independent review, Codex lead verification,
  and Gio's acceptance. This packet does not close it.
- Separate gates, none satisfied here: private operator, specialist review,
  runtime/real-node, UI, and Codex Security. **Codex Security: NOT RUN.**
  Advisory mapping, compatibility, measurement, reproduction, and indexer
  replay: **NOT RUN / NOT VERIFIED**.
- No claim that G3, PoC, audit, or production work is done.
