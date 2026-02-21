# Economic Risk Scenarios -- v0.51.5

**Protocol:** 1kUSD -- Decentralized Stablecoin
**Tag:** `audit-final-v0.51.5`
**Date:** 2026-02-22
**Status:** Core Dev review for Sepolia deployment gate

---

## Overview

This document answers five critical economic risk questions required for Core Dev
approval before production deployment. Each scenario is grounded in exact code
references, validated by passing tests, and mapped to monitoring infrastructure.

**Severity ratings:**

| Rating | Meaning |
|--------|---------|
| CRITICAL | Protocol insolvency or total loss of user funds possible |
| HIGH | Significant economic loss or extended protocol halt |
| MEDIUM | Degraded operation, recoverable without fund loss |
| LOW | Minor inefficiency or cosmetic issue |

---

## S1: What Happens if USDC Depegs?

### Risk Description

If the collateral token (USDC) depegs from $1.00, the oracle-reported price
diverges from the peg. Users minting 1kUSD receive fewer tokens per collateral
unit; users redeeming receive more collateral per 1kUSD. A severe depeg (e.g.,
USDC drops to $0.80) creates arbitrage pressure: rational actors redeem 1kUSD
for USDC at the depressed oracle price, extracting more collateral than the
economic value of the 1kUSD burned.

**Severity:** HIGH -- potential collateral drain if oracle reflects depeg
accurately; potential mispricing if oracle lags.

### Current Mitigations

**M1: Oracle deviation gate** (`OracleAggregator.sol:113-120`)

```
maxDiffBps = registry.getUint(KEY_MAX_DIFF_BPS)
if diffBps > maxDiffBps => healthy = false
```

When `oracle:maxDiffBps` is configured in the ParameterRegistry, any price
update via `setPriceMock()` that deviates more than the threshold from the
previous price is automatically marked `healthy = false`. The PSM then rejects
all swaps:

- `PegStabilityModule.sol:149` -- `require(p.healthy, "PSM: oracle unhealthy")`
- `PegStabilityModule.sol:150` -- `require(p.price > 0, "PSM: bad price")`

**Effect:** A sudden depeg beyond the configured BPS threshold halts the PSM
automatically -- no admin intervention needed.

**M2: Oracle staleness gate** (`OracleAggregator.sol:139-152`)

```
if block.timestamp > p.updatedAt + maxStale => p.healthy = false
```

If the price feed stops updating (e.g., Chainlink pauses during depeg), the
staleness gate marks the price unhealthy after `oracle:maxStale` seconds.

**M3: Price normalization is symmetric** (`PegStabilityModule.sol:258-310`)

The `_normalizeTo1kUSD()` and `_normalizeFrom1kUSD()` functions apply the
oracle price consistently in both directions. At 0.95 USD/USDC:
- Mint: 1,000 USDC -> 950 1kUSD (user receives less)
- Redeem: 950 1kUSD -> 1,000 USDC (symmetric reversal)

This means a user who minted during a depeg and redeems during recovery
gets their full collateral back.

**M4: Emergency pause** (`SafetyAutomata.sol:34-45`)

Guardian, admin, or DAO can pause the PSM module immediately via
`pauseModule(keccak256("PSM"))`, blocking all mints and redeems.

**M5: Daily volume caps** (`PSMLimits.sol:45-53`)

Even if swaps are allowed during a depeg, the daily cap (1,000,000 1kUSD in
production -- `Deploy.s.sol:30`) and single-tx cap (100,000 1kUSD --
`Deploy.s.sol:31`) bound the maximum collateral that can be extracted in any
24-hour window.

### Test Coverage

| Test | File:Line | What It Proves |
|------|-----------|----------------|
| `testEcon_DepegStress_OracleDrop` | `PSM_EconSim.t.sol:149` | Mint at 1:1, oracle drops to 0.95, mint/redeem at depeg, recovery -- symmetric |
| `testMaxDiffBpsMarksLargeJumpUnhealthy` | `OracleRegression_Health.t.sol` | Deviation gate marks large price jumps unhealthy |
| `testMaxDiffBpsAllowsSmallJump` | `OracleRegression_Health.t.sol` | Small jumps within threshold remain healthy |
| `testSwap_OracleNotOperational_Reverts` | `PSM_Config.t.sol` | PSM rejects swaps when oracle is not operational |
| `invariant_collateralBacking` | `PSM_Invariant.t.sol` | Vault always holds >= collateral deposited minus withdrawn |

### Residual Risk

