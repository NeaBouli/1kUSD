[![CI](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/ci.yml?branch=main&label=CI)](https://github.com/NeaBouli/1kUSD/actions/workflows/ci.yml)
[![Foundry Tests](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/foundry-test.yml?branch=main&label=Foundry%20Tests)](https://github.com/NeaBouli/1kUSD/actions/workflows/foundry-test.yml)
[![Tests](https://img.shields.io/badge/tests-183%2F183%20passing-brightgreen)]()
![License](https://img.shields.io/github/license/NeaBouli/1kUSD)

# 1kUSD — Decentralized Stablecoin Protocol

1kUSD is a security-first, collateralized stablecoin pegged 1:1 to USD via on-chain reserves, a Peg-Stability Module (PSM), oracle aggregation, and safety automata. The current release (**v0.51.x**) covers the stable economic core: PSM, Oracle layer, Guardian/SafetyAutomata, and BuybackVault.

**Repository language:** English.
**Whitepaper:** German & English under [`docs/whitepaper/`](docs/whitepaper/).

## Quick Start

```bash
# Clone
git clone https://github.com/NeaBouli/1kUSD.git && cd 1kUSD

# Install dependencies
forge install

# Build
forge build

# Run tests (183/183 expected)
forge test

# Run with summary
forge test --summary
```

**Requirements:** [Foundry](https://book.getfoundry.sh/getting-started/installation) (Solidity 0.8.30, Paris EVM).

## Architecture

The protocol is composed of these core on-chain modules:

| Module | Contract | Purpose |
|--------|----------|---------|
| **Token** | `OneKUSD` | ERC-20 with restricted mint/burn (protocol-only) |
| **PSM** | `PegStabilityModule` | 1:1 swap collateral <-> 1kUSD with fees, spreads, limits |
| **Vault** | `CollateralVault` | Holds collateral (USDC/USDT/DAI); withdrawals via PSM only |
| **Oracle** | `OracleAggregator` | Multi-feed aggregation with staleness/deviation health gates |
| **Safety** | `SafetyAutomata` | Pause/resume per module, guardian sunset, DAO override |
| **Limits** | `PSMLimits` | Daily + per-tx volume caps on PSM swaps |
| **Buyback** | `BuybackVault` | DAO-controlled treasury buyback via PSM, rolling window caps |
| **Registry** | `ParameterRegistry` | DAO-governed on-chain parameter store |
| **Fees** | `FeeRouter` | Route mint/redeem fees to treasury |

For detailed architecture, see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Repository Layout

```
contracts/          Solidity source (core/, psm/, interfaces/)
foundry/test/       Foundry test suites (unit, regression, invariant, smoke)
docs/               Documentation (architecture, specs, governance, reports)
docs/reports/       Audit reports, deployment checklist, Gas/DoS review
lib/                Dependencies (forge-std, OpenZeppelin)
.github/workflows/  CI pipelines
```

## Test Suite

**183 tests across 33 suites — all passing.**

| Category | Tests | Suites | Description |
|----------|-------|--------|-------------|
| Unit & regression | 168 | 30 | Config, auth, flows, fees, spreads, limits, oracle, guardian |
| Invariant & fuzz | 13 | 3 | BuybackVault, PSMLimits, SafetyAutomata (256 runs x 64 depth) |
| Smoke & negative | 9 | 1 | Phase 7 post-deployment verification (real contracts) |

Invariant testing covers: window cap bounds, balance accounting, daily volume caps, pause/resume state machine, guardian sunset enforcement.

## Key Documentation

| Document | Path |
|----------|------|
| Documentation index | [`docs/README.md`](docs/README.md) |
| Architecture overview | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| Deployment checklist | [`docs/reports/DEPLOYMENT_CHECKLIST_v051.md`](docs/reports/DEPLOYMENT_CHECKLIST_v051.md) |
| Gas/DoS review | [`docs/reports/GAS_DOS_REVIEW_v051.md`](docs/reports/GAS_DOS_REVIEW_v051.md) |
| Security audit | [`docs/reports/SECURITY_AUDIT_v051_2026-02.md`](docs/reports/SECURITY_AUDIT_v051_2026-02.md) |
| Error catalog | [`docs/ERROR_CATALOG.md`](docs/ERROR_CATALOG.md) |
| Reports index | [`docs/reports/REPORTS_INDEX.md`](docs/reports/REPORTS_INDEX.md) |

## Security

The protocol ships with a dedicated security and risk layer:

- [Security audit (v0.51.x, Feb 2026)](docs/reports/SECURITY_AUDIT_v051_2026-02.md)
- [Gas/DoS review](docs/reports/GAS_DOS_REVIEW_v051.md) — 8 findings, all resolved
- [Deployment checklist](docs/reports/DEPLOYMENT_CHECKLIST_v051.md) — Phase 1-7 verification
- [Threat model](docs/THREAT_MODEL.md)
- [Safety pause matrix](docs/SAFETY_PAUSE_MATRIX.md)
- [Error catalog](docs/ERROR_CATALOG.md)

## Governance

Parameter governance is handled via `ParameterRegistry` + DAO Timelock:

- [Governance overview](docs/GOVERNANCE.md)
- [Parameter keys](docs/PARAMETER_KEYS.md)
- [Governance operations](docs/GOVERNANCE_OPS.md)
- [Guardian sunset runbook](docs/GUARDIAN_SUNSET_RUNBOOK.md)

## Contributing

The main architect assigns tasks. Each area is developed by a dedicated developer with a precise prompt. All deliverables follow the EOF-based file format. See [`docs/DEVELOPER_ONBOARDING.md`](docs/DEVELOPER_ONBOARDING.md) for setup and workflow.

## License

[AGPL-3.0](LICENSE)
