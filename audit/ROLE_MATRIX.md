# Role Matrix -- v0.51.x

---

## Role Hierarchy

```
ADMIN (highest authority)
  |
  +-- Can change all protocol configuration
  +-- Can grant/revoke all subordinate roles
  +-- Single address per contract (no multi-admin)
  |
  +-- DAO
  |     +-- BuybackVault (immutable dao)
  |     +-- PSMLimits (dao)
  |     +-- OracleAdapter (dao)
  |     +-- Guardian (immutable dao)
  |     +-- SafetyAutomata (DAO_ROLE, if granted by admin)
  |     +-- TreasuryVault (DAO_ROLE, granted at construction)
  |
  +-- GUARDIAN (time-limited)
  |     +-- SafetyAutomata (GUARDIAN_ROLE)
  |     +-- Can pause only (not resume)
  |     +-- Expires at guardianSunset timestamp
  |
  +-- AUTHORIZED CALLERS (whitelist per contract)
  |     +-- CollateralVault: deposit/withdraw
  |     +-- PSMLimits: checkAndUpdate
  |     +-- FeeRouter: routeToTreasury
  |
  +-- MINTER / BURNER (OneKUSD-specific)
  |     +-- OneKUSD.mint (isMinter)
  |     +-- OneKUSD.burn (isBurner)
  |
  +-- PUBLIC (no restriction)
        +-- PSM swap functions (gated by pause/oracle/limits, not by role)
        +-- All view functions
        +-- OneKUSD transfers
        +-- OracleWatcher read/update
```

---

## Function-Level Access Control

### PegStabilityModule (`contracts/core/PegStabilityModule.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `swapTo1kUSD(tokenIn, amountIn, to, minOut, deadline)` | Public | `whenNotPaused`, `nonReentrant` |
| `swapFrom1kUSD(tokenOut, amountIn1k, to, minOut, deadline)` | Public | `whenNotPaused`, `nonReentrant` |
| `quoteTo1kUSD(tokenIn, amountIn, feeBps, tokenInDecimals)` | Public | view |
| `quoteFrom1kUSD(tokenOut, amountIn1k, feeBps, tokenOutDecimals)` | Public | view |
| `setLimits(address)` | ADMIN_ROLE | `onlyRole(ADMIN_ROLE)` |
| `setOracle(address)` | ADMIN_ROLE | `onlyRole(ADMIN_ROLE)` |
| `setFeeRouter(address)` | ADMIN_ROLE | `onlyRole(ADMIN_ROLE)` |
| `setFees(uint256, uint256)` | ADMIN_ROLE | `onlyRole(ADMIN_ROLE)` |

### OneKUSD (`contracts/core/OneKUSD.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `transfer(to, amount)` | Public | -- |
| `transferFrom(from, to, amount)` | Public | allowance check |
| `approve(spender, amount)` | Public | -- |
| `permit(owner, spender, value, deadline, v, r, s)` | Public | EIP-2612 signature verification |
| `mint(to, amount)` | isMinter | `notPaused`, `isMinter[msg.sender]` |
| `burn(from, amount)` | isBurner | `notPaused`, `isBurner[msg.sender]` |
| `setMinter(account, bool)` | Admin | `onlyAdmin` |
| `setBurner(account, bool)` | Admin | `onlyAdmin` |
| `setAdmin(address)` | Admin | `onlyAdmin` |
| `pause()` | Admin | `onlyAdmin` |
| `unpause()` | Admin | `onlyAdmin` |

### CollateralVault (`contracts/core/CollateralVault.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `deposit(asset, from, amount)` | Authorized Caller | `notPaused`, `onlySupported`, `onlyAuthorized` |
| `withdraw(asset, to, amount, reason)` | Authorized Caller | `notPaused`, `onlySupported`, `onlyAuthorized` |
| `balanceOf(asset)` | Public | view |
| `isAssetSupported(asset)` | Public | view |
| `areAssetsSupported(assets[])` | Public | view |
| `setAdmin(address)` | Admin | `onlyAdmin` |
| `setRegistry(IParameterRegistry)` | Admin | `onlyAdmin` |
| `setAssetSupported(asset, bool)` | Admin | `onlyAdmin` |
| `setAuthorizedCaller(caller, bool)` | Admin | `onlyAdmin` |

### SafetyAutomata (`contracts/core/SafetyAutomata.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `isPaused(moduleId)` | Public | view |
| `isModuleEnabled(moduleId)` | Public | view |
| `pauseModule(moduleId)` | GUARDIAN / ADMIN / DAO | Guardian: `block.timestamp < guardianSunset`; else: `ADMIN_ROLE \|\| DAO_ROLE` |
| `resumeModule(moduleId)` | ADMIN / DAO | `ADMIN_ROLE \|\| DAO_ROLE` |
| `grantGuardian(address)` | ADMIN_ROLE | `onlyRole(ADMIN_ROLE)` |

### OracleAggregator (`contracts/core/OracleAggregator.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `getPrice(asset)` | Public | view |
| `isOperational()` | Public | view |
| `setPriceMock(asset, price, decimals, healthy)` | Admin | `onlyAdmin`, `notPaused` |
| `setAdmin(address)` | Admin | `onlyAdmin` |
| `setRegistry(IParameterRegistry)` | Admin | `onlyAdmin` |