1. **Oracle lag:** If the oracle price lags behind the real depeg, arbitrageurs
   can front-run the update. v0.51.x uses `setPriceMock()` (admin-controlled)
   which introduces human latency.
   - **Quantified:** At 10 bps fee with 100k single-tx cap, maximum extractable
     value per trade = (price_delta * 100,000) - fees. At 5% depeg lag:
     ~$4,990 per tx, ~$49,900 per day.

2. **Deviation gate disabled:** If `oracle:maxDiffBps = 0`, the deviation gate
   is inactive (`OracleAggregator.sol:114`). Admin must configure this value.
   Cross-ref: **KNOWN_LIMITATIONS L8** (no value validation on registry setters).

3. **Symmetric normalization amplifies redemption:** When USDC = $0.80,
   redeeming 1kUSD yields 1.25 USDC per 1kUSD. If 1kUSD supply > vault
   collateral (impossible under normal operation but possible with rounding
   dust), last redeemers may face shortfall.

### v0.52+ Improvements

| Improvement | Description |
|-------------|-------------|
| **Chainlink adapter** | Replace `setPriceMock()` with `AggregatorV3Interface.latestRoundData()` for sub-second price updates. Eliminates human latency. |
| **Circuit breaker** | Auto-pause PSM if oracle price deviates > N% from a TWAP anchor within a single block. Prevents atomic arbitrage. |
| **Per-asset deviation thresholds** | Move `maxDiffBps` from global to per-token registry keys, allowing tighter bounds on volatile collateral. |
| **Depeg redemption queue** | During a depeg event, queue redemptions and process pro-rata to prevent first-mover advantage. |

### Monitoring / Alerts

| Monitor.s.sol Section | Line | Trigger | Alert Level |
|----------------------|------|---------|-------------|
| 3. Oracle Health | `Monitor.s.sol:117` | `oracle.isOperational() == false` | CRITICAL |
| 3. Oracle Health | `Monitor.s.sol:126-130` | `p.healthy == false` or `staleSec > 3600` | DEGRADED |
| 4. Treasury & Supply | `Monitor.s.sol:146` | `collateral < supply` (collateral ratio < 100%) | DEGRADED |
| 2. PSM Limits & Volume | `Monitor.s.sol:104-105` | Volume > 80% of daily cap (mass redemption spike) | DEGRADED |

**Recommended external alert:** Off-chain price comparison between oracle price
and CoinGecko/Binance spot price. Alert if delta > 50 bps for > 5 minutes.

---

## S2: What Happens if Chainlink Feed Pauses?

### Risk Description

In v0.51.x the oracle uses `setPriceMock()` (admin-controlled mock feeds), but
the architecture is designed for Chainlink integration in v0.52+. If the price
feed stops updating -- whether due to Chainlink downtime, admin unavailability,
or network congestion -- the PSM must handle the stale state safely.

Two failure modes:
1. **Feed paused via SafetyAutomata:** Oracle module explicitly paused --
   `isOperational()` returns false immediately.
2. **Feed stale (no updates):** Price data ages past `maxStale` threshold --
   `getPrice()` returns `healthy = false` after timeout.

**Severity:** MEDIUM -- protocol halts (no fund loss), but extended downtime
degrades user trust.

### Current Mitigations

**M1: `isOperational()` gate** (`OracleAggregator.sol:76-78`)

```solidity
function isOperational() external view returns (bool) {
    return !safety.isPaused(MODULE_ID);
}
```

When the ORACLE module is paused via SafetyAutomata, `isOperational()` returns
false. The PSM checks this before every swap:

- `PegStabilityModule.sol:99-104` -- `_requireOracleHealthy()` reverts with
  `"PSM: oracle not operational"` if `isOperational()` returns false.

**M2: Staleness gate** (`OracleAggregator.sol:139-152`)

```solidity
uint256 maxStale = _getUint(KEY_MAX_STALE);
if (block.timestamp > p.updatedAt + maxStale) {
    p.healthy = false;
}
```

If configured (`oracle:maxStale > 0`), prices automatically become unhealthy
after the timeout. The PSM rejects swaps via `require(p.healthy)` at
`PegStabilityModule.sol:149`.

**M3: Pause propagation** (`SafetyAutomata.sol:34-45`)

Guardian can pause the ORACLE module (before sunset), which cascades:
- `OracleAggregator.isOperational()` -> false
- `OracleAggregator.setPriceMock()` -> reverts `PAUSED()` (line 103, `notPaused` modifier)
- `OracleWatcher.updateHealth()` -> marks status as Paused
- PSM `_requireOracleHealthy()` -> reverts on every swap

**M4: OracleWatcher cached health** (`OracleWatcher.sol`)

