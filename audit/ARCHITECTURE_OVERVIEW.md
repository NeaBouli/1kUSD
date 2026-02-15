# Architecture Overview -- v0.51.x

**Protocol:** 1kUSD (collateral-backed stablecoin, 1:1 USD peg)
**Solidity:** 0.8.19 -- 0.8.30 | **EVM:** Paris | **Framework:** Foundry
**Tag:** v0.51.2 | **Tests:** 183/183 passing across 33 suites

---

## System Diagram

```
                                    +-----------------+
                                    | SafetyAutomata  |
                                    | (pause/resume)  |
                                    +-------+---------+
                                            |
                          isPaused(moduleId) | (PSM, VAULT, ORACLE)
                  +-------------------------+-------------------------+
                  |                         |                         |
          +-------v--------+      +--------v--------+      +--------v--------+
          | PegStability   |      | CollateralVault  |      | OracleAggregator|
          | Module (PSM)   |      | (custody)        |      | (price feeds)   |
          +---+---+---+----+      +--------+---------+      +--------+--------+
              |   |   |                    |                          |
   +----------+   |   +----------+        |                          |
   |              |              |        |                          |
+--v---+   +------v------+  +---v----+   |                  +-------v--------+
|OneKUSD|  | PSMLimits   |  |FeeRouter|  |                  | OracleWatcher  |
|(token)|  | (daily/tx)  |  |(v1/v2) |   |                  | (health cache) |
+------+   +-------------+  +--------+   |                  +----------------+
                                          |
                              +-----------+-----------+
                              |                       |
                     +--------v--------+    +---------v-------+
                     | ParameterRegistry|   | BuybackVault    |
                     | (DAO params)     |   | (treasury ops)  |
                     +-----------------+    +-----------------+
```

**Data flow:** Users interact with the PSM. The PSM orchestrates OneKUSD (mint/burn), CollateralVault (deposit/withdraw), OracleAggregator (pricing), PSMLimits (rate limiting), and FeeRouter (fee distribution). SafetyAutomata gates all state-changing operations via per-module pause flags.

---

## Contract Responsibilities

| Contract | Path | Lines | Purpose |
|----------|------|-------|---------|
| `PegStabilityModule` | `contracts/core/PegStabilityModule.sol` | 531 | Canonical swap facade: collateral <-> 1kUSD with fees, spreads, limits, oracle pricing |
| `OneKUSD` | `contracts/core/OneKUSD.sol` | 249 | ERC-20 token (18 decimals) with gated mint/burn, EIP-2612 permit. Pause gates mint/burn only, not transfers |
| `CollateralVault` | `contracts/core/CollateralVault.sol` | 167 | Holds ERC-20 collateral. Tracks per-asset balances. Authorized-caller whitelist for deposit/withdraw |
| `OracleAggregator` | `contracts/core/OracleAggregator.sol` | 157 | Mock price oracle with staleness/deviation health gates via ParameterRegistry |
| `SafetyAutomata` | `contracts/core/SafetyAutomata.sol` | 59 | Per-module pause/resume with guardian sunset. OpenZeppelin AccessControl |
| `PSMLimits` | `contracts/psm/PSMLimits.sol` | 60 | Daily volume cap + single-transaction cap. Day-boundary auto-reset |
| `FeeRouter` | `contracts/core/FeeRouter.sol` | 70 | Push-model fee routing (v1 interface). Authorized-caller whitelist |
| `ParameterRegistry` | `contracts/core/ParameterRegistry.sol` | 75 | Key-value store for DAO-governed protocol parameters. No value validation |
| `BuybackVault` | `contracts/core/BuybackVault.sol` | 341 | DAO-controlled treasury buyback via PSM. Per-op + rolling window caps, oracle health gate, strategy enforcement |
| `TreasuryVault` | `contracts/core/TreasuryVault.sol` | 34 | Passive multi-asset fee sink. DAO_ROLE sweep only |
| `Guardian` | `contracts/security/Guardian.sol` | 64 | Time-limited oracle pause delegated to operator. DAO-controlled |
| `OracleWatcher` | `contracts/oracle/OracleWatcher.sol` | 72 | Read-only oracle + pause health monitor with cached state |
| `OracleAdapter` | `contracts/oracle/OracleAdapter.sol` | 45 | Minimal DAO-controlled price feed with heartbeat staleness |
| `FeeRouterV2` | `contracts/router/FeeRouterV2.sol` | 13 | **Stub.** Emits events only, no token movement. Placeholder for v0.52+ |

