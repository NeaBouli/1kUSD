# Audit Shipment Manifest

**Protocol:** 1kUSD -- Decentralized Stablecoin
**Tag:** `audit-final-v0.51.5`
**Commit:** `dad9409da555d5903540684e4521120f0d1f5d80`
**Freeze Date:** 2026-02-20
**Compiler:** solc 0.8.30 | Forge 1.5.0-stable
**EVM Target:** Paris | Optimizer: 200 runs

---

## Quick Start

```bash
git clone https://github.com/NeaBouli/1kUSD.git && cd 1kUSD
git checkout audit-final-v0.51.5

forge install
forge build       # expect 0 errors
forge test        # expect 198/198 passing (35 suites)
```

---

## Build Verification (2026-02-20)

| Check | Result |
|-------|--------|
| `forge clean && forge build` | 0 errors, 0 warnings (lint notes only) |
| `forge test` | **198/198 passed**, 0 failed, 0 skipped |
| Invariant/fuzz runs | 256 runs x 64 depth per property |
| Test suites | 35 total |

---

## In-Scope Source Files (SHA-256)

### Core Contracts (14 files)

```
fba3e32e8e7a031f0be4e1bb4074f69dc20b45e3e06ba14212b3b694641bb0e2  contracts/core/1kUSD.sol
8359741544fcf76535d4914496c1ef3404fd0165956878603b8f14fef916a0e6  contracts/core/BuybackVault.sol
2ec33c7dd74f541937f3c5bb6b94755aea5faeaeb764c2d699d9369511eeec1f  contracts/core/CollateralVault.sol
539f3f8d84990d2967f9321b537006a785daf5943e0a3f5c3999e11f5072ac8b  contracts/core/DAO_Timelock.sol
925009d83eb7e6ca881676805921b99c2a8ec23e3299ca81d8f7fb0688cb7095  contracts/core/FeeRouter.sol
6c584e72d1a6c58f7d6a89598883c834732e9dec79d63086ddfd6c07699ab958  contracts/core/GuardianMonitor.sol
83e7cea57bf83a9879806a4270c569f8b70aee7b62fd933344843c7c5fee339f  contracts/core/OneKUSD.sol
e72cee7b68bbaa98cb62108e642100016d0fa7b1438c58d243ec4a8f80e7320e  contracts/core/OracleAggregator.sol
b61916c188a7e322ffd96b23ac94ff83b58f51d68022b8b2a26da582e5a1071f  contracts/core/ParameterRegistry.sol
849da0586e496294651641d564c85536cc7221c4d3fda464575b9b95a2009fd1  contracts/core/PegStabilityEngine.sol
c39bc50a720445d6e616f9e53bf5746d3b4f8ded7e7e159110f017f3341a51a6  contracts/core/PegStabilityModule.sol
a4d009187e2676657e855acf504114dd3fdd502dab063a6c01ea1d1eed12203b  contracts/core/SafetyAutomata.sol
dce9f72eead1d358bb0ba50ff129e52fc1a1218e012830538e5856ab4ff913d2  contracts/core/SafetyNet.sol
5fe75085c0d30517c86d13282acbf15ec5330451bdd55ceab14a05ef635d6fad  contracts/core/TreasuryVault.sol
```

### Oracle & Security (3 files)

```
36c5411ed23c37adc70b9c74102444aa9f007ed1ccea8579f286a7ea1dcf3b6a  contracts/oracle/OracleAdapter.sol
f1103ee1f59ba22cabc7316fcbe37adc874a0f1835e5c306be238793f7673f53  contracts/oracle/OracleWatcher.sol
1397e675f9485db5d9d4ddcbfa3d935dda6348be8cf04cac84803a58b6f864c7  contracts/security/Guardian.sol
```

### PSM & Router (4 files)

```
43faa50252d05b0f19fbcece30fc7286f1dddfcbe2827e3d1b285842edd51c41  contracts/psm/PSM.sol
1408f3a635737bd667aaf23ff7286317baae28abcd92fcd80b906d986d39835e  contracts/psm/PSMLimits.sol
52499728223413b33ccd2515793037e866ebcbaa281c0e4f5f429f9b291de5e9  contracts/psm/PSMSwapCore.sol
d9231a1a230500060e70317e2919a73dcde3ce1d28942a0f7b11bf78303295a9  contracts/router/FeeRouterV2.sol
```

### Strategy (1 file)

```
8f48ec79d2141bb91fbc5d133c88f06d229c5b4ef0d7b08cf10453790a56847a  contracts/strategy/IBuybackStrategy.sol
```

### Interfaces (12 files)