The OracleWatcher maintains a cached health state that can be polled by
external monitoring without incurring the cost of full oracle evaluation.

**M5: PSM still allows redemptions at stale price (if healthy flag set)**

If `maxStale = 0` (staleness gate disabled), the last-known price remains
usable indefinitely. This is a design choice: the admin must either configure
staleness OR manually pause the oracle.

### Test Coverage

| Test | File:Line | What It Proves |
|------|-----------|----------------|
| `testEcon_WorstCase_OracleDown` | `PSM_EconSim.t.sol:267` | Oracle pause blocks all swaps; resume restores operation |
| `testSwap_OracleNotOperational_Reverts` | `PSM_Config.t.sol` | PSM reverts when oracle not operational |
| `testSwap_OracleNotSet_Reverts` | `PSM_Config.t.sol` | PSM reverts when oracle address is zero |
| `testMaxStaleMarksOldPriceUnhealthy` | `OracleRegression_Health.t.sol` | Staleness gate marks aged prices unhealthy |
| `testMaxStaleZeroDoesNotAlterHealth` | `OracleRegression_Health.t.sol` | Disabled staleness gate preserves raw health |
| `testPausePropagation` | `OracleRegression_Watcher.t.sol` | Oracle pause propagates to OracleWatcher |
| `testGuardianPauseStopsPSM` | `Guardian_PSMPropagation.t.sol` | Guardian pause cascades to block PSM swaps |

### Residual Risk

1. **Staleness gate disabled by default:** If `oracle:maxStale = 0` (no
   registry entry), the staleness gate is inactive. A stale price persists
   indefinitely until manually updated or the oracle is paused.
   Cross-ref: **KNOWN_LIMITATIONS L8** (no value validation on registry).

2. **No automatic recovery:** After a feed pause, the oracle does not
   automatically resume. Admin must call `setPriceMock()` with fresh data AND
   `resumeModule()` if the oracle was paused. Both require admin availability.

3. **Resume requires ADMIN or DAO:** Guardian can pause but cannot resume
   (`SafetyAutomata.sol:47-54`). If admin key is unavailable during recovery,
   the protocol remains halted until DAO governance acts.

### v0.52+ Improvements

| Improvement | Description |
|-------------|-------------|
| **Chainlink integration** | `AggregatorV3Interface.latestRoundData()` provides automatic price updates with built-in heartbeat. Eliminates manual `setPriceMock()`. |
| **Fallback oracle** | Secondary price source (e.g., Uniswap TWAP) activated when primary feed is stale > N seconds. |
| **Auto-resume with health check** | When Chainlink resumes after downtime, auto-resume oracle module if price is within deviation bounds. |
| **Mandatory staleness config** | Enforce `maxStale > 0` at deployment. Reject `maxStale = 0` in ParameterRegistry setter. |

### Monitoring / Alerts

| Monitor.s.sol Section | Line | Trigger | Alert Level |
|----------------------|------|---------|-------------|
| 1. Emergency Pause | `Monitor.s.sol:80` | `safety.isPaused(ORACLE) == true` | CRITICAL |
| 3. Oracle Health | `Monitor.s.sol:117-120` | `oracle.isOperational() == false` | CRITICAL |
| 3. Oracle Health | `Monitor.s.sol:126-130` | `staleSec > STALE_WARN_SEC (3600)` | DEGRADED |
| 3. Oracle Health | `Monitor.s.sol:123` | `p.healthy == false` | DEGRADED |

**Recommended external alert:** Monitor `block.timestamp - price.updatedAt`
every 60 seconds. Alert at 50% of `maxStale`; escalate to CRITICAL at 90%.

---

## S3: What Happens if the DAO Key is Compromised?

### Risk Description

The DAO/admin key has sweeping control over the protocol. A compromised key can:

1. **Mint unlimited 1kUSD:** Grant minter role to attacker address
   (`OneKUSD.setMinter()`) then mint arbitrary tokens.
2. **Drain collateral vault:** Add attacker as authorized caller
   (`CollateralVault.setAuthorizedCaller()`) then withdraw all collateral.
3. **Manipulate oracle:** Set price to any value via `setPriceMock()`, then
   exploit the mispricing.
4. **Disable safety:** Resume paused modules, remove caps, set fees to 0 or
   100%.
5. **Drain BuybackVault:** Call `withdrawStable()` or `withdrawAsset()`
   directly (`BuybackVault.sol:146,153`).

**Severity:** CRITICAL -- total protocol compromise, complete loss of funds.

### Current Mitigations

**M1: Single-admin architecture** (by design for v0.51.x testnet)

