# Telemetry Model -- v0.51.x

---

## Event Catalog

### SafetyAutomata (2 events)

```solidity
event Paused(bytes32 indexed moduleId, address indexed by);
event Resumed(bytes32 indexed moduleId, address indexed by);
```

### PegStabilityModule (3 events)

```solidity
event FeesUpdated(uint256 mintFeeBps, uint256 redeemFeeBps);
// From IPSMEvents:
event SwapTo1kUSD(address indexed user, address tokenIn, uint256 notional1k, uint256 fee1k, uint256 net1k, uint256 ts);
event SwapFrom1kUSD(address indexed user, address tokenOut, uint256 notional1k, uint256 fee1k, uint256 netTokenOut, uint256 ts);
event PSMSwapExecuted(address indexed user, address indexed token, uint256 amount, uint256 ts);
```

### OneKUSD (7 events)

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
event MinterSet(address indexed account, bool enabled);
event BurnerSet(address indexed account, bool enabled);
event Paused(address indexed by);
event Unpaused(address indexed by);
```

### CollateralVault (6 events)

```solidity
event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
event AssetSupportSet(address indexed asset, bool supported);
event Deposit(address indexed asset, address indexed from, uint256 amount);
event Withdraw(address indexed asset, address indexed to, uint256 amount, bytes32 reason);
event AuthorizedCallerSet(address indexed caller, bool enabled);
```

### OracleAggregator (3 events)

```solidity
event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
event OracleUpdated(address indexed asset, int256 price, uint8 decimals, bool healthy);
```

### BuybackVault (9 events)

```solidity
event StableFunded(address indexed from, uint256 amount);
event StableWithdrawn(address indexed to, uint256 amount);
event AssetWithdrawn(address indexed to, uint256 amount);
event BuybackExecuted(address indexed recipient, uint256 stableIn, uint256 assetOut);
event StrategyEnforcementUpdated(bool enforced);
event StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled);
event BuybackTreasuryCapUpdated(uint16 oldCapBps, uint16 newCapBps);
event BuybackOracleHealthGateUpdated(address indexed oldModule, address indexed newModule, bool oldEnforced, bool newEnforced);
event BuybackWindowConfigUpdated(uint64 oldDuration, uint64 newDuration, uint16 oldCapBps, uint16 newCapBps);
```

### ParameterRegistry (4 events)

```solidity
event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
event UintSet(bytes32 indexed key, uint256 value);
event AddressSet(bytes32 indexed key, address value);
event BoolSet(bytes32 indexed key, bool value);
```

### FeeRouter (3 events)

```solidity
event AuthorizedCallerSet(address indexed caller, bool enabled);
event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
// From IFeeRouter:
event FeeRouted(address indexed token, address indexed from, address indexed to, uint256 amount, bytes32 tag);
```

### FeeRouterV2 -- stub (1 event)

```solidity
event FeeRouted(bytes32 indexed key, address token, uint256 amount);
```

### TreasuryVault (1 event)

```solidity
event Swept(address indexed token, address indexed to, uint256 amount);
```

### Guardian (2 events)

```solidity
event SafetyAutomataSet(address indexed safety);
event OperatorUpdated(address indexed oldOperator, address indexed newOperator);
```

### OracleWatcher (1 event)

```solidity
event HealthUpdated(Status status, uint256 timestamp);
// Status enum: { Healthy, Paused, Stale }
```

### OracleAdapter (2 events)

```solidity
event PricePushed(uint256 price, uint256 timestamp);
event HeartbeatChanged(uint256 newHeartbeat);
```

---

## Error -> Revert -> Metric -> Alert Mapping

| Error | Contract | Revert Condition | Suggested Metric | Alert Level |
|-------|----------|-----------------|------------------|-------------|
| `PausedError()` | PSM | Module paused | `psm_paused_revert_total` | CRITICAL -- swaps halted |
| `PSM_ORACLE_MISSING()` | PSM | `oracle == address(0)` | `psm_oracle_missing_total` | CRITICAL -- misconfiguration |
| `PSM_DEADLINE_EXPIRED()` | PSM | `block.timestamp > deadline` | `psm_deadline_expired_total` | INFO -- user-side |
| `InsufficientOut()` | PSM | `netOut < minOut` | `psm_slippage_revert_total` | INFO -- user-side |
| `PAUSED()` | CollateralVault | VAULT module paused | `vault_paused_revert_total` | CRITICAL |
| `NOT_AUTHORIZED()` | CollateralVault | Caller not whitelisted | `vault_auth_revert_total` | WARNING -- possible attack |
| `ASSET_NOT_SUPPORTED()` | CollateralVault | Asset not enabled | `vault_unsupported_asset_total` | WARNING |
| `INSUFFICIENT_VAULT_BALANCE()` | CollateralVault | Withdraw > balance | `vault_insufficient_balance_total` | CRITICAL -- accounting issue |
| `ACCESS_DENIED()` | OneKUSD | Not minter/burner/admin | `token_access_denied_total` | WARNING -- possible attack |
| `PAUSED()` | OneKUSD | Token paused | `token_paused_revert_total` | CRITICAL |
| `NOT_DAO()` | BuybackVault | Caller != dao | `buyback_auth_revert_total` | WARNING -- possible attack |
| `PAUSED()` | BuybackVault | Module paused | `buyback_paused_revert_total` | CRITICAL |
| `BUYBACK_TREASURY_CAP_EXCEEDED()` | BuybackVault | Per-op cap hit | `buyback_per_op_cap_total` | WARNING |
| `BUYBACK_TREASURY_WINDOW_CAP_EXCEEDED()` | BuybackVault | Window cap hit | `buyback_window_cap_total` | WARNING |
| `BUYBACK_ORACLE_UNHEALTHY()` | BuybackVault | Oracle health gate | `buyback_oracle_unhealthy_total` | WARNING |
| `MAX_STRATEGIES_REACHED()` | BuybackVault | 16 strategies full | `buyback_max_strategies_total` | INFO |
| `GuardianExpired()` | SafetyAutomata | Guardian past sunset | `guardian_expired_total` | INFO -- expected after sunset |
| `NOT_AUTHORIZED()` | PSMLimits | Caller not whitelisted | `limits_auth_revert_total` | WARNING |
| `"swap too large"` | PSMLimits | Daily or single-tx cap | `limits_cap_exceeded_total` | WARNING -- rate limit hit |
| `NotAuthorized()` | FeeRouter | Caller not whitelisted | `feerouter_auth_revert_total` | WARNING |
| `PAUSED()` | OracleAggregator | ORACLE module paused | `oracle_paused_revert_total` | CRITICAL |

---

## Critical Monitoring Points

### 1. Emergency Pause Detection

**Events:** `SafetyAutomata.Paused(moduleId, by)`, `SafetyAutomata.Resumed(moduleId, by)`

**Action:** Immediate alert on any `Paused` event. Track which module and who triggered it. Guardian-initiated pauses before sunset are expected; admin/DAO pauses require investigation.

### 2. Swap Volume Monitoring

**Events:** `PSM.SwapTo1kUSD(...)`, `PSM.SwapFrom1kUSD(...)`

**Metrics:**
- Total mint volume per hour/day (sum of `notional1k` from SwapTo1kUSD)
- Total redeem volume per hour/day (sum of `notional1k` from SwapFrom1kUSD)
- Net flow (mint - redeem) per day
- Fee revenue (sum of `fee1k` fields)

**Alerts:** Unusual volume spikes, sustained one-directional flow (all mint or all redeem).

### 3. Treasury / Buyback Monitoring

**Events:** `BuybackVault.BuybackExecuted(recipient, stableIn, assetOut)`

**Metrics:**
- Buyback frequency and size
- Cumulative buyback within rolling window
- Ratio of stableIn to assetOut (tracks execution price)

**Alerts:** Buybacks approaching window cap, buybacks at unfavorable prices.

### 4. Oracle Price Monitoring

**Events:** `OracleAggregator.OracleUpdated(asset, price, decimals, healthy)`

**Metrics:**
- Price update frequency per asset
- Price deviation between updates
- Health flag transitions (healthy -> unhealthy)

**Alerts:** Price marked unhealthy, price deviation exceeding `maxDiffBps`, staleness approaching `maxStale`.

### 5. Role Change Detection

**Events:** `OneKUSD.AdminChanged(old, new)`, `OneKUSD.MinterSet(account, bool)`, `OneKUSD.BurnerSet(account, bool)`, `CollateralVault.AdminChanged(old, new)`, `CollateralVault.AuthorizedCallerSet(caller, bool)`, `ParameterRegistry.AdminChanged(old, new)`

**Action:** Immediate alert on any role change. Verify against expected governance actions.

---

## Telemetry Gaps

| Contract | Gap | Impact |
|----------|-----|--------|
| **PSMLimits** | Emits no events at all | Daily volume, cap changes, day boundary resets are invisible to off-chain monitoring. Must be polled via `dailyVolumeView()` and `lastDay()` |
| **CollateralVault** | No event on admin actions that fail | Failed `deposit`/`withdraw` (reverts) leave no trace unless RPC records revert data |
| **OracleWatcher** | `HealthUpdated` only emits on explicit `updateHealth()` call | Stale oracle state between calls is unmonitored. Requires external cron to call `refreshState()` |
| **ParameterRegistry** | No event distinguishes which consumer contract reads a parameter | Cannot attribute parameter lookups to specific modules without transaction tracing |
