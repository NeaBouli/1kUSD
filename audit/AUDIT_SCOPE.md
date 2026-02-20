# Audit Scope -- v0.51.x Freeze

---

## Freeze Reference

| Field | Value |
|-------|-------|
| **Protocol** | 1kUSD -- Decentralized Stablecoin |
| **Version** | v0.51.5 |
| **Tag** | `audit-final-v0.51.5` |
| **Commit** | `dad9409da555d5903540684e4521120f0d1f5d80` |
| **Freeze Date** | 2026-02-20 |
| **Repository** | https://github.com/NeaBouli/1kUSD |
| **Compiler** | solc 0.8.30 |
| **EVM Target** | Paris |
| **Optimizer** | Enabled, 200 runs |

---

## Build & Test Instructions

```bash
# Clone at freeze tag
git clone https://github.com/NeaBouli/1kUSD.git && cd 1kUSD
git checkout audit-final-v0.51.5

# Install dependencies (forge-std v1.11.0, OpenZeppelin v4.8.0)
forge install

# Build (expect 0 errors, 0 warnings on production contracts)
forge build

# Run full test suite (expect 198/198 passing across 35 suites)
forge test

# Run invariant/fuzz tests only (256 runs x 64 depth)
forge test --match-contract Invariant

# Run economic simulation tests only
forge test --match-contract EconSim

# Run with verbosity for failure traces
forge test -vvv
```

---

## Dependencies

| Dependency | Version | Commit | Source |
|------------|---------|--------|--------|
| forge-std | v1.11.0 | `8e40513d` | foundry-rs/forge-std |
| OpenZeppelin Contracts | v4.8.0-952 | `c64a1edb` | OpenZeppelin/openzeppelin-contracts |

Remappings (`foundry.toml`):
```
forge-std/=lib/forge-std/src/
@openzeppelin/=lib/openzeppelin-contracts/
```

---

## Source File Manifest

### In-Scope: Core Contracts (18 files, 1,896 SLoC)

These are the production contracts that comprise the v0.51.x protocol.

| File | SLoC | Description | Status |
|------|------|-------------|--------|
| `contracts/core/PegStabilityModule.sol` | 531 | Canonical PSM: mint/redeem with fees, spreads, limits, oracle | FINAL |
| `contracts/core/BuybackVault.sol` | 341 | DAO treasury buyback via PSM, per-op + window caps | FINAL |
| `contracts/core/OneKUSD.sol` | 249 | ERC-20 stablecoin, restricted mint/burn, pause, permit | FINAL |
| `contracts/core/CollateralVault.sol` | 167 | Holds collateral assets, PSM-only withdrawals | FINAL |
| `contracts/core/OracleAggregator.sol` | 157 | Multi-feed aggregation, staleness/deviation health gates | FINAL |
| `contracts/core/PegStabilityEngine.sol` | 78 | Alternative PSM facade (simpler interface) | WIP |
| `contracts/core/DAO_Timelock.sol` | 77 | Timelock skeleton (execute = NOT_IMPLEMENTED) | STUB |
| `contracts/core/ParameterRegistry.sol` | 75 | DAO-governed on-chain parameter store | FINAL |
| `contracts/core/FeeRouter.sol` | 70 | Route fees to treasury with authorized callers | FINAL |
| `contracts/core/SafetyAutomata.sol` | 59 | Per-module pause/resume, guardian sunset | FINAL |
| `contracts/core/TreasuryVault.sol` | 34 | Passive fee sink, admin sweep | FINAL |
| `contracts/oracle/OracleWatcher.sol` | 72 | Oracle health monitor with cached state | FINAL |
| `contracts/oracle/OracleAdapter.sol` | 45 | DAO-controlled mock price feed | FINAL |
| `contracts/security/Guardian.sol` | 64 | Time-limited oracle pause, delegated operator | FINAL |
| `contracts/psm/PSMLimits.sol` | 60 | Daily + per-tx volume caps | FINAL |
| `contracts/psm/PSMSwapCore.sol` | 52 | Legacy swap implementation (do NOT deploy) | LEGACY |
| `contracts/router/FeeRouterV2.sol` | 13 | Stub: emits events only, no token movement | STUB |
| `contracts/strategy/IBuybackStrategy.sol` | 26 | Buyback strategy interface | FINAL |