All admin functions are gated by `onlyRole(ADMIN_ROLE)` or `onlyDAO`:

| Contract | Admin Gate | Line |
|----------|-----------|------|
| PegStabilityModule | `onlyRole(ADMIN_ROLE)` | `:78,83,88,458` |
| OneKUSD | `onlyAdmin` | Throughout |
| CollateralVault | `onlyAdmin` | `:68` |
| SafetyAutomata | `ADMIN_ROLE` / `DAO_ROLE` | `:39,48` |
| BuybackVault | `onlyDAO` | `:99` |
| PSMLimits | `onlyDAO` | `:18` |
| ParameterRegistry | `onlyAdmin` | `:35` |

**M2: Guardian sunset** (`SafetyAutomata.sol:12,36`)

The Guardian role has a hard expiration (`guardianSunset = deployment + 365
days`). After sunset, Guardian cannot pause, limiting the blast radius of a
compromised Guardian key. Only admin/DAO can pause post-sunset.

**M3: BuybackVault caps**

Even with DAO access, the BuybackVault enforces per-op and window caps
(`BuybackVault.sol:203-230`). However, the DAO can set
`maxBuybackSharePerOpBps = 10000` to bypass this, or call `withdrawStable()`
directly.

**M4: Monitor.s.sol role state check** (`Monitor.s.sol:178-200`)

Detects if PSM minter/burner/vault-auth/limits-auth roles have been
modified. CRITICAL alert if any expected authorization is missing.

### Test Coverage

| Test | File:Line | What It Proves |
|------|-----------|----------------|
| `testSetMinter_NonAdmin_Reverts` | `OneKUSD_Config.t.sol` | Only admin can grant minter role |
| `testSetBurner_NonAdmin_Reverts` | `OneKUSD_Config.t.sol` | Only admin can grant burner role |
| `testDeposit_UnauthorizedCaller_Reverts` | `CollateralVault_Auth.t.sol` | Vault rejects unauthorized callers |
| `testWithdraw_UnauthorizedCaller_Reverts` | `CollateralVault_Auth.t.sol` | Vault rejects unauthorized withdrawals |
| `testSetAdmin_NonAdmin_Reverts` | `PSM_Config.t.sol` | PSM admin transfer requires admin |
| `testExecuteBuybackOnlyDaoCanCall` | `BuybackVault.t.sol` | Buyback restricted to DAO address |
| `testWithdrawStableOnlyDao` | `BuybackVault.t.sol` | Direct withdrawal restricted to DAO |
| `testPauseModule_Unauthorized_Reverts` | `SafetyAutomata_Config.t.sol` | Non-authorized cannot pause |
| `testResumeModule_Unauthorized_Reverts` | `SafetyAutomata_Config.t.sol` | Non-authorized cannot resume |

### Residual Risk

1. **No on-chain timelock:** `DAO_Timelock.sol` has `execute()` returning
   `NOT_IMPLEMENTED` (`DAO_Timelock.sol:56`). All admin actions execute
   instantly with no delay for community review.
   Cross-ref: **KNOWN_LIMITATIONS L5**.

2. **Single-step admin transfer:** All contracts use `setAdmin(address)` with
   immediate effect. A typo in the new address permanently locks out admin.
   Cross-ref: **KNOWN_LIMITATIONS L11**.

3. **No multisig enforcement:** The admin address is a plain EOA in testnet
   deployment. No on-chain requirement for multi-signature approval.

4. **Admin can disable all safety:** Set `maxDiffBps = 0` and `maxStale = 0`
   to remove oracle safety gates, then push manipulated prices. No on-chain
   constraint prevents this sequence.

5. **BuybackVault bypass:** DAO can call `withdrawStable(to, amount)` or
   `withdrawAsset(to, amount)` directly (`BuybackVault.sol:146,153`),
   bypassing all per-op and window caps entirely.

### v0.52+ Improvements

| Improvement | Description |
|-------------|-------------|
| **DAO Timelock (functional)** | Implement `DAO_Timelock.execute()` with 48-hour minimum delay. Queue all admin actions. Emit `ActionQueued` events for off-chain monitoring. |
| **Two-step admin transfer** | Replace `setAdmin(newAdmin)` with `proposeAdmin(newAdmin)` + `acceptAdmin()`. Prevents typo-induced lockout. Pattern: OpenZeppelin `Ownable2Step`. |
| **Gnosis Safe multisig** | Require N-of-M signatures for all admin actions. Deploy with 3-of-5 minimum for mainnet. |
| **Role separation** | Split ADMIN into OPERATOR (day-to-day: set prices, adjust fees) and GOVERNANCE (structural: change oracle, add collateral, transfer admin). GOVERNANCE behind timelock only. |
| **Action allowlist** | Timelock with per-function delay tiers: 0h for pause, 24h for fee changes, 72h for oracle/admin changes, 7d for contract upgrades. |
| **Guardian-only emergency drain** | Add a `emergencyWithdrawAll()` to CollateralVault gated by Guardian with a separate sunset, allowing recovery without full admin access. |

