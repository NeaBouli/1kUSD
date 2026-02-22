<p align="center">
  <img src="docs/assets/1kUSD.png" alt="1kUSD Logo" width="200">
</p>

<h1 align="center">1kUSD — Decentralized Stablecoin Protocol</h1>

<p align="center">
  <strong>Security-first stablecoin pegged 1:1 to USD</strong><br>
  Built on Ethereum today. Designed for native KASPA when the layer supports it.
</p>

<p align="center">

[![Foundry CI](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/foundry.yml?branch=main&label=Foundry%20CI)](https://github.com/NeaBouli/1kUSD/actions/workflows/foundry.yml)
[![Solidity CI](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/ci.yml?branch=main&label=Solidity%20CI)](https://github.com/NeaBouli/1kUSD/actions/workflows/ci.yml)
[![Tests](https://img.shields.io/badge/tests-198%2F198%20passing-brightgreen)]()
[![Solidity](https://img.shields.io/badge/solidity-0.8.30-blue)]()
![License](https://img.shields.io/github/license/NeaBouli/1kUSD)

</p>

<p align="center">
  <a href="https://x.com/Kaspa_USD">Follow @Kaspa_USD on X</a> |
  <a href="https://neabouli.github.io/1kUSD/">Documentation</a> |
  <a href="audit/AUDIT_SCOPE.md">Audit Package</a>
</p>

---

## Vision

1kUSD is a collateralized stablecoin protocol with on-chain reserves, a Peg Stability Module (PSM), oracle aggregation, and safety automata.

**Today:** ERC-20 on Ethereum (v0.51.x) — audit-ready, fully tested, Sepolia deployment pipeline complete.

**Tomorrow:** Native stablecoin on the KASPA network. When KASPA's smart contract layer (or equivalent) enables programmable token issuance, 1kUSD will migrate to a native KASPA implementation — bringing the same security guarantees to KASPA's high-throughput, GHOSTDAG-powered BlockDAG.

The protocol architecture is chain-agnostic by design: the PSM, oracle, and safety layers are modular abstractions that can be re-implemented on any EVM-compatible or KASPA-native runtime.

## Quick Start

```bash
git clone https://github.com/NeaBouli/1kUSD.git && cd 1kUSD
forge install
forge build
forge test          # 198/198 expected
```

**Requirements:** [Foundry](https://book.getfoundry.sh/getting-started/installation) (Solidity 0.8.30, Paris EVM).

## Architecture

| Module | Contract | Purpose |
|--------|----------|---------|
| **Token** | `OneKUSD` | ERC-20 with restricted mint/burn, EIP-2612 permit |
| **PSM** | `PegStabilityModule` | Swap collateral <-> 1kUSD with fees, spreads, oracle pricing |
| **Vault** | `CollateralVault` | Hold collateral assets; PSM-authorized withdrawals only |
| **Oracle** | `OracleAggregator` | Multi-feed aggregation with staleness/deviation health gates |
| **Safety** | `SafetyAutomata` | Per-module pause/resume, guardian sunset, DAO override |
| **Limits** | `PSMLimits` | Daily + per-tx volume caps on PSM swaps |
| **Buyback** | `BuybackVault` | DAO treasury buyback via PSM, per-op + rolling window caps |
| **Registry** | `ParameterRegistry` | DAO-governed on-chain parameter store |
| **Fees** | `FeeRouter` | Route mint/redeem fees to treasury |

See [`audit/ARCHITECTURE_OVERVIEW.md`](audit/ARCHITECTURE_OVERVIEW.md) for detailed system diagrams and critical call paths.

## Repository Layout

```
contracts/           Solidity source (core/, psm/, oracle/, interfaces/)
foundry/test/        Foundry test suites (unit, regression, invariant, econ sim)
foundry/script/      Deployment & monitoring scripts
audit/               Audit documentation package (11 docs)
docs/                Architecture, specs, governance, reports
lib/                 Dependencies (forge-std, OpenZeppelin)
.github/workflows/   CI pipelines
```

## Test Suite

**198 tests across 35 suites — all passing.**

| Category | Tests | Suites | Description |
|----------|-------|--------|-------------|
| Unit | 52 | 10 | BuybackVault, PSMLimits, PSM deadline, DAO Timelock, PSMSwapCore |
| Config & Auth | 79 | 7 | PSM, OneKUSD, CollateralVault, SafetyAutomata, Registry, FeeRouter, Limits |
| Regression | 19 | 6 | PSM flows, limits, fees, spreads, oracle health, oracle watcher |
| Integration | 7 | 4 | Guardian pause propagation, PSM enforcement, unpause |
| Smoke | 9 | 1 | Phase 7 post-deployment verification |
| Invariant/Fuzz | 18 | 4 | Supply conservation, collateral backing, vault solvency, fee bounds (256 runs x 64 depth) |
| Economic Sim | 10 | 1 | Fee accrual, depeg stress, bank run, worst cases, cap exhaustion |
| Misc | 4 | 2 | Guardian monitor, safety net |

## Audit Package

The protocol ships with a comprehensive audit documentation package in [`audit/`](audit/):

| Document | Content |
|----------|---------|
| [`AUDIT_SCOPE.md`](audit/AUDIT_SCOPE.md) | Scope, file manifest, build instructions |
| [`SHIPMENT_MANIFEST.md`](audit/SHIPMENT_MANIFEST.md) | SHA-256 checksums, build verification |
| [`ARCHITECTURE_OVERVIEW.md`](audit/ARCHITECTURE_OVERVIEW.md) | System diagram, critical call paths |
| [`INVARIANTS.md`](audit/INVARIANTS.md) | 35 protocol invariants, coverage matrix |
| [`ECONOMIC_RISK_SCENARIOS.md`](audit/ECONOMIC_RISK_SCENARIOS.md) | 5 risk scenarios (depeg, feed pause, key compromise, bank run, fees) |
| [`THREAT_MODEL.md`](audit/THREAT_MODEL.md) | 10 attack classes with mitigations |
| [`TRUST_MODEL.md`](audit/TRUST_MODEL.md) | Trusted/untrusted entities |
| [`ECONOMIC_MODEL.md`](audit/ECONOMIC_MODEL.md) | Fee math, limits, buyback caps |
| [`ROLE_MATRIX.md`](audit/ROLE_MATRIX.md) | Function-level access control |
| [`TELEMETRY_MODEL.md`](audit/TELEMETRY_MODEL.md) | Event catalog, monitoring |
| [`KNOWN_LIMITATIONS.md`](audit/KNOWN_LIMITATIONS.md) | 12 accepted limitations |

**Freeze tag:** `audit-final-v0.51.5` | **Tests:** 198/198 | **Compiler:** solc 0.8.30

## Security

- [Audit scope & freeze](audit/AUDIT_SCOPE.md) — 34 in-scope Solidity files
- [Economic risk scenarios](audit/ECONOMIC_RISK_SCENARIOS.md) — depeg, oracle failure, key compromise, bank run, fee sustainability
- [Gas/DoS review](docs/reports/GAS_DOS_REVIEW_v051.md) — 8 findings, all resolved
- [Deployment checklist](docs/reports/DEPLOYMENT_CHECKLIST_v051.md) — Phase 1-7 verification
- [Error catalog](docs/ERROR_CATALOG.md) — complete error code mapping

## Governance

Parameter governance via `ParameterRegistry` + DAO Timelock:

- [Governance overview](docs/GOVERNANCE.md)
- [Parameter keys catalog](docs/PARAM_KEYS_CATALOG.md)
- [Guardian sunset runbook](docs/GUARDIAN_SUNSET_RUNBOOK.md)

## KASPA Roadmap

| Phase | Status | Description |
|-------|--------|-------------|
| **v0.51.x** | Current | ERC-20 on Ethereum — audit-ready, 198 tests, Sepolia deployment |
| **v0.52.x** | Planned | Functional DAO Timelock, Chainlink oracle, FeeRouter v2, multisig |
| **v0.6x** | Research | KASPA smart contract layer evaluation, bridge architecture |
| **v1.0** | Vision | Native 1kUSD on KASPA BlockDAG with full PSM + oracle stack |

Follow development: [@Kaspa_USD](https://x.com/Kaspa_USD)

## Contributing

See [`docs/DEVELOPER_ONBOARDING.md`](docs/DEVELOPER_ONBOARDING.md) for setup and workflow.

## License

[AGPL-3.0](LICENSE)