---

## Critical Path 1: PSM.swapTo1kUSD (Mint)

```
User calls: swapTo1kUSD(tokenIn, amountIn, to, minOut, deadline)
|
+-- [GATE] whenNotPaused: safetyAutomata.isPaused(keccak256("PSM"))
+-- [GATE] nonReentrant (OpenZeppelin ReentrancyGuard)
|
+-- [CHECK] deadline != 0 && block.timestamp > deadline => PSM_DEADLINE_EXPIRED()
+-- [CHECK] amountIn > 0
|
+-- _requireOracleHealthy(tokenIn)
|   +-- oracle == address(0) => PSM_ORACLE_MISSING()
|   +-- oracle.isOperational() => checks !safety.isPaused(keccak256("ORACLE"))
|
+-- _getTokenDecimals(tokenIn)
|   +-- registry.getUint(keccak256(abi.encode("psm:tokenDecimals", tokenIn)))
|   +-- fallback: 18
|
+-- totalBps = _getMintFeeBps(tokenIn) + _getMintSpreadBps(tokenIn)
|   +-- fee: per-token registry -> global registry -> local mintFeeBps
|   +-- spread: per-token registry -> global registry -> 0
|   +-- require(totalBps <= 10_000)
|
+-- _computeSwapTo1kUSD(tokenIn, amountIn, totalBps, tokenInDecimals)
|   +-- _getPrice(tokenIn) => oracle.getPrice(tokenIn) => require(healthy, price > 0)
|   +-- _normalizeTo1kUSD: scale tokenDecimals -> 18, apply price
|   +-- fee1k = (notional1k * totalBps) / 10_000
|   +-- net1k = notional1k - fee1k
|
+-- _enforceLimits(notional1k)
|   +-- limits == address(0) => no-op
|   +-- limits.checkAndUpdate(notional1k)
|       +-- day boundary reset (block.timestamp / 1 days)
|       +-- require(amount <= singleTxCap)
|       +-- require(dailyVolume + amount <= dailyCap)
|       +-- dailyVolume += amount
|
+-- require(net1k >= minOut) => InsufficientOut()
|
+-- IERC20(tokenIn).safeTransferFrom(msg.sender, address(vault), amountIn)
+-- vault.deposit(tokenIn, msg.sender, amountIn)
|   +-- [GATE] notPaused: safety.isPaused(keccak256("VAULT"))
|   +-- [GATE] onlySupported(tokenIn)
|   +-- [GATE] onlyAuthorized (authorizedCallers[msg.sender] || admin)
|   +-- _balances[tokenIn] += amountIn
|
+-- oneKUSD.mint(to, net1k)
|   +-- [GATE] notPaused (token pause flag)
|   +-- [GATE] isMinter[msg.sender]
|   +-- _totalSupply += net1k; _balances[to] += net1k
|
+-- if (fee1k > 0 && feeRouter != address(0)):
|   feeRouter.route("PSM_MINT_FEE", address(oneKUSD), fee1k)
|   (v0.51.x: feeRouter is stub, emits event only)
|
+-- emit SwapTo1kUSD(...)
+-- emit PSMSwapExecuted(...)
+-- return net1k
```

**External calls in order:** SafetyAutomata.isPaused, OracleAggregator.isOperational, ParameterRegistry.getUint (4-6x), OracleAggregator.getPrice, PSMLimits.checkAndUpdate, IERC20.safeTransferFrom, CollateralVault.deposit, OneKUSD.mint, FeeRouterV2.route (conditional).

---

## Critical Path 2: PSM.swapFrom1kUSD (Redeem)