### BuybackVault (`contracts/core/BuybackVault.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `fundStable(amount)` | DAO | `onlyDAO`, `notPaused` |
| `withdrawStable(to, amount)` | DAO | `onlyDAO`, `notPaused` |
| `withdrawAsset(to, amount)` | DAO | `onlyDAO`, `notPaused` |
| `executeBuybackPSM(amount1k, recipient, minOut, deadline)` | DAO | `onlyDAO`, `notPaused` |
| `setMaxBuybackSharePerOpBps(uint16)` | DAO | `onlyDAO` |
| `setBuybackWindowConfig(uint64, uint16)` | DAO | `onlyDAO` |
| `setOracleHealthGateConfig(address, bool)` | DAO | `onlyDAO` |
| `setStrategiesEnforced(bool)` | DAO | `onlyDAO` |
| `setStrategy(id, asset, weightBps, enabled)` | DAO | `onlyDAO` |
| `strategyCount()` | Public | view |
| `getStrategy(id)` | Public | view |
| `stableBalance()` | Public | view |
| `assetBalance()` | Public | view |

### PSMLimits (`contracts/psm/PSMLimits.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `checkAndUpdate(amount)` | Authorized Caller | `onlyAuthorized` |
| `_updateVolume(amount)` | Authorized Caller | delegates to `checkAndUpdate` |
| `setLimits(daily, single)` | DAO | `onlyDAO` |
| `setAuthorizedCaller(caller, bool)` | DAO | `onlyDAO` |
| `lastDay()` | Public | view |
| `dailyVolumeView()` | Public | view |

### ParameterRegistry (`contracts/core/ParameterRegistry.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `getUint(key)` | Public | view |
| `getAddress(key)` | Public | view |
| `getBool(key)` | Public | view |
| `setUint(key, value)` | Admin | `onlyAdmin` |
| `setAddress(key, value)` | Admin | `onlyAdmin` |
| `setBool(key, value)` | Admin | `onlyAdmin` |
| `setAdmin(address)` | Admin | `onlyAdmin` |

### FeeRouter (`contracts/core/FeeRouter.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `routeToTreasury(token, treasury, amount, tag)` | Authorized Caller | `onlyAuthorized` |
| `setAdmin(address)` | Admin | `onlyAdmin` |
| `setAuthorizedCaller(caller, bool)` | Admin | `onlyAdmin` |

### TreasuryVault (`contracts/core/TreasuryVault.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `sweep(token, to, amount)` | DAO_ROLE | `onlyRole(DAO_ROLE)` |

### Guardian (`contracts/security/Guardian.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `setSafetyAutomata(ISafetyAutomata)` | DAO | `onlyDAO` |
| `setOperator(address)` | DAO | `onlyDAO` |
| `selfRegister()` | DAO | `onlyDAO` |
| `pauseOracle()` | Operator | `onlyOperator`, requires `block.timestamp < guardianSunset` |
| `resumeOracle()` | DAO | `onlyDAO` |

### OracleWatcher (`contracts/oracle/OracleWatcher.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `updateHealth()` | Public | -- |
| `refreshState()` | Public | -- |
| `isHealthy()` | Public | view |
| `getStatus()` | Public | view |

### OracleAdapter (`contracts/oracle/OracleAdapter.sol`)

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `setPrice(uint256)` | DAO | `onlyDAO` |
| `setHeartbeat(uint256)` | DAO | `onlyDAO` |
| `latestPrice()` | Public | view (reverts if stale) |
| `isStale()` | Public | view |

### FeeRouterV2 (`contracts/router/FeeRouterV2.sol`) -- STUB

| Function | Access | Modifier/Check |
|----------|--------|----------------|
| `route(key, token, amount)` | **Public (no access control)** | -- |

**Note:** Stub has no access control. No tokens are moved (event-only). Not a security issue unless stub is deployed with real token balances.

---

## Role Assignment Cross-Reference

| Role | Who grants it | Who can hold it |
|------|---------------|-----------------|
| ADMIN_ROLE (SafetyAutomata) | DEFAULT_ADMIN_ROLE holder | Any address |
| DAO_ROLE (SafetyAutomata) | DEFAULT_ADMIN_ROLE holder | Any address |
| GUARDIAN_ROLE (SafetyAutomata) | ADMIN_ROLE via `grantGuardian()` | Any address |
| admin (CollateralVault) | Current admin via `setAdmin()` | Any address |
| admin (OracleAggregator) | Current admin via `setAdmin()` | Any address |
| admin (ParameterRegistry) | Current admin via `setAdmin()` | Any address |
| admin (FeeRouter) | Current admin via `setAdmin()` | Any address |
| admin (OneKUSD) | Current admin via `setAdmin()` | Any address |
| isMinter (OneKUSD) | admin via `setMinter()` | Any address |
| isBurner (OneKUSD) | admin via `setBurner()` | Any address |
| authorizedCallers (CollateralVault) | admin via `setAuthorizedCaller()` | Any address |
| authorizedCallers (PSMLimits) | dao via `setAuthorizedCaller()` | Any address |
| authorizedCallers (FeeRouter) | admin via `setAuthorizedCaller()` | Any address |
| dao (BuybackVault) | Constructor only | **Immutable** |
| dao (Guardian) | Constructor only | **Immutable** |
| dao (PSMLimits) | Constructor only | Not changeable |
| operator (Guardian) | dao via `setOperator()` | Any address |

---

## Emergency Actions

| Action | Who can do it | Constraint |
|--------|---------------|------------|
| Pause any module | GUARDIAN_ROLE, ADMIN_ROLE, DAO_ROLE | Guardian: only before sunset |
| Resume any module | ADMIN_ROLE, DAO_ROLE | No time constraint |
| Pause oracle (via Guardian) | Operator | Before sunset; requires `safety` to be set |
| Resume oracle (via Guardian) | DAO | Requires `safety` to be set |
| Pause OneKUSD mint/burn | Admin | Direct `pause()` call |
| Unpause OneKUSD mint/burn | Admin | Direct `unpause()` call |