### Monitoring / Alerts

| Monitor.s.sol Section | Line | Trigger | Alert Level |
|----------------------|------|---------|-------------|
| 5. Role State | `Monitor.s.sol:187` | `PSM not minter` (role revoked) | CRITICAL |
| 5. Role State | `Monitor.s.sol:190` | `PSM not burner` (role revoked) | CRITICAL |
| 5. Role State | `Monitor.s.sol:193-194` | `PSM vault unauthorized` | CRITICAL |
| 5. Role State | `Monitor.s.sol:199` | `Oracle not wired to PSM` | CRITICAL |

**Recommended external alerts:**

| Alert | Description |
|-------|-------------|
| `AdminChanged` event | Monitor all contracts for admin transfer events. Alert immediately on any change. |
| `MinterSet` / `BurnerSet` | Alert on any grant of minter/burner role to unexpected addresses. |
| `AuthorizedCallerSet` | Alert on vault/limits authorized caller changes. |
| Multisig signer change | Monitor Gnosis Safe signer set (when deployed). |

---

## S4: How Fast Can a Bank Run Exhaust the Caps?

### Risk Description

In a panic scenario, users rush to redeem 1kUSD for collateral. The question is
whether rate limits provide sufficient time for admin response, and whether
the protocol remains solvent throughout.

**Severity:** MEDIUM -- protocol designed to handle this; caps enforce orderly
unwinding.

### Current Mitigations

**M1: Daily volume cap** (`PSMLimits.sol:45-53`)

```solidity
function checkAndUpdate(uint256 amount) public onlyAuthorized {
    uint256 day = block.timestamp / 1 days;
    if (day > lastUpdatedDay) {
        dailyVolume = 0;
        lastUpdatedDay = day;
    }
    if (amount > singleTxCap) revert("swap too large");
    if (dailyVolume + amount > dailyCap) revert("swap too large");
    dailyVolume += amount;
}
```

Production caps from `Deploy.s.sol:30-31`:

| Parameter | Value | Effect |
|-----------|-------|--------|
| `DAILY_CAP` | 1,000,000 1kUSD | Max 1M redeemed per UTC day |
| `SINGLE_TX_CAP` | 100,000 1kUSD | Max 100k per transaction |

**M2: Day-boundary reset** (`PSMLimits.sol:46-49`)

Volume resets at UTC 00:00 (`block.timestamp / 1 days`). After cap exhaustion,
users must wait until the next day boundary. Minimum admin response time =
(seconds remaining in current UTC day).

**M3: Caps apply to both mint and redeem**

Both `swapTo1kUSD` and `swapFrom1kUSD` call `_enforceLimits(notional1k)` at
`PegStabilityModule.sol:344` and `:391` respectively. A 1M daily cap means 1M
total volume across ALL operations, not 1M per direction.

**M4: Collateral is always fully backed**

Under normal operation, every 1kUSD is backed by >= 1 USD of collateral in the
vault (invariant `invariant_collateralBacking` in `PSM_Invariant.t.sol`). A
bank run does not create insolvency -- it simply exhausts daily capacity.

### Exhaustion Timeline

With production caps:

| Time | Scenario | Volume Used | Remaining |
|------|----------|-------------|-----------|
| T+0 | Whale redeems 100k (single-tx cap) | 100k | 900k |
| T+1 min | 9 more users redeem 100k each | 1,000k | 0 |
| T+1 min | Cap exhausted | -- | Swaps revert until next day |
| T+24h | Day boundary reset | 0 | 1,000k |

**Worst case:** 10 transactions of 100k = 1M 1kUSD redeemed in ~2 minutes
(limited only by block time). Cap is exhausted in under 5 minutes.

**Full protocol drain timeline** (at 1M/day with 10M 1kUSD supply):
- Day 1: 1M redeemed (90% remaining)
- Day 10: 10M redeemed (0% remaining)
- A 10M supply takes 10 days to fully unwind at production caps.

### Test Coverage

