# Deployment Checklist — v0.51.x

**Source:** Security Audit v0.51.x (February 2026)
**Baseline:** commit `db95a31` (post-PR #86, Sprint 1 Task 1)
**Tests:** 181/181 passing across 33 suites

---

## Phase 1: Core Infrastructure Deploy

Deploy in this exact order. Each contract's constructor parameters reference only previously-deployed contracts.

| Step | Contract | Constructor Parameters |
|------|----------|----------------------|
| 1 | `SafetyAutomata` | `admin`, `guardianSunsetTimestamp` |
| 2 | `ParameterRegistry` | `admin` |
| 3 | `OracleAggregator` | `admin`, `safetyAutomata`, `parameterRegistry` |
| 4 | `CollateralVault` | `admin`, `safetyAutomata`, `parameterRegistry` |
| 5 | `OneKUSD` | `admin` |
| 6 | `PSMLimits` | `dao`, `dailyCap`, `singleTxCap` |
| 7 | `FeeRouter` | `admin` |
| 8 | `PegStabilityModule` | `admin`, `oneKUSD`, `collateralVault`, `safetyAutomata`, `parameterRegistry` |

### Phase 1 Validation

```
SafetyAutomata.hasRole(ADMIN_ROLE, admin) == true
ParameterRegistry.admin() == admin
OracleAggregator.admin() == admin
CollateralVault.admin() == admin
OneKUSD.admin() == admin
PSMLimits.dao() == dao
FeeRouter.admin() == admin
PegStabilityModule.hasRole(ADMIN_ROLE, admin) == true
```

---

## Phase 2: Authorized Caller Whitelist

These calls MUST execute before any swap can succeed. Missing any one will cause reverts on first use.

### 2.1 OneKUSD — Mint/Burn Roles

| Call | Why | Reverts Without |
|------|-----|-----------------|
| `oneKUSD.setMinter(psm, true)` | PSM must mint 1kUSD in `swapTo1kUSD` | `ACCESS_DENIED()` on mint |
| `oneKUSD.setBurner(psm, true)` | PSM must burn 1kUSD in `swapFrom1kUSD` | `ACCESS_DENIED()` on burn |

### 2.2 CollateralVault — Caller + Asset Authorization

| Call | Why | Reverts Without |
|------|-----|-----------------|
| `vault.setAuthorizedCaller(psm, true)` | PSM must call `deposit`/`withdraw` | `NOT_AUTHORIZED()` |
| `vault.setAssetSupported(token, true)` | Per collateral token (e.g., USDC) | `ASSET_NOT_SUPPORTED()` |

Repeat `setAssetSupported` for **each** collateral token the PSM will accept.

### 2.3 PSMLimits — Caller Authorization (if deployed)

| Call | Why | Reverts Without |
|------|-----|-----------------|
| `limits.setAuthorizedCaller(psm, true)` | PSM must call `checkAndUpdate` | `NOT_AUTHORIZED()` |

Note: `setAuthorizedCaller` on PSMLimits is `onlyDAO` — must be called by the DAO address.

### 2.4 FeeRouter — Caller Authorization (if IFeeRouterV2 deployed)

| Call | Why | Reverts Without |
|------|-----|-----------------|
| `feeRouterV2.setAuthorizedCaller(psm, true)` | PSM fee routing via `IFeeRouterV2.route()` | `NotAuthorized()` |

**v0.52+ Note:** The PSM uses `IFeeRouterV2.route(moduleId, token, amount)` interface, not the v1 `IFeeRouter.routeToTreasury(token, treasury, amount, tag)`. The current `FeeRouter.sol` implements v1 only. A compatible `IFeeRouterV2` implementation is required before fee routing can be enabled. Until then, `psm.feeRouter()` remains `address(0)` (safe no-op).

### Phase 2 Validation

```
oneKUSD.isMinter(psm) == true
oneKUSD.isBurner(psm) == true
vault.authorizedCallers(psm) == true
vault.isAssetSupported(token) == true        // per token
limits.authorizedCallers(psm) == true        // if limits deployed
```

---

## Phase 3: Oracle Configuration

### 3.1 Wire Oracle to PSM

| Call | Why | Reverts Without |
|------|-----|-----------------|
| `psm.setOracle(oracleAggregator)` | PSM prices swaps via oracle | `PSM_ORACLE_MISSING()` |

### 3.2 Set Initial Price Data

| Call | Why | Reverts Without |
|------|-----|-----------------|
| `oracleAggregator.setPriceMock(token, price, decimals, true)` | Initial price for each collateral asset | `getPrice` returns unhealthy / zero price |

Example for USDC at $1.00:
```
oracleAggregator.setPriceMock(usdc, 1e8, 8, true)
```

### 3.3 Health Thresholds (via ParameterRegistry)

| Call | Key | Purpose | Default if unset |
|------|-----|---------|-----------------|
| `registry.setUint(keccak256("oracle:maxStale"), seconds)` | `oracle:maxStale` | Max age of price before marked stale | 0 (no staleness check) |
| `registry.setUint(keccak256("oracle:maxDiffBps"), bps)` | `oracle:maxDiffBps` | Max price change per update before marked unhealthy | 0 (no deviation check) |

### Phase 3 Validation

```
psm.oracle() != address(0)
oracle.isOperational() == true
oracle.getPrice(token) returns (price > 0, decimals, healthy == true)
```

---

## Phase 4: PSM Configuration

### 4.1 Fees

| Call | Constraint | Reverts Without |
|------|-----------|-----------------|
| `psm.setFees(mintFeeBps, redeemFeeBps)` | Both must be ≤ 10,000 (100%) | No revert — defaults to 0 bps (no fees) |

### 4.2 Limits (optional)

| Call | Why |
|------|-----|
| `psm.setLimits(psmLimitsAddress)` | Enforces daily + per-tx caps |

If not set, `address(limits) == address(0)` and `_enforceLimits` is a no-op — unlimited swaps.

### 4.3 Fee Router (optional — requires IFeeRouterV2 implementation)

| Call | Why |
|------|-----|
| `psm.setFeeRouter(feeRouterV2Address)` | Routes mint fees to treasury via `IFeeRouterV2` |

If not set, `address(feeRouter) == address(0)` and fee routing is a no-op — fees are computed but not routed. **Requires a contract implementing `IFeeRouterV2.route()` (v0.52+ item).**

### 4.4 Token Decimals (via ParameterRegistry)

| Call | Key | Default |
|------|-----|---------|
| `registry.setUint(keccak256(abi.encode(keccak256("psm:tokenDecimals"), token)), decimals)` | Per-token decimal override | 18 if unset |

Set this for every non-18-decimal token (e.g., USDC = 6).

### 4.5 Spreads (via ParameterRegistry, optional)

| Call | Key | Default |
|------|-----|---------|
| `registry.setUint(keccak256("psm:mintSpreadBps"), bps)` | Global mint spread | 0 |
| `registry.setUint(keccak256("psm:redeemSpreadBps"), bps)` | Global redeem spread | 0 |

### Phase 4 Validation

```
psm.mintFeeBps() == expectedMintFee
psm.redeemFeeBps() == expectedRedeemFee
psm.limits() == expectedLimitsAddress    // or address(0) if none
psm.feeRouter() == expectedFeeRouter     // or address(0) if none
```

---

## Phase 5: Safety-Automata Setup

### 5.1 Role Assignment

| Call | Why |
|------|-----|
| `safetyAutomata.grantRole(DAO_ROLE, daoAddress)` | DAO can pause/resume any module |
| `safetyAutomata.grantGuardian(guardianAddress)` | Guardian can pause (not resume) before sunset |

### 5.2 Guardian Contract Wiring (if deployed)

| Step | Call | Why |
|------|------|-----|
| 1 | `guardian.setSafetyAutomata(safetyAutomata)` | Links guardian to pause system |
| 2 | `guardian.selfRegister()` | Calls `safetyAutomata.grantGuardian(address(this))` |
| 3 | `guardian.setOperator(operatorAddress)` | Delegates `pauseOracle()` to operator (optional) |

### Phase 5 Validation

```
safetyAutomata.hasRole(DAO_ROLE, dao) == true
safetyAutomata.hasRole(GUARDIAN_ROLE, guardian) == true   // if guardian deployed
safetyAutomata.isPaused(keccak256("PSM")) == false
safetyAutomata.isPaused(keccak256("VAULT")) == false
safetyAutomata.isPaused(keccak256("ORACLE")) == false
```

---

## Phase 6: Optional Modules

### 6.1 BuybackVault

**Constructor:** `stable`, `asset`, `dao`, `safetyAutomata`, `psm`, `moduleId`

| Step | Call | Notes |
|------|------|-------|
| 1 | `buybackVault.setMaxBuybackSharePerOpBps(bps)` | 0 = disabled |
| 2 | `buybackVault.setBuybackWindowConfig(durationSec, capBps)` | 0/0 = disabled |
| 3 | `buybackVault.setOracleHealthGateConfig(oracleWatcher, true)` | Requires OracleWatcher |
| 4 | `buybackVault.setStrategy(id, asset, weightBps, true)` | Per buyback asset |
| 5 | `buybackVault.setStrategiesEnforced(true)` | After all strategies set |
| 6 | `buybackVault.fundStable(amount)` | Requires prior ERC20 `approve` |

### 6.2 OracleWatcher

**Constructor:** `oracleAggregator`, `safetyAutomata`

| Step | Call | Notes |
|------|------|-------|
| 1 | `oracleWatcher.refreshState()` | Initialize health cache |

No access control needed — read-only monitoring.

### 6.3 OracleAdapter

**Constructor:** `dao`

| Step | Call | Notes |
|------|------|-------|
| 1 | `adapter.setHeartbeat(seconds)` | Default 3600 (1h) |
| 2 | `adapter.setPrice(price)` | Must be called before `latestPrice()` works |

### 6.4 TreasuryVault

**Constructor:** `admin`

| Step | Call | Notes |
|------|------|-------|
| 1 | `treasuryVault.grantRole(DAO_ROLE, dao)` | DAO can sweep funds |

---

## Phase 7: Post-Deployment Verification

### 7.1 State Checks

Run every check. Any failure = system is misconfigured.

```
 1. psm.oracle() != address(0)                              → oracle wired
 2. oracle.isOperational() == true                           → oracle not paused
 3. oneKUSD.isMinter(psm) == true                            → PSM can mint
 4. oneKUSD.isBurner(psm) == true                            → PSM can burn
 5. vault.isAssetSupported(token) == true                     → collateral accepted
 6. vault.authorizedCallers(psm) == true                      → PSM can deposit/withdraw
 7. limits.authorizedCallers(psm) == true                     → PSM can update limits (if limits deployed)
 8. safetyAutomata.isPaused(keccak256("PSM")) == false        → PSM not paused
 9. safetyAutomata.isPaused(keccak256("VAULT")) == false      → vault not paused
10. safetyAutomata.isPaused(keccak256("ORACLE")) == false     → oracle not paused
```

### 7.2 Smoke Test — Full Roundtrip

```solidity
// 1. Approve collateral token for PSM
token.approve(address(psm), smallAmount);

// 2. Swap collateral → 1kUSD
uint256 supplyBefore = oneKUSD.totalSupply();
psm.swapTo1kUSD(token, smallAmount, recipient, 0, block.timestamp + 300);
assert(oneKUSD.totalSupply() > supplyBefore);

// 3. Approve 1kUSD for PSM
oneKUSD.approve(address(psm), oneKUSD.balanceOf(recipient));

// 4. Swap 1kUSD → collateral
psm.swapFrom1kUSD(token, oneKUSD.balanceOf(recipient), recipient, 0, block.timestamp + 300);

// 5. Verify roundtrip (supply returns to original, accounting for fees)
assert(oneKUSD.totalSupply() == supplyBefore);  // only if fees == 0
```

### 7.3 Negative Tests

| Test | Expected Result |
|------|-----------------|
| Call `psm.swapTo1kUSD` with unsupported token | Reverts `ASSET_NOT_SUPPORTED()` at vault layer |
| Call `psm.swapTo1kUSD` with expired deadline | Reverts `PSM_DEADLINE_EXPIRED()` |
| Call `psm.swapTo1kUSD` when oracle paused | Reverts `"PSM: oracle not operational"` |
| Call `vault.deposit` directly (not from PSM) | Reverts `NOT_AUTHORIZED()` |
| Call `limits.checkAndUpdate` directly | Reverts (unauthorized) |
| Call `feeRouter.routeToTreasury` directly | Reverts `NotAuthorized()` |
| Call `psm.setFees(10_001, 0)` | Reverts `"PSM: mintFee too high"` |

### 7.4 Run Full Test Suite

```bash
cd foundry && forge test --summary
```

Expected: **181/181 tests passing** across 33 suites.

---

## Quick Reference: "Forgot Config" Failure Modes

| Forgotten Step | Symptom | Error |
|----------------|---------|-------|
| `psm.setOracle()` | All swaps revert | `PSM_ORACLE_MISSING()` |
| `oneKUSD.setMinter(psm)` | `swapTo1kUSD` reverts | `ACCESS_DENIED()` |
| `oneKUSD.setBurner(psm)` | `swapFrom1kUSD` reverts | `ACCESS_DENIED()` |
| `vault.setAuthorizedCaller(psm)` | All swaps revert at vault | `NOT_AUTHORIZED()` |
| `vault.setAssetSupported(token)` | Swaps for that token revert | `ASSET_NOT_SUPPORTED()` |
| `limits.setAuthorizedCaller(psm)` | All swaps revert at limits | `NOT_AUTHORIZED()` |
| `oracleAggregator.setPriceMock()` | Oracle returns unhealthy | `"PSM: oracle not operational"` |
| Token decimals not set for 6-decimal token | Wrong mint/redeem amounts | Silent — 1e12 scaling error |

---

*Checklist updated: 2026-02-15. Sprint 2 Task 2: Gas/DoS review complete (see GAS_DOS_REVIEW_v051.md). BuybackVault balanceOf caching applied. G1 (unbounded strategies loop) and G2 (CEI pattern) escalated for core-dev decision.*