### In-Scope: Interfaces (12 files, 301 SLoC)

| File | SLoC |
|------|------|
| `contracts/interfaces/IPSM.sol` | 86 |
| `contracts/interfaces/IOneKUSD.sol` | 50 |
| `contracts/interfaces/IFeeRouter.sol` | 20 |
| `contracts/interfaces/IPSMEvents.sol` | 20 |
| `contracts/interfaces/ICollateralRegistry.sol` | 19 |
| `contracts/interfaces/IVault.sol` | 19 |
| `contracts/interfaces/I1kUSD.sol` | 17 |
| `contracts/interfaces/IERC2612.sol` | 17 |
| `contracts/interfaces/IOracleWatcher.sol` | 15 |
| `contracts/interfaces/IParameterRegistry.sol` | 15 |
| `contracts/interfaces/IOracleAggregator.sol` | 13 |
| `contracts/interfaces/ISafetyAutomata.sol` | 10 |

### Out-of-Scope: Stubs, Mocks, Legacy

| File | SLoC | Reason |
|------|------|--------|
| `contracts/core/1kUSD.sol` | 11 | Stub -- forwards to OneKUSD |
| `contracts/core/GuardianMonitor.sol` | 10 | Stub -- placeholder |
| `contracts/core/SafetyNet.sol` | 10 | Stub -- placeholder |
| `contracts/psm/PSM.sol` | 30 | Legacy PSM stub |
| `contracts/core/mocks/MockRegistry.sol` | 27 | Test mock |
| `contracts/mocks/MockOneKUSD.sol` | 6 | Test mock |
| `contracts/mocks/MockRegistry.sol` | 6 | Test mock |
| `contracts/mocks/MockVault.sol` | 6 | Test mock |
| `contracts/router/IFeeRouterV2.sol` | 11 | Interface for stub router |
| `contracts/vault/TreasuryVault.sol` | 30 | Duplicate of core/TreasuryVault |

---

## Test Suite Summary

**198 tests across 35 suites -- all passing.**

### By Category