| Test | File:Line | What It Proves |
|------|-----------|----------------|
| `testEcon_BankRun_MassRedemption` | `PSM_EconSim.t.sol:187` | 10M mint then full redemption -- clean exit, zero supply, user fully restored |
| `testEcon_DailyCapExhaustion_Recovery` | `PSM_EconSim.t.sol:378` | Cap exhaustion blocks swaps; day boundary reset restores capacity |
| `testDailyCapReverts` | `PSMLimits.t.sol` | Swap exceeding daily cap reverts |
| `testSingleCapReverts` | `PSMLimits.t.sol` | Swap exceeding single-tx cap reverts |
| `testDailyResetOnNextDay` | `PSMLimits.t.sol` | Day boundary resets daily volume to 0 |
| `invariant_dailyVolumeNeverExceedsCap` | `PSMLimits_Invariant.t.sol` | Fuzzed: daily volume always <= daily cap |
| `invariant_vaultSolvent` | `PSM_Invariant.t.sol` | Fuzzed: vault balance always >= tracked deposits |

### Residual Risk

1. **Cap-to-supply ratio:** At 1M daily cap vs potential 100M+ supply at scale,
   a full unwind takes 100+ days. Users may lose confidence waiting. However,
   this is the intended design: orderly unwinding prevents a destructive rush.

2. **No per-direction caps:** Both mints and redeems share the same daily
   counter. During a bank run, attackers could waste cap space with mints to
   slow redemptions. Mitigation: minting during a depeg is economically
   irrational (user receives less 1kUSD per collateral).

3. **Caps are DAO-adjustable:** The DAO can call `limits.setLimits(newDaily,
   newSingle)` at any time (`PSMLimits.sol:34-38`). A compromised DAO could
   set caps to zero (halting the protocol) or to `type(uint256).max`
   (removing all limits). Cross-ref: **S3 (DAO key compromise)**.

4. **No events from PSMLimits:** Volume changes and cap exhaustion emit no
   events (`PSMLimits.sol`). Monitoring requires polling contract state.
   Cross-ref: **KNOWN_LIMITATIONS L10**.

### v0.52+ Improvements

| Improvement | Description |
|-------------|-------------|
| **Per-direction caps** | Separate `dailyMintCap` and `dailyRedeemCap` to prevent mint-spam attacks during bank runs. |
| **PSMLimits events** | Emit `VolumeUpdated(day, newVolume, cap)` and `CapExhausted(day)` events for real-time off-chain monitoring. |
| **Dynamic caps** | Auto-reduce daily cap when collateral ratio drops below 110%. Conversely, increase cap when ratio exceeds 150%. Governed by ParameterRegistry thresholds. |
| **Redemption queue** | When caps are hit, queue pending redemptions and process FIFO at next day boundary. Prevents UI-level front-running of the reset. |
| **Circuit breaker** | If > 50% of daily cap consumed in < 1 hour, auto-pause PSM for admin review. Configurable via ParameterRegistry. |

### Monitoring / Alerts

| Monitor.s.sol Section | Line | Trigger | Alert Level |
|----------------------|------|---------|-------------|
| 2. PSM Limits & Volume | `Monitor.s.sol:104-105` | Utilization >= 80% of daily cap | DEGRADED |
| 4. Treasury & Supply | `Monitor.s.sol:146` | Collateral ratio < 100% | DEGRADED |
| 1. Emergency Pause | `Monitor.s.sol:74` | PSM paused (admin response to run) | CRITICAL |

**Recommended external alerts:**

| Alert | Description |
|-------|-------------|
| Volume velocity | If > 500k redeemed in < 1 hour, alert admin for potential bank run. |
| Cap exhaustion | Poll `dailyVolume >= dailyCap` every 5 minutes. Alert when cap is hit. |
| Day boundary prep | Alert at UTC 23:00 if volume > 90% of cap (prepare for reset surge). |

---

## S5: Are Fees Sufficient for Sustainability?

### Risk Description

Protocol sustainability requires that fees collected over time exceed
operational costs (gas, infrastructure, audit, development). If fees are too
low, the protocol is economically unviable. If too high, users migrate to
competitors.

**Severity:** LOW (short-term) / MEDIUM (long-term) -- protocol functions
correctly regardless of fee level; sustainability is a business concern.

### Current Fee Architecture

**Fee computation** (`PegStabilityModule.sol:258-310`):

```
fee1k = (notional1k * totalBps) / 10_000
```

Where `totalBps = feeBps + spreadBps` with a 3-tier cascade:
1. Per-token registry override (`PegStabilityModule.sol:223-255`)
2. Global registry default
3. Local storage fallback

**Production defaults** (`Deploy.s.sol:32-33`):

