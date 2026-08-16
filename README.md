<p align="center">
  <img src="docs/assets/1kUSD.png" alt="1kUSD logo" width="180">
</p>

<h1 align="center">1kUSD Stablecoin Protocol</h1>

<p align="center">
  <strong>Collateralized stablecoin research and testnet implementation.</strong><br>
  EVM reference today; accepted Kaspa Toccata Testnet-10 PoC architecture.
</p>

<p align="center">

[![Foundry CI](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/foundry.yml?branch=main&label=Foundry%20CI)](https://github.com/NeaBouli/1kUSD/actions/workflows/foundry.yml)
[![Docs](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/docs.yml?branch=main&label=Docs)](https://github.com/NeaBouli/1kUSD/actions/workflows/docs.yml)
[![Solidity](https://img.shields.io/badge/solidity-0.8.30-blue)]()

</p>

> **Status — active remediation.** This repository is not a production
> stablecoin, has no mainnet deployment, and has not completed an independent
> external audit. The current EVM code contains test-only and stub components.
> Do not deploy it with real funds.

**Approved product direction:** Kaspa Toccata is the primary target. The EVM
implementation remains an executable reference and test model with no current
production commitment. See
[`ADR-041`](docs-internal/adr/ADR-041-kaspa-primary-product-track.md).

## Current verified baseline

| Area | Verified state / evidence date |
|---|---|
| Foundry tests | 229 passed, 0 failed, 0 skipped across 35 suites (#124, 2026-08-16) |
| Test quality | 8 counted tests are placeholders (#124, 2026-08-16) |
| Coverage | 78.92% lines / 57.63% branches (default report, 2026-08-05) |
| Oracle | Admin-set mock prices; not a production feed system |
| Governance | DAO timelock is a non-functional stub |
| Fee routing | Incomplete; two incompatible router paths coexist |
| Deployment | Testnet/demo wiring with MockERC20; no production role handoff |
| External audit | Not completed |
| Kaspa | ADR-042 accepted; any Testnet-10 PoC remains separately gated |

The historical `audit-final-v0.51.5` tag is preserved as evidence, but its
metadata and dependency labels contain known inconsistencies. It is not a
production certification.

## Product objective

1kUSD is intended to become a fully collateralized stablecoin with:

- one-to-one redeemable collateral accounting;
- two-way mint/redeem through a Peg Stability Module (PSM);
- no CDP debt or liquidation engine;
- bounded issuance and redemption limits;
- fail-closed price, asset, and configuration checks;
- time-limited emergency pause authority;
- timelocked multisig governance;
- transparent fee, reserve, and treasury accounting;
- independent monitoring, audit, and release evidence.

The implementation program and release gates are defined in the
[master plan](docs-internal/planning/MASTER_PLAN_2026.md). Work is tracked in the
[Agent Bridge](docs/agent-bridge/README.md) and GitHub Issues.

## EVM architecture

| Module | Current contract | Current status |
|---|---|---|
| Token | `OneKUSD` | Implemented; further production hardening required |
| PSM | `PegStabilityModule` | Implemented prototype; config/economic hardening required |
| Vault | `CollateralVault` | Implemented prototype; accounting hardening required |
| Oracle | `OracleAggregator` | Mock/admin-set, not multi-feed production infrastructure |
| Safety | `SafetyAutomata` | Sunset role precedence hardened; production role handoff remains gated |
| Guardian | `Guardian` | Direct registration/revocation and DAO resume lifecycle implemented; deployment E2E remains gated |
| Limits | `PSMLimits` | Implemented; events/fail-closed configuration required |
| Governance | `DAO_Timelock` | Stub; execution is not implemented |
| Fees | `FeeRouter` / `FeeRouterV2` | Incomplete and not unified |
| Buyback | `BuybackVault` | Prototype with documented limitations |

Detailed source evidence is in the [audit follow-up](docs-internal/reports/AUDIT_REVIEW_2026-08-05.md).

## Kaspa Toccata direction

Kaspa's Toccata programmability stack is live and is **UTXO/covenant-native**,
not EVM account-native. 1kUSD will not translate Solidity contracts line by line.

The EVM contracts remain an executable economic reference. A separate Kaspa
design must define covenant state, successor validation, native-asset policy,
PSM state sharding, oracle reports, governance spend paths, indexing, and
transaction-v1 budgets. Silverscript and vProgs are still evolving, so the first
step is a pinned, value-capped testnet proof of concept—not a launch.

See [Kaspa Toccata Agent Brief](https://docs.kaspa.org/toccata/agent-brief) and the
[Kaspa track in the master plan](docs-internal/planning/MASTER_PLAN_2026.md).

## Build and test

Requirements: Foundry with Solidity `0.8.30` support.

```bash
git clone --recurse-submodules https://github.com/NeaBouli/1kUSD.git
cd 1kUSD
forge build
forge test -vv
forge test --match-contract Invariant -vv
```

Do not treat a green count alone as a release gate. Production-scope branch
coverage, placeholder removal, static analysis, and deployment E2E remain open.

## Repository map

```text
contracts/             Solidity source; includes explicit legacy/stub modules
foundry/test/          Foundry unit, regression, invariant, and economic tests
foundry/script/        Current testnet/demo deployment scripts
audit/                 Historical v0.51.x audit package
docs/                  Public GitHub Pages content
docs-internal/         Architecture, reports, planning, and runbooks
docs/agent-bridge/     Canonical multi-agent state and ticket index
archive/               Preserved non-active backups, outputs, and workflow drafts
```

## Security and contributing

- Report vulnerabilities privately through
  [GitHub Security Advisories](https://github.com/NeaBouli/1kUSD/security/advisories/new).
- Read [SECURITY.md](SECURITY.md) before testing or reporting a vulnerability.
- Read [CONTRIBUTING.md](CONTRIBUTING.md) before proposing changes.
- Contract/governance/economic changes require a threat-model delta and focused
  plus full-suite verification.

## Documentation

- [Public site](https://neabouli.github.io/1kUSD/)
- [Master plan](docs-internal/planning/MASTER_PLAN_2026.md)
- [Ticket list](docs/agent-bridge/TICKET_LIST.md)
- [Architecture overview](audit/ARCHITECTURE_OVERVIEW.md)
- [Known limitations](audit/KNOWN_LIMITATIONS.md)
- [Audit follow-up](docs-internal/reports/AUDIT_REVIEW_2026-08-05.md)

## License status

License metadata is under reconciliation. The root `LICENSE` currently contains
GPL-3.0 text, while package metadata and per-file SPDX identifiers are not fully
consistent. Review the root license and each file's SPDX identifier; do not rely
on the previous AGPL-only README claim until the license decision is completed.
