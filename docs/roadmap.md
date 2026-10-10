# Readiness-gated roadmap

Status as of **2026-10-10**. The roadmap is gated on evidence, not on dates. No
phase starts automatically. A phase starts only after the earlier gates pass
and the owner approves it explicitly. The [GitHub issues](https://github.com/NeaBouli/1kUSD/issues)
are the execution record. This page summarizes them.

Four states are kept apart: **implemented** (code exists on a branch),
**merged** (on `main`), **deployed** (on a network) and **live** (in real use).
Nothing listed here is deployed or live.

| Phase | Goal | State · evidence date |
|---|---|---|
| 0 — Project truth | Honest status, Pages, README, archive | Done · #113 |
| 1 — Product boundary | Kaspa as primary target, EVM as reference | Accepted · `ADR-041`, 2026-08-05 (#101) |
| 2 — Kaspa architecture | Covenant execution architecture | Accepted · `ADR-042`, 2026-08-16 (#112). Revalidation against SilverScript v1 and node v2.1.0 prepared 2026-10-10 and **in review**; gate G3 open (#131) |
| 3 — Isolated Kaspa PoC | Value-capped Testnet-10 singleton experiment with synthetic collateral | **Not approved.** Needs G3, a separate execution ticket and owner approval. A smaller offline compile proof is only a queued proposal |
| 4 — Protocol hardening | Safety, governance, collateral, fees, oracle | Partly started. Safety fixes merged in #120 (2026-08-13) and #124 (2026-08-16). Governance architecture `ADR-043` accepted as design only (2026-08-16). Oracle, fee and collateral choices wait on owner decisions (#106–#109) |
| 5 — Deployment and operations | Reproducible testnet candidate, post-deploy checks, reserve and solvency monitoring | Blocked by 2–4 (#110, #111); release prerequisites remain open |
| 6 — Assurance | Coverage, static analysis, fuzz/invariant/economic-simulation gates, placeholder replacement and reproducible freeze | Ongoing / incomplete (#104, #105); license decision remains open |
| 7 — External review | New freeze, external audit, remediation, bug bounty | Blocked by 1–6 (#114) |
| 8 — Production readiness | Legal, reserve, redemption and incident gates | Blocked |

## Mainnet gate

No mainnet date exists. Mainnet requires all of the following:

- every release blocker closed and no open High/Medium audit finding;
- production oracle, governance, fee and monitoring systems;
- a reproducible deployment;
- legal and reserve decisions;
- an independent audit and bug-bounty evidence.

## Kaspa gate

Kaspa is the approved primary track, and `ADR-042` is the accepted design for
the first proof of concept. Before any network execution:

- the revalidation must pass independent review and gate G3;
- the owner must pin the toolchain. The candidate compiler and node versions
  are currently **non-adopted**, and their compatibility and runtime behaviour
  are **not verified**;
- a separate execution ticket must be approved.

A KCC20-shaped interface, vProgs and Zelcore tooling are not adopted. This
roadmap makes no claim about Kaspa network activation, Testnet-10 liveness or a
production timeline.

See the [master plan on GitHub](https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/planning/MASTER_PLAN_2026.md)
and the [ticket list](https://github.com/NeaBouli/1kUSD/blob/main/docs/agent-bridge/TICKET_LIST.md).