| Parameter | Value | Revenue per $1M volume |
|-----------|-------|----------------------|
| `MINT_FEE_BPS` | 10 (0.1%) | $1,000 |
| `REDEEM_FEE_BPS` | 10 (0.1%) | $1,000 |

**Fee bounds:** `require(mintFee <= 10_000)` and `require(redeemFee <= 10_000)`
at `PegStabilityModule.sol:460-461`. No minimum fee enforced.

**Spread mechanism** (`PegStabilityModule.sol:471-530`):

Spreads are additive to fees. `totalBps = feeBps + spreadBps` computed at
`PegStabilityModule.sol:336-339` (mint) and `:383-386` (redeem). Combined
total is capped at 10,000 bps by `require(totalBps <= 10_000)`.

### Fee Collection Status (v0.51.x)

**FeeRouter is a stub** (`FeeRouterV2.sol` -- 13 lines). The `route()` function
emits an event but does NOT transfer tokens. Cross-ref: **KNOWN_LIMITATIONS L3**.

In v0.51.x, fees are effectively:
- **Mint fees:** Burned (never minted). User deposits 1000 USDC, receives 999
  1kUSD. The 1 1kUSD fee is never created -- collateral surplus accrues in the
  vault.
- **Redeem fees:** Burned. User burns 500 1kUSD, receives 499.5 USDC. The 0.5
  1kUSD fee portion is burned but only 499.5 USDC leaves the vault.

**Net effect:** Fees accumulate as a collateral surplus in the vault
(vault_balance > 1kUSD_supply). This surplus is protocol revenue that can be
swept by the DAO once FeeRouter is implemented.

### Sustainability Analysis

**Revenue projections at 10 bps (0.1% each way):**

| Daily Volume | Annual Volume | Annual Revenue (mint+redeem) |
|-------------|--------------|----------------------------|
| $100k | $36.5M | $73,000 |
| $1M | $365M | $730,000 |
| $10M | $3.65B | $7,300,000 |
| $100M | $36.5B | $73,000,000 |

**Break-even estimate** (rough):
- Annual operational costs (infra + dev + audit): ~$500k-$1M
- Required daily volume for break-even: ~$1.4M-$2.7M/day
- At 10 bps, protocol is sustainable above ~$2M daily volume.

**Fee comparison (DeFi stablecoins):**

| Protocol | Mint Fee | Redeem Fee |
|----------|----------|------------|
| MakerDAO PSM | 0 bps | 0 bps |
| Frax | 0-30 bps | 0-30 bps |
| Liquity v2 | 50+ bps | 50+ bps |
| **1kUSD** | **10 bps** | **10 bps** |

10 bps is competitive. Lower than Liquity, higher than Maker (which subsidizes
with DSR interest).

### Test Coverage

| Test | File:Line | What It Proves |
|------|-----------|----------------|
| `testEcon_FeeAccrual_30Days` | `PSM_EconSim.t.sol:114` | 30-day simulation: fees accrue correctly over time, surplus grows monotonically |
| `testEcon_WorstCase_ZeroFees` | `PSM_EconSim.t.sol:215` | Zero fees: exact 1:1 roundtrip, no dust, no protocol revenue |
| `testEcon_WorstCase_MaxFees` | `PSM_EconSim.t.sol:241` | 50%+50% fees: 1M input -> 250k after roundtrip, 750k retained by protocol |
| `testEcon_SpreadAndFeeInteraction` | `PSM_EconSim.t.sol:343` | Fees + spreads combine correctly, no double-counting |
| `testEcon_CollateralSurplus_FeeRetention` | `PSM_EconSim.t.sol:415` | Proof: vault surplus == cumulative mint fees + redeem surplus |
| `invariant_feeNeverExceedsInput` | `PSM_Invariant.t.sol` | Fuzzed: fee amount always < input amount |

### Residual Risk

1. **No fee collection in v0.51.x:** FeeRouterV2 is a stub. Fees accrue as
   vault surplus but are not actively collected or distributed. The DAO cannot
   sweep surplus without a functional fee router or manual vault withdrawal.
   Cross-ref: **KNOWN_LIMITATIONS L3**.

2. **Rounding favors users on mint:** Fee truncation (`(notional * bps) /
   10_000` rounds down) means the protocol loses up to 1 wei per fee
   computation. At scale, this is negligible (<$0.01/year at $1B volume).

3. **Fee can be set to zero:** Admin can call `setFees(0, 0)` with no minimum
   enforcement. This is by design (allows fee-free operation during bootstrap)
   but creates sustainability risk if left at zero indefinitely.