```
User calls: swapFrom1kUSD(tokenOut, amountIn1k, to, minOut, deadline)
|
+-- [GATE] whenNotPaused, nonReentrant
+-- [CHECK] deadline, amountIn1k > 0
+-- _requireOracleHealthy(tokenOut)
|
+-- totalBps = _getRedeemFeeBps(tokenOut) + _getRedeemSpreadBps(tokenOut)
+-- _computeSwapFrom1kUSD(tokenOut, amountIn1k, totalBps, tokenOutDecimals)
|   +-- notional1k = amountIn1k
|   +-- fee1k = (notional1k * totalBps) / 10_000
|   +-- net1k = notional1k - fee1k
|   +-- netTokenOut = _normalizeFrom1kUSD(net1k, ...) => reverse price scaling
|
+-- _enforceLimits(notional1k)
+-- require(netTokenOut >= minOut) => InsufficientOut()
|
+-- oneKUSD.burn(msg.sender, amountIn1k)    // burn FULL input amount
|   +-- [GATE] notPaused, isBurner
|   +-- _balances[from] -= amountIn1k; _totalSupply -= amountIn1k
|
+-- vault.withdraw(tokenOut, address(this), netTokenOut, "PSM_REDEEM")
|   +-- [GATE] notPaused, onlySupported, onlyAuthorized
|   +-- _balances[tokenOut] -= netTokenOut
|   +-- IERC20(tokenOut).safeTransfer(address(psm), netTokenOut)
|
+-- IERC20(tokenOut).safeTransfer(to, netTokenOut)  // PSM -> user
|
+-- emit SwapFrom1kUSD(...), PSMSwapExecuted(...)
+-- return netTokenOut
```

**Key difference from mint path:** Burns the FULL amountIn1k (including fee portion), then withdraws only the net token amount. The fee is implicitly "burned" (removed from circulation).

---

## Critical Path 3: BuybackVault.executeBuybackPSM

```
DAO calls: executeBuybackPSM(amount1k, recipient, minOut, deadline)
|
+-- [GATE] onlyDAO: msg.sender == dao (immutable)
+-- [GATE] notPaused: safety.isPaused(moduleId)
|
+-- require(recipient != address(0), amount1k > 0)
+-- bal = stable.balanceOf(address(this))
+-- require(bal >= amount1k)
|
+-- _checkPerOpTreasuryCap(amount1k, bal)
|   +-- cap = (bal * maxBuybackSharePerOpBps) / 10_000
|   +-- if (amount1k > cap) revert BUYBACK_TREASURY_CAP_EXCEEDED()
|   +-- capBps == 0 => skip (no enforcement)
|
+-- _checkBuybackWindowCap(amount1k, bal)
|   +-- dur == 0 || capBps == 0 => skip
|   +-- window expired or first call => reset: start=now, accumulated=0, basis=bal
|   +-- deltaBps = ceil(amount1k * 10_000 / basis)
|   +-- next = accumulated + deltaBps
|   +-- if (next > capBps) revert BUYBACK_TREASURY_WINDOW_CAP_EXCEEDED()
|   +-- buybackWindowAccumulatedBps = next
|
+-- _checkOracleHealthGate()
|   +-- !oracleHealthGateEnforced => skip
|   +-- IOracleHealthModule(oracleHealthModule).isHealthy()
|   +-- if (!healthy) revert BUYBACK_ORACLE_UNHEALTHY()
|
+-- _checkStrategyEnforcement()
|   +-- !strategiesEnforced => skip
|   +-- loop strategies[0..n-1] (max 16): find enabled strategy for asset
|   +-- if (!found) revert NO_ENABLED_STRATEGY_FOR_ASSET()
|
+-- stable.safeIncreaseAllowance(address(psm), amount1k)
+-- amountOut = psm.swapFrom1kUSD(asset, amount1k, recipient, minOut, deadline)
|   +-- [follows PSM.swapFrom1kUSD path above]
|
+-- emit BuybackExecuted(recipient, amount1k, amountOut)
+-- return amountOut
```

