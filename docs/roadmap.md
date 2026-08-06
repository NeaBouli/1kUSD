# Readiness-gated roadmap

The roadmap is release-gated, not date-driven. No phase starts automatically.

| Phase | Goal | Current state |
|---|---|---|
| 0 — Project truth | Honest status, Bridge, issues, Pages, README, archive | In progress |
| 1 — Product boundary | Kaspa-primary scope; EVM reference role | Approved in `ADR-041` |
| 2 — Kaspa architecture | Covenant, based-app, and hybrid ADR | Proposed; awaiting #112 approval |
| 3 — Isolated Kaspa PoC | Value-capped testnet vault/issuance experiment | Blocked by phase 2 |
| 4 — Protocol hardening | Safety, governance, collateral, fees, and oracle | Proposed |
| 5 — Deployment | Reproducible Kaspa testnet candidate and monitoring | Blocked by 2–4 |
| 6 — Assurance | Coverage, static analysis, fuzz/invariant/economic gates | Ongoing / incomplete |
| 7 — External review | New freeze, audit, remediation, bug bounty | Blocked by 1–6 |
| 8 — Production readiness | Legal, reserve, redemption, and incident gates | Blocked |

## Mainnet gate

Mainnet is not scheduled. It requires all release blockers closed, no open
High/Medium audit findings, production oracle/governance/fee/monitoring systems,
reproducible deployment, legal and reserve decisions, independent audit, and bug
bounty evidence.

## Kaspa gate

Kaspa is the approved primary product track. Work starts with an architecture
decision record and only then a separately approved, value-capped testnet proof
of concept. Silverscript and vProgs are evolving; no production timeline is
claimed.

See the full [master plan on GitHub](https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/planning/MASTER_PLAN_2026.md)
and the [ticket list](https://github.com/NeaBouli/1kUSD/blob/main/docs/agent-bridge/TICKET_LIST.md).
