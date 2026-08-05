# Roadmap

The roadmap is release-gated, not date-driven. No phase starts automatically.

| Phase | Goal | Current state |
|---|---|---|
| 0 — Project truth | Honest status, Bridge, issues, Pages, README, archive | In progress |
| 1 — Safety correctness | Fix sunset and Guardian role lifecycle | Proposed |
| 2 — Governance | Functional timelock, multisig, role handoff | Proposed |
| 3 — Economic core | Fail-closed collateral, decimals, limits, fees, solvency | Proposed |
| 4 — Production oracle | Approved real feeds, quorum/fallback and monitoring | Proposed |
| 5 — Deployment | Reproducible testnet release and post-deploy verification | Blocked by 1–4 |
| 6 — Assurance | Coverage, static analysis, fuzz/invariant/economic gates | Ongoing / incomplete |
| 7 — External review | New freeze, audit, remediation, bug bounty | Blocked by 1–6 |
| 8 — Kaspa validation | Toccata ADR and isolated testnet-10 covenant PoC | Proposed research |

## Mainnet gate

Mainnet is not scheduled. It requires all release blockers closed, no open
High/Medium audit findings, production oracle/governance/fee/monitoring systems,
reproducible deployment, legal and reserve decisions, independent audit, and bug
bounty evidence.

## Kaspa gate

Kaspa work starts with an architecture decision record and small value-capped
testnet proof of concept. Silverscript and vProgs are evolving; no production
timeline is claimed.

See the full [master plan on GitHub](https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/planning/MASTER_PLAN_2026.md)
and the [ticket list](https://github.com/NeaBouli/1kUSD/blob/main/docs/agent-bridge/TICKET_LIST.md).