```
ce81fbd85822b23728b2e109f086f740594b3a18e3b95c21552f65f41e91af39  contracts/interfaces/I1kUSD.sol
325cd2b49e7799e8e8b875b1697825326c5b311dc5755e6465b8646d3375323f  contracts/interfaces/ICollateralRegistry.sol
a42a90c3e9cabc4f9ed94bcccfc701b9e3041229da86b2383cfe5feba95850bf  contracts/interfaces/IERC2612.sol
39f0a0152106032de9a34c304c18fa675ecfc490194776ee6c5a82fccb395343  contracts/interfaces/IFeeRouter.sol
c61a4908ac691f107d119b9ea624cc82dcec02b74952eb48cd9ef5d971fd77b5  contracts/interfaces/IOneKUSD.sol
c493bde958fdba7cc82bf7e01dc6ee733418e9578ff7e1e406c49486a4d45e38  contracts/interfaces/IOracleAggregator.sol
ef991f1a77547631ea4333102b0b65ecf18d43e1fcdc9f0978f7fd38537522c2  contracts/interfaces/IOracleWatcher.sol
cb73cd7ea38fa513b9c952ee7b4ee768a395bf140a37be81823930a6895d4bf6  contracts/interfaces/IParameterRegistry.sol
6a2449daffe2949ecda7c3230b629c31cdec3ccf7546c26bfc5e8cfba56d799b  contracts/interfaces/IPSM.sol
1dd1fb487da7653672758819c0a544c92e303e1409e3f46d7f0119554cb384ca  contracts/interfaces/IPSMEvents.sol
d64051f69eae9248e95416be9273823fbe229c269b19821202e4013ddd8c5fa2  contracts/interfaces/ISafetyAutomata.sol
f63d02bad815797c6082e4ef620b231cccd71554f666d6a3bd7365fd1a95185b  contracts/interfaces/IVault.sol
```

**Total in-scope:** 34 Solidity files

---

## Audit Documentation Package (9 docs, 2,109 lines)

| Document | Lines | Content |
|----------|-------|---------|
| `AUDIT_SCOPE.md` | 215 | Scope definition, file manifest, build instructions |
| `ARCHITECTURE_OVERVIEW.md` | 310 | System diagram, critical call paths, stub contracts |
| `INVARIANTS.md` | 343 | 35 protocol invariants, coverage matrix, econ sim mapping |
| `ECONOMIC_MODEL.md` | 248 | Fee math, limits, buyback caps, worst-case scenarios |
| `ROLE_MATRIX.md` | 236 | Function-level access control for all contracts |
| `TRUST_MODEL.md` | 232 | Trusted/untrusted entities, per-contract assumptions |
| `TELEMETRY_MODEL.md` | 207 | Event catalog, error-to-alert mapping, monitoring |
| `KNOWN_LIMITATIONS.md` | 178 | 12 accepted limitations with mitigations |
| `THREAT_MODEL.md` | 140 | 10 attack classes with mitigations |

### External Documentation

| Document | Path |
|----------|------|
| Deployment checklist | `docs/reports/DEPLOYMENT_CHECKLIST_v051.md` |
| Gas/DoS review | `docs/reports/GAS_DOS_REVIEW_v051.md` |
| Error catalog | `docs/ERROR_CATALOG.md` |
| Safety pause matrix | `docs/SAFETY_PAUSE_MATRIX.md` |
| Audit plan | `docs/security/audit_plan.md` |

---

## Test Suite Breakdown (198 tests / 35 suites)

| Category | Tests | Suites |
|----------|-------|--------|
| Unit | 52 | 10 |
| Config & Auth | 79 | 7 |
| Regression | 19 | 6 |
| Integration | 7 | 4 |
| Smoke | 9 | 1 |
| Invariant/Fuzz | 18 | 4 |
| Economic Sim | 10 | 1 |
| Misc | 4 | 2 |

---

## Dependencies

| Dependency | Version | Commit |
|------------|---------|--------|
| forge-std | v1.11.0 | `8e40513d` |
| OpenZeppelin Contracts | v4.8.0 | `c64a1edb` |

---

## Build Configuration (`foundry.toml`)

```toml
[profile.default]
src = "contracts"
test = "foundry/test"
solc_version = "0.8.30"
optimizer = true
optimizer_runs = 200
evm_version = "paris"

[invariant]
runs = 256
depth = 64
```

---

## Verification

To verify file integrity after checkout:

```bash
git checkout audit-final-v0.51.5
# Verify commit hash
git rev-parse HEAD
# Expected: dad9409da555d5903540684e4521120f0d1f5d80

# Verify checksums (compare against this manifest)
find contracts/core contracts/oracle contracts/security contracts/psm \
     contracts/router contracts/strategy contracts/interfaces \
     -name "*.sol" -not -path "*/mocks/*" | sort | \
     xargs shasum -a 256
```