| Category | Tests | Suites | Description |
|----------|-------|--------|-------------|
| Unit | 52 | 10 | BuybackVault (36), PSMLimits (4), PSM_Deadline (4), DAO_Timelock (4), PSMSwapCore (3), TreasuryVault (1) |
| Config & Auth | 79 | 7 | PSM_Config (14), OneKUSD_Config (14), CollateralVault_Auth (19), SafetyAutomata_Config (9), ParameterRegistry_Config (8), FeeRouter_Auth (8), PSMLimits_Auth (7) |
| Regression | 19 | 6 | PSMRegression_Flows (3), PSMRegression_Limits (3), PSMRegression_Fees (3), PSMRegression_Spreads (2), OracleRegression_Health (4), OracleRegression_Watcher (3), PSMRegression_Base (1) |
| Integration | 7 | 4 | Guardian_OraclePropagation (3), Guardian_PSMUnpause (1), Guardian_Integration (1), Guardian_Advanced (1), Guardian_PSMEnforcement (1), Guardian_PSMPropagation (1) |
| Smoke | 9 | 1 | PSM_SmokeTest (9) -- Phase 7 post-deployment verification |
| Invariant/Fuzz | 18 | 4 | BuybackVault_Invariant (5), PSMLimits_Invariant (4), SafetyAutomata_Invariant (4), PSM_Invariant (5: F14-F18 supply conservation, collateral backing, vault solvency, fee bounds, supply non-negative) |
| Economic Sim | 10 | 1 | PSM_EconSim (10: fee accrual, depeg stress, bank run, worst cases WC#1/2/5, spread+fee interaction, daily cap exhaustion, surplus proof) |
| Misc | 4 | 2 | FeeRouter (1), TestGuardianMonitor (1), TestSafetyNet (1) |

### Invariant Configuration

```toml
[invariant]
runs = 256
depth = 64
```

---

## Critical Audit Paths

These are the highest-priority code paths for review:

1. **PSM mint (`swapTo1kUSD`)** -- user deposits collateral, receives 1kUSD minus fees
2. **PSM redeem (`swapFrom1kUSD`)** -- user burns 1kUSD, receives collateral minus fees
3. **BuybackVault (`executeBuybackPSM`)** -- DAO swaps vault 1kUSD for collateral
4. **SafetyAutomata (`pauseModule` / `resumeModule`)** -- emergency pause propagation
5. **OneKUSD (`mint` / `burn`)** -- restricted token supply changes
6. **CollateralVault (`deposit` / `withdraw`)** -- asset custody

---

## Audit Documentation Package

All supporting documentation is in the `/audit/` directory:

| Document | Content |
|----------|---------|
| **This file** (`AUDIT_SCOPE.md`) | Scope definition, file manifest, build instructions |
| [`ARCHITECTURE_OVERVIEW.md`](ARCHITECTURE_OVERVIEW.md) | System diagram, call graphs, module map |
| [`THREAT_MODEL.md`](THREAT_MODEL.md) | 10 attack classes with mitigations |
| [`TRUST_MODEL.md`](TRUST_MODEL.md) | Trusted/untrusted entities, per-contract assumptions |
| [`ECONOMIC_MODEL.md`](ECONOMIC_MODEL.md) | Fee math, limits, buyback caps, worst cases |
| [`ROLE_MATRIX.md`](ROLE_MATRIX.md) | Function-level access control for all contracts |
| [`TELEMETRY_MODEL.md`](TELEMETRY_MODEL.md) | Event catalog, error-to-alert mapping |
| [`KNOWN_LIMITATIONS.md`](KNOWN_LIMITATIONS.md) | 12 accepted limitations with mitigations |
| [`INVARIANTS.md`](INVARIANTS.md) | Consolidated protocol invariants |

### External Documentation

| Document | Path |
|----------|------|
| Deployment checklist | `docs/reports/DEPLOYMENT_CHECKLIST_v051.md` |
| Gas/DoS review | `docs/reports/GAS_DOS_REVIEW_v051.md` |
| Error catalog | `docs/ERROR_CATALOG.md` |
| Safety pause matrix | `docs/SAFETY_PAUSE_MATRIX.md` |
| Module IDs | `docs/MODULE_IDS.md` |

---

## Compiler & Pragma Notes

The codebase uses mixed pragma versions. All files compile under solc 0.8.30 (configured in `foundry.toml`).

| Pragma | Files | Notes |
|--------|-------|-------|
| `^0.8.24` | 23 | Production contracts (PSM, Vault, Oracle, BuybackVault, Guardian, Watcher) |
| `^0.8.30` | 13 | Interfaces and newer implementations |
| `^0.8.20` | 3 | DAO_Timelock, legacy PSM |
| `^0.8.19` | 1 | SafetyNet stub |

---

## Scope Exclusions

The following are explicitly out of scope for v0.51.x audit:

- **Deployment scripts** (`foundry/script/`) -- present but not deployed to mainnet; Sepolia-only
- **Monitoring scripts** (`foundry/script/Monitor.s.sol`) -- read-only health checks, not deployed
- **Frontend / DApp** (`dapp/`) -- documentation only
- **Indexer** (`indexer/`) -- documentation only
- **Test mocks** (`foundry/test/mocks/`, `contracts/mocks/`) -- not deployed
- **Future modules** -- DEX integration, AutoConverter, multi-collateral registry