**CEI note (G2):** `_checkBuybackWindowCap` writes state (accumulated BPS, window start) BEFORE the external PSM call. Accepted risk -- `onlyDAO` makes reentrancy from untrusted caller impossible.

---

## Critical Path 4: SafetyAutomata.pauseModule

```
Caller: pauseModule(moduleId)
|
+-- if hasRole(GUARDIAN_ROLE, msg.sender):
|   +-- block.timestamp >= guardianSunset => revert GuardianExpired()
|   +-- (guardian can pause, but NOT resume)
|
+-- else:
|   +-- require(hasRole(ADMIN_ROLE) || hasRole(DAO_ROLE))
|
+-- _paused[moduleId] = true
+-- emit Paused(moduleId, msg.sender)
```

### Pause Propagation

```
SafetyAutomata._paused[moduleId] = true
|
+-- moduleId = keccak256("PSM")
|   +-- PSM.swapTo1kUSD => whenNotPaused => revert PausedError()
|   +-- PSM.swapFrom1kUSD => whenNotPaused => revert PausedError()
|
+-- moduleId = keccak256("VAULT")
|   +-- CollateralVault.deposit => notPaused => revert PAUSED()
|   +-- CollateralVault.withdraw => notPaused => revert PAUSED()
|
+-- moduleId = keccak256("ORACLE")
|   +-- OracleAggregator.setPriceMock => notPaused => revert PAUSED()
|   +-- OracleAggregator.isOperational() => returns false
|       +-- PSM._requireOracleHealthy => "PSM: oracle not operational"
|       +-- OracleWatcher.updateHealth => marks status as Paused
```

**Resume:** Only ADMIN_ROLE or DAO_ROLE. Guardian cannot resume.

---

## Oracle Architecture (v0.51.x)

OracleAggregator uses **mock price feeds** (`setPriceMock`) administered by the admin. This is intentional for v0.51.x; production feeds will be wired behind the same `getPrice(asset)` API.

**Health gates (via ParameterRegistry):**

1. **Staleness gate** (`oracle:maxStale`): If `block.timestamp > price.updatedAt + maxStale`, `getPrice` returns `healthy = false`. Value 0 disables the check.

2. **Deviation gate** (`oracle:maxDiffBps`): On `setPriceMock`, if `|newPrice - oldPrice| / oldPrice > maxDiffBps / 10_000`, the new price is marked `healthy = false`. Value 0 disables the check.

3. **Negative/zero prices** are always marked unhealthy.

**PSM enforcement:** `_requireOracleHealthy` checks `isOperational()` (not paused) before every swap. `_getPrice` checks `p.healthy && p.price > 0` during price computation.

---

## Buyback Treasury Cap Logic

### Per-Operation Cap

```
cap = (vaultStableBalance * maxBuybackSharePerOpBps) / 10_000
require(amount1k <= cap)
```

If `maxBuybackSharePerOpBps == 0`: no per-op enforcement.

### Rolling Window Cap

```
Window state: {start, duration, accumulatedBps, basisBalance}

On each buyback:
  if window expired or uninitialized:
    start = block.timestamp
    accumulatedBps = 0
    basisBalance = current stable balance

  deltaBps = ceil(amount1k * 10_000 / basisBalance)
  newAccumulated = accumulatedBps + deltaBps
  require(newAccumulated <= maxBuybackSharePerWindowBps)
```

Ceiling division ensures no rounding bypass: `ceil(a/b) = (a * 10_000 + (b - 1)) / b`.

If `buybackWindowDuration == 0` or `maxBuybackSharePerWindowBps == 0`: no window enforcement.

---

## Stub Contracts (v0.51.x)

| Contract | Status | Impact |
|----------|--------|--------|
| `FeeRouterV2` | Event-only stub | Fee routing is a no-op. Fees computed but not transferred. PSM `feeRouter` defaults to `address(0)` |
| `DAO_Timelock` | Skeleton | `execute()` reverts `NOT_IMPLEMENTED`. Events only |
| `PSMSwapCore` | Legacy | Separate from canonical PSM. Must not be deployed in place of `PegStabilityModule` |