4. **No fee-on-transfer token support:** If a fee-on-transfer collateral token
   is whitelisted, the vault receives less than `amountIn` but accounts for
   the full amount. Over time, vault becomes undercollateralized.
   Cross-ref: **KNOWN_LIMITATIONS L9**.

### v0.52+ Improvements

| Improvement | Description |
|-------------|-------------|
| **Functional FeeRouter** | Implement real token transfers in `FeeRouterV2.route()`. Split fees: X% to treasury, Y% to insurance fund, Z% to stakers. |
| **Minimum fee floor** | Enforce `mintFeeBps >= MIN_FEE` and `redeemFeeBps >= MIN_FEE` in `setFees()`. Suggested floor: 1 bps. Prevents accidental zero-fee config. |
| **Dynamic fee model** | Adjust fees based on utilization: higher fees when volume approaches cap (congestion pricing), lower fees during low activity (incentivize usage). |
| **Fee-on-transfer guard** | Add `balanceBefore`/`balanceAfter` check in `CollateralVault.deposit()` to detect and reject FoT tokens. Revert if `received < expected`. |
| **Revenue dashboard** | Off-chain service that reads vault surplus (`vault_balance - 1kUSD_supply`) and computes annualized revenue. Feed into governance for fee parameter decisions. |

### Monitoring / Alerts

| Monitor.s.sol Section | Line | Trigger | Alert Level |
|----------------------|------|---------|-------------|
| 4. Treasury & Supply | `Monitor.s.sol:146` | Supply vs collateral ratio (surplus = revenue proxy) | INFO |
| 2. PSM Limits & Volume | `Monitor.s.sol:90` | Daily volume (revenue velocity proxy) | INFO |

**Recommended external alerts:**

| Alert | Description |
|-------|-------------|
| Fee change event | Monitor `FeesUpdated(mintFee, redeemFee)` events. Alert if fees set to 0. |
| Surplus tracking | Daily snapshot of `vault_balance - 1kUSD_supply`. Alert if surplus decreases (shouldn't happen without withdrawals). |
| Volume trend | 7-day moving average of daily volume. Alert if trending below break-even threshold. |

---

## Cross-Reference Matrix

### Scenarios vs KNOWN_LIMITATIONS

| Limitation | S1 | S2 | S3 | S4 | S5 |
|-----------|----|----|----|----|-----|
| **L1** CEI Pattern | | | | | |
| **L3** FeeRouter Stub | | | | | X |
| **L5** DAO Timelock Stub | | | X | | |
| **L8** No Registry Validation | X | X | X | | |
| **L9** No FoT Support | | | | | X |
| **L10** No PSMLimits Events | | | | X | |
| **L11** Single-Step Admin | | | X | | |

### Scenarios vs Monitor.s.sol Sections

| Monitor Section | S1 | S2 | S3 | S4 | S5 |
|----------------|----|----|----|----|-----|
| 1. Emergency Pause | X | X | | X | |
| 2. PSM Limits & Volume | X | | | X | X |
| 3. Oracle Health | X | X | | | |
| 4. Treasury & Supply | X | | | X | X |
| 5. Role State | | | X | | |

### Scenarios vs Invariant Properties

| Invariant | S1 | S2 | S3 | S4 | S5 |
|----------|----|----|----|----|-----|
| `invariant_supplyConservation` | X | | | X | |
| `invariant_collateralBacking` | X | | | X | |
| `invariant_vaultSolvent` | X | | | X | |
| `invariant_feeNeverExceedsInput` | | | | | X |
| `invariant_dailyVolumeNeverExceedsCap` | | | | X | |

---

## Summary: Risk Priority Matrix

| Scenario | Severity | Likelihood | Mitigation Coverage | Residual |
|----------|---------|------------|-------------------|----------|
| **S1** USDC Depeg | HIGH | MEDIUM | 5 mitigations, deviation gate, caps | Oracle lag, disabled gates |
| **S2** Feed Pause | MEDIUM | MEDIUM | 4 mitigations, auto-staleness, pause cascade | Disabled staleness, no auto-resume |
| **S3** DAO Compromise | CRITICAL | LOW | Access control on all functions | No timelock, single-step transfer, no multisig |
| **S4** Bank Run | MEDIUM | MEDIUM | Daily/tx caps, full collateral backing | Shared cap, no events, adjustable by DAO |
| **S5** Fee Sustainability | LOW | LOW | Fee architecture in place, surplus accrual | Stub router, no minimum fee, no collection |

**Top priority for v0.52+:** Functional DAO Timelock (addresses S3) and
Chainlink integration (addresses S1 + S2). These two improvements eliminate
the highest-severity residual risks.
