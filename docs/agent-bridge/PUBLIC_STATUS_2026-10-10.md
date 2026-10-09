# 1kUSD Public Status and Work Plan — 2026-10-10

Public-safe summary of the current project state and the modular work queue.
It records status only; it does not approve any ticket, decision, merge,
deployment, or release. Canonical rules remain in
[`COOPERATION_RULES.md`](COOPERATION_RULES.md); the ticket table remains in
[`TICKET_LIST.md`](TICKET_LIST.md).

## Current truth

- 1kUSD is an EVM research/testnet prototype. **Production: NO-GO.** No main
  merge, deployment, wallet, key, network, or real-funds action is authorized
  by this document.
- Keep these states separate: *implemented* (code exists on a branch),
  *merged* (on `main`), *deployed* (on a network), *live* (in real use).
  Nothing in this plan is deployed or live.
- `main` is at `2a5ec38` (PR #128 merge).
- Released third-party toolchains do not imply production readiness. Any
  wallet integration such as Zelcore requires an exact source, version, and
  license review first; none is adopted.
- No economic, governance, license, or architecture decision is made here.
  Open decisions stay with their owners in [`DECISIONS.md`](DECISIONS.md).

## Open pull requests and issues (as observed 2026-10-10)

| Item | State |
| --- | --- |
| [PR #129](https://github.com/NeaBouli/1kUSD/pull/129) | Head `4a1617a` published; four checks green; review thread resolved; human review still missing. Not merged. |
| [PR #130](https://github.com/NeaBouli/1kUSD/pull/130) | Documentation correction `df0d798` published after a separate Claude source/document review plus two wording fixes. Forge and docs checks green at observation; CodeRabbit pending at that time. This was not a full technical re-audit. Not merged. |
| [Issue #131](https://github.com/NeaBouli/1kUSD/issues/131) | Created for `1K-P1-017` documentation revalidation. Evidence is still draft; independent review pending. No G3 or PoC approval. |
| [Issue #114](https://github.com/NeaBouli/1kUSD/issues/114) | Open (external assurance). |
| [Issue #118](https://github.com/NeaBouli/1kUSD/issues/118) | Open. |
| [Issue #119](https://github.com/NeaBouli/1kUSD/issues/119) | Open. Holds the unique private-operator gate; it is distinct from the Codex Security gate below. Details are intentionally not published. |

## Working model (owner decision, 2026-10-10)

- **Codex**: lean lead and integrator — scoping, review, integration gates.
- **Claude Code and Kimi**: full workers on disjoint tickets.
- **Grok**: optional independent fallback worker.
- Exactly one active product ticket at a time; no duplicate work on the same
  ticket. Partial results are preserved and handed back, not rebuilt.
- Transient failures retry after 5 minutes; quota exhaustion pauses the worker
  instead of switching scope.

## Modular work queue (order, not approval)

1. Status and PR reconciliation (#129, #130, #131).
2. [#104](https://github.com/NeaBouli/1kUSD/issues/104) — license decision
   `DEC-005` first, then freeze/dependency/SBOM work.
3. [#105](https://github.com/NeaBouli/1kUSD/issues/105) — quality gates.
4. [#131](https://github.com/NeaBouli/1kUSD/issues/131) / G3 — Kaspa evidence
   must be reviewed before any PoC.
5. [#106](https://github.com/NeaBouli/1kUSD/issues/106) oracle and
   [#107](https://github.com/NeaBouli/1kUSD/issues/107) governance — choices
   reserved for the owner.
6. [#108](https://github.com/NeaBouli/1kUSD/issues/108) — fee policy, after
   `DEC-004`.
7. [#109](https://github.com/NeaBouli/1kUSD/issues/109) — collateral.
8. [#110](https://github.com/NeaBouli/1kUSD/issues/110) /
   [#111](https://github.com/NeaBouli/1kUSD/issues/111) — operations, only
   behind the prior gates.
9. [#114](https://github.com/NeaBouli/1kUSD/issues/114) — external assurance.
10. [#115](https://github.com/NeaBouli/1kUSD/issues/115) — bounded hygiene.

## Protected gates

- **Codex Security gate**: requires an explicit destination, code scope,
  exclusions, and cost before running. Recorded as **NOT RUN**; for
  documentation-only changes it is **N/A**. It does not replace the operator,
  specialist, runtime, or UI gates.
- **Private-operator gate** (#119): separate and unique; not satisfied by any
  automated scan.
- **Publication gate**: a local planning stack is on **HOLD** for a public
  confidentiality review and is not published. Only already-published history
  is used as the base for public updates.
- No detailed findings and no unreproducible PASS claims are published.

## CI

CI currently runs on the public repository. No GitHub Actions quota blocker has
been demonstrated, and no fallback runner switch is active.
