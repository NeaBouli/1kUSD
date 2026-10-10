<p align="center">
  <img src="docs/assets/1kUSD.png" alt="1kUSD logo" width="180">
</p>

<h1 align="center">1kUSD Stablecoin Protocol</h1>

<p align="center">
  <strong>Open research program for a fully collateralized, USD-targeting stablecoin.</strong><br>
  Kaspa is the primary target. The Solidity code is an executable EVM reference.
</p>

<p align="center">

[![Foundry CI](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/foundry.yml?branch=main&label=Foundry%20CI)](https://github.com/NeaBouli/1kUSD/actions/workflows/foundry.yml)
[![Docs](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/docs.yml?branch=main&label=Docs)](https://github.com/NeaBouli/1kUSD/actions/workflows/docs.yml)
[![Solidity](https://img.shields.io/badge/solidity-0.8.30-blue)]()

</p>

> **Research system — not a live stablecoin.** There is no mainnet deployment,
> no live reserve, no completed external audit and no guaranteed peg. The EVM
> code contains test-only and stub components. Do not use it with real funds.

**Start here:** [public site](https://neabouli.github.io/1kUSD/) ·
[security & limits](https://neabouli.github.io/1kUSD/security/) ·
[roadmap](https://neabouli.github.io/1kUSD/roadmap/) ·
[issues](https://github.com/NeaBouli/1kUSD/issues)

## Status as of 2026-10-10

Each line gives a state and its evidence. A decision is not code, merged code
is not deployed, and nothing here is deployed or live.

| Area | State · evidence |
|---|---|
| Product boundary | Accepted: Kaspa primary, EVM reference · [`ADR-041`](docs-internal/adr/ADR-041-kaspa-primary-product-track.md), 2026-08-05 |
| Kaspa execution architecture | Accepted: singleton control/reserve covenant family for the first PoC · [`ADR-042`](docs-internal/adr/ADR-042-kaspa-toccata-execution-architecture.md), 2026-08-16 |
| ADR-042 revalidation | In review against SilverScript v1 and node v2.1.0; gate G3 open · [#131](https://github.com/NeaBouli/1kUSD/issues/131), 2026-10-10 |
| Testnet-10 PoC | Not approved; needs G3 plus a separate execution ticket |
| Governance architecture | Accepted as design only; no implementation authorized · [`ADR-043`](docs-internal/adr/ADR-043-autonomous-community-control.md), 2026-08-16 |
| Foundry tests (historical) | 229 passed, 0 failed, 0 skipped across 35 suites; 8 are placeholders · #124, 2026-08-16 |
| Coverage (historical) | 78.92% lines / 57.63% branches · 2026-08-05 |
| Oracle / governance / fees | Admin-set mock prices / timelock stub / incomplete routing |
| Deployment / external audit | Testnet/demo wiring only / not completed |

The historical `audit-final-v0.51.5` tag is kept as evidence. Its metadata and
dependency labels are known to be inconsistent, and it is not a production
certification.

## Intended mechanism

1kUSD is designed to be a fully collateralized stablecoin. Approved collateral
is deposited to mint 1kUSD, and returned 1kUSD is burned to release collateral,
both through a Peg Stability Module (PSM). The design has no CDP debt and no
liquidation engine. It also relies on:

- bounded limits and fail-closed price, asset and configuration checks;
- time-limited emergency pause;
- timelocked multisig governance;
- transparent fee, reserve and treasury accounting.

This is the target design. The [security & limits](https://neabouli.github.io/1kUSD/security/)
page lists what the reference implements today.

## Kaspa target and EVM reference

Kaspa uses UTXOs and covenants, not EVM accounts. 1kUSD will not translate
Solidity contracts line by line. The accepted first proof of concept is a
value-capped Testnet-10 experiment with one singleton control/reserve covenant
family and synthetic collateral. Its execution is **not approved**.

Candidate SilverScript compiler and node versions are recorded as
**non-adopted**. Their compatibility and runtime behaviour are **not verified**.
A KCC20-shaped interface, vProgs and Zelcore tooling are not adopted. This
README makes no claim about Kaspa network activation or Testnet-10 liveness.

The EVM contracts remain an executable model of the economics, with no
production or EVM-mainnet commitment.

| Module | Contract | State |
|---|---|---|
| Token | `OneKUSD` | Implemented; hardening required |
| PSM | `PegStabilityModule` | Prototype; config/economic hardening required |
| Vault | `CollateralVault` | Prototype; accounting hardening required |
| Oracle | `OracleAggregator` | Mock/admin-set |
| Safety / Guardian | `SafetyAutomata`, `Guardian` | Lifecycle fixes merged (#120, #124); deployment handoff gated |
| Limits | `PSMLimits` | Implemented; fail-closed configuration required |
| Governance | `DAO_Timelock` | Stub; execution not implemented |
| Fees | `FeeRouter` / `FeeRouterV2` | Incomplete and not unified |
| Buyback | `BuybackVault` | Prototype with documented limitations |

## Build and test

Requirements: Foundry with Solidity `0.8.30` support.

```bash
git clone --recurse-submodules https://github.com/NeaBouli/1kUSD.git
cd 1kUSD
forge build
forge test -vv
```

A green count alone is not a release gate. Branch coverage, placeholder
removal, static analysis and deployment end-to-end checks are still open.

## Repository map

```text
contracts/             Solidity source, including explicit legacy/stub modules
foundry/test/          Foundry unit, regression, invariant and economic tests
foundry/script/        Testnet/demo deployment scripts
docs/                  Public GitHub Pages content
docs-internal/         ADRs, architecture, reports, planning and runbooks
docs/agent-bridge/     Multi-agent state and ticket index
audit/                 Historical v0.51.x audit package
archive/               Preserved non-active backups and drafts
```

## Security and contributing

- Report vulnerabilities privately through
  [GitHub Security Advisories](https://github.com/NeaBouli/1kUSD/security/advisories/new).
  Read [SECURITY.md](SECURITY.md) first.
- Read [CONTRIBUTING.md](CONTRIBUTING.md) before proposing changes. Contract,
  governance and economic changes need an approved ticket, a threat-model
  delta, tests and independent review.
- Further references: [master plan](docs-internal/planning/MASTER_PLAN_2026.md),
  [ticket list](docs/agent-bridge/TICKET_LIST.md),
  [known limitations](audit/KNOWN_LIMITATIONS.md),
  [audit follow-up](docs-internal/reports/AUDIT_REVIEW_2026-08-05.md).

## License status

License metadata is under reconciliation. The root `LICENSE` contains GPL-3.0
text, while package metadata and per-file SPDX identifiers are not fully
consistent. Check the root license and each file's SPDX identifier before reuse.
No license decision has been made yet.
