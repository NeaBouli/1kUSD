# Security Audit Report — v0.51.x (February 2026)

**Scope:** All smart contracts in `contracts/` and `foundry/test/`
**Baseline:** commit `999278d` (pre-audit), Final: `1f045a7` (PR #84 merged)
**Tests:** 76/76 passing across 22 suites
**Auditor:** Claude Code (automated, human-reviewed)

---

## 1. Changes Applied

### 1.1 PR #84 — Rollback + v0.51.x Fixes

PR #84 contains three scoped changes applied on top of the initial security fix commit (`8fd9869`).

#### D1: Rollback of `_requireAssetSupported` from PSM

| Field | Detail |
|---|---|
| Intent | Rollback out-of-scope policy gate |
| Files | `PegStabilityModule.sol`, 5 mock files |
| Lines | -75 |

**What was removed:**
- `_requireAssetSupported(address token)` internal function
- `PSM_UNSUPPORTED_ASSET` custom error
- Two call sites in `swapTo1kUSD` and `swapFrom1kUSD`
- `isAssetSupported()` stubs from 5 mock vault files

**Why rolled back:**
1. Out of v0.51.x scope — introduced a new cross-contract interface dependency (PSM calling `vault.isAssetSupported()`)
2. Redundant — `CollateralVault.deposit()` and `CollateralVault.withdraw()` already enforce asset support via the `onlySupported(asset)` modifier
3. Created a deploy-order trap — vault must whitelist every token before PSM can operate, adding a "forgot config = system bricked" scenario
4. Required changes to 5 mock files just to satisfy the new interface call

**Protection still in place:** The vault layer rejects unsupported assets at `deposit`/`withdraw` time. No funds-at-risk gap from this rollback.

#### D2: Fee Bounds Validation on `PSM.setFees()`

| Field | Detail |
|---|---|
| Intent | Bugfix — prevent misconfiguration DoS |
| Files | `PegStabilityModule.sol` |
| Lines | +2 |

**What was added:**
```solidity
require(mintFee <= 10_000, "PSM: mintFee too high");
require(redeemFee <= 10_000, "PSM: redeemFee too high");
```

**Why:** Without bounds, an admin could set fees >100% (>10,000 bps). The internal `_getMintFeeBps`/`_getRedeemFeeBps` functions validate the local fallback with `require(raw <= 10_000)`, so invalid fees would cause every swap to revert with a confusing error. The fix validates at the setter, giving a clear revert reason at configuration time.

**Wiring impact:** None. Non-breaking. Existing valid fee values are unaffected.

#### D3: Dead Code Removal from PSM

| Field | Detail |
|---|---|
| Intent | Code quality — remove unreachable functions |
| Files | `PegStabilityModule.sol` |
| Lines | -52 |

**What was removed:**
- `_pullCollateral(address, address, uint256)`
- `_pushCollateral(address, address, uint256)`
- `_mint1kUSD(address, uint256)`
- `_burn1kUSD(address, uint256)`
- `_routeFee(address, uint256)`

**Why:** These were scaffolded for DEV-45 but `swapTo1kUSD`/`swapFrom1kUSD` inline the logic directly. No code path calls these functions. They duplicate logic from the actual swap paths and could diverge, confusing auditors.

### 1.2 Earlier Security Fixes (commit `8fd9869`)

These changes from the initial audit remain on `main` and are in-scope for v0.51.x:

| Fix | Contract | Classification | Rationale |
|---|---|---|---|
| `authorizedCallers` on PSMLimits | `PSMLimits.sol` | Critical (DoS) | `checkAndUpdate` was public — anyone could exhaust daily caps, blocking PSM swaps |
| `authorizedCallers` on FeeRouter | `FeeRouter.sol` | Critical (fund drain) | `routeToTreasury` was open — anyone could redirect tokens to any address |
| OracleWatcher try-catch fix | `OracleWatcher.sol` | Critical (silent failure) | Raw staticcall used wrong ABI encoding; watcher never detected paused oracle state |
| Deadline enforcement in PSM | `PegStabilityModule.sol` | High (mempool risk) | IPSM interface declared `deadline` param but PSM ignored it (`/*deadline*/`) |
| Real CollateralVault deposit/withdraw | `CollateralVault.sol` | High (functional) | deposit/withdraw were `NOT_IMPLEMENTED` stubs; now tracks balances and transfers tokens |
| SafeERC20 in PSMSwapCore | `PSMSwapCore.sol` | High (token compat) | `transferFrom` → `safeTransferFrom` for non-standard tokens (USDT) |
| BuybackVault consolidation | `BuybackVault.sol` | Medium (code quality) | Removed duplicate `executeBuyback`, kept canonical `executeBuybackPSM`; deduplicated events; standardized modifiers |

---

## 2. Remaining Issues

### 2.1 v0.51.x — Low Priority (no action required)

#### B1: `OneKUSD._transfer` unchecked addition

**File:** `contracts/core/OneKUSD.sol:243-246`
```solidity
unchecked {
    _balances[from] = bal - amount;
    _balances[to] += amount;  // theoretically overflowable
}
```
**Risk:** Practically zero. `_totalSupply` is bounded by `mint` calls. Reaching `2^256` on a single address is infeasible. The subtraction is safe (pre-checked), but the addition shares the `unchecked` block.
**Recommendation:** No action for v0.51.x. If refactoring OneKUSD in v0.52+, move the addition outside `unchecked`.

#### B5: `FeeRouterV2` stub has no access control

**File:** `contracts/router/FeeRouterV2.sol:9`
**Risk:** None — the stub only emits events, no token movements. If it gains transfer logic in v0.52+, access control must be added.
**Recommendation:** No action. Tag as v0.52+ when stub is implemented.

#### B6: `setFees` had no upper bound — **FIXED in D2**

#### B7: PSM has no `setFeeRouter` admin function

**File:** `contracts/core/PegStabilityModule.sol`
**Risk:** `feeRouter` is declared but never settable — fee routing code in `swapTo1kUSD` is dead (`address(feeRouter) == address(0)` always true). Fees are deducted from user output but not routed anywhere — effectively "burned" (not minted).
**Recommendation:** v0.52+ — add `setFeeRouter()` when fee routing is wired. Current behavior is safe (implicit burn).

#### B8: `OracleAdapter.latestPrice` reverts if never initialized

**File:** `contracts/oracle/OracleAdapter.sol:38`
**Risk:** None. If `setPrice` was never called, `lastUpdate == 0`, causing `block.timestamp - 0 > heartbeat`, which correctly reverts with "stale price".
**Recommendation:** No action.

### 2.2 v0.51.x — Informational

#### B3: Dead PSM helpers — **FIXED in D3**

#### B4: `PSMSwapCore` is a separate legacy contract

**File:** `contracts/psm/PSMSwapCore.sol`
**Risk:** Coexists with the canonical `PegStabilityModule.sol`. Has its own `dao`, `oracle`, `feeRouter`, `stableToken`. If accidentally deployed instead of `PegStabilityModule`, swaps would bypass limits, spreads, and oracle health checks.
**Recommendation:** v0.52+ — mark as deprecated or remove. Not a runtime risk if correct contract is deployed.

### 2.3 v0.52+ Proposals (NOT implemented)

| Issue | Description | Why deferred |
|---|---|---|
| CollateralVault ReentrancyGuard | `withdraw` calls `safeTransfer` which could callback via malicious token. Currently safe because only PSM (which has `nonReentrant`) can call. | Adding ReentrancyGuard is defense-in-depth, not a current exploit path |
| ParameterRegistry value validation | Admin can set any uint for any key — no range checks | Documented as "no validations in DEV37" |
| DAOTimelock real execution | `execute()` always reverts with `NOT_IMPLEMENTED` | Skeleton by design |
| Received-amount vault accounting | Deposit trusts `amount` parameter instead of measuring `balanceAfter - balanceBefore` | Required for FoT token support; not in v0.51.x scope |
| PSMSwapCore deprecation | Legacy contract should be marked or removed | Not a runtime risk |

---

## 3. Wiring Requirements for Deployment

### 3.1 Contract Deploy Order

```
1. SafetyAutomata(admin, guardianSunsetTimestamp)
2. ParameterRegistry(admin)
3. OracleAggregator(admin, safetyAutomata, parameterRegistry)
4. CollateralVault(admin, safetyAutomata, parameterRegistry)
5. OneKUSD(admin)
6. PegStabilityModule(admin, oneKUSD, collateralVault, safetyAutomata, parameterRegistry)
7. PSMLimits(dao, dailyCap, singleTxCap)                    [optional]
8. FeeRouter(admin)                                          [optional]
9. BuybackVault(stable, asset, dao, safety, psm, moduleId)   [optional]
10. OracleWatcher(oracleAggregator, safetyAutomata)           [optional]
11. Guardian(dao, guardianSunset)                              [optional]
```

### 3.2 Authorized Caller Whitelist

These calls MUST be executed after deployment or the system will revert on first use:

| Contract | Call | Why |
|---|---|---|
| OneKUSD | `setMinter(psm, true)` | PSM must mint 1kUSD on swapTo1kUSD |
| OneKUSD | `setBurner(psm, true)` | PSM must burn 1kUSD on swapFrom1kUSD |
| CollateralVault | `setAuthorizedCaller(psm, true)` | PSM must call deposit/withdraw |
| CollateralVault | `setAssetSupported(token, true)` | Per collateral token |
| PSMLimits | `setAuthorizedCaller(psm, true)` | PSM must call checkAndUpdate |
| FeeRouter | `setAuthorizedCaller(psm, true)` | PSM must call routeToTreasury |

### 3.3 Oracle Configuration

| Step | Call |
|---|---|
| Set PSM oracle | `psm.setOracle(oracleAggregator)` |
| Set initial price | `oracleAggregator.setPriceMock(asset, price, decimals, true)` |
| Optional: staleness threshold | `parameterRegistry.setUint(keccak256("oracle:maxStale"), seconds)` |
| Optional: deviation threshold | `parameterRegistry.setUint(keccak256("oracle:maxDiffBps"), bps)` |

**Critical:** PSM reverts with `PSM_ORACLE_MISSING` if `setOracle` is not called.

### 3.4 PSM Configuration

| Step | Call |
|---|---|
| Set fees | `psm.setFees(mintFeeBps, redeemFeeBps)` — both must be ≤ 10,000 |
| Set limits | `psm.setLimits(psmLimitsAddress)` — optional |
| Token decimals | `parameterRegistry.setUint(keccak256(abi.encode(keccak256("psm:tokenDecimals"), token)), decimals)` — defaults to 18 if unset |

### 3.5 Safety-Automata Setup

| Step | Call |
|---|---|
| Grant guardian role | `safetyAutomata.grantGuardian(guardianAddress)` |
| Wire Guardian contract | `guardian.setSafetyAutomata(safetyAutomata)` |
| Self-register guardian | `guardian.selfRegister()` — calls `safetyAutomata.grantGuardian(guardian)` |
| Grant DAO role | `safetyAutomata.grantRole(keccak256("DAO_ROLE"), daoAddress)` |

### 3.6 BuybackVault Configuration (if deployed)

| Step | Call |
|---|---|
| Fund stable | `buybackVault.fundStable(amount)` — requires prior ERC20 approve |
| Per-op cap | `buybackVault.setMaxBuybackSharePerOpBps(bps)` — 0 = disabled |
| Window cap | `buybackVault.setBuybackWindowConfig(durationSec, capBps)` — 0/0 = disabled |
| Oracle gate | `buybackVault.setOracleHealthGateConfig(oracleWatcher, true)` |
| Strategy | `buybackVault.setStrategy(0, assetAddr, weightBps, true)` |
| Enforce strategies | `buybackVault.setStrategiesEnforced(true)` |

### 3.7 Post-Deployment Verification

Run these checks after deployment to confirm correct wiring:

```
1. PSM.oracle() != address(0)                    → oracle is set
2. oracle.isOperational() == true                 → oracle not paused
3. oneKUSD.isMinter(psm) == true                  → PSM can mint
4. oneKUSD.isBurner(psm) == true                  → PSM can burn
5. vault.isAssetSupported(token) == true           → collateral accepted
6. vault.authorizedCallers(psm) == true            → PSM can deposit/withdraw
7. limits.authorizedCallers(psm) == true           → PSM can update limits
8. safetyAutomata.isPaused(keccak256("PSM")) == false   → PSM not paused
9. safetyAutomata.isPaused(keccak256("VAULT")) == false → vault not paused
10. safetyAutomata.isPaused(keccak256("ORACLE")) == false → oracle not paused
```

Functional smoke test:
```
1. swapTo1kUSD(token, smallAmount, recipient, 0, deadline) → should succeed
2. swapFrom1kUSD(token, smallAmount, recipient, 0, deadline) → should succeed
3. Verify oneKUSD.totalSupply() returned to original after roundtrip
```

---

## 4. File Change Summary

### PR #84 (D1/D2/D3)
| File | Change |
|---|---|
| `contracts/core/PegStabilityModule.sol` | -63 lines: removed `_requireAssetSupported`, `PSM_UNSUPPORTED_ASSET`, 5 dead helpers; +2 lines: fee bounds validation |
| `contracts/mocks/MockVault.sol` | -3 lines: removed `isAssetSupported` |
| `foundry/test/Guardian_PSMUnpause.t.sol` | -1 line: removed `isAssetSupported` from inline mock |
| `foundry/test/mocks/MockCollateralVault.sol` | -4 lines: removed `isAssetSupported` |
| `foundry/test/mocks/MockVault.sol` | -4 lines: removed `isAssetSupported` |
| `foundry/test/psm/PSMRegression_Spreads.t.sol` | -4 lines: removed `isAssetSupported` from inline mock |

### Earlier commit `8fd9869` (retained on main)
| File | Change |
|---|---|
| `contracts/psm/PSMLimits.sol` | +authorizedCallers, onlyAuthorized modifier |
| `contracts/oracle/OracleWatcher.sol` | +ORACLE_MODULE constant, try-catch for isPaused/isOperational |
| `contracts/core/FeeRouter.sol` | +admin, authorizedCallers, constructor(address), onlyAuthorized |
| `contracts/core/PegStabilityModule.sol` | +deadline enforcement, PSM_DEADLINE_EXPIRED error |
| `contracts/core/CollateralVault.sol` | +real deposit/withdraw with SafeERC20, _balances accounting, authorizedCallers |
| `contracts/psm/PSMSwapCore.sol` | +SafeERC20 import, safeTransferFrom |
| `contracts/core/BuybackVault.sol` | Consolidated executeBuyback paths, deduped events, standardized modifiers |
| `contracts/strategy/IBuybackStrategy.sol` | Updated comment reference |
| 8 test/mock files | Updated to match new interfaces |

---

*Report generated: 2026-02-07. All 76 tests passing on commit `1f045a7`.*
