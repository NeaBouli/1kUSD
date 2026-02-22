# Gas/DoS Review Report -- v0.51.x

**Sprint 2 Task 2** | **Reviewer:** Automated Security Review | **Date:** 2026-02-15
**Baseline:** commit `bd74933` (post-PR #89, Sprint 2 Task 1)
**Scope:** Cap logic loops, window accounting storage growth, reentrancy risk validation, authorization gate cost sanity

---

## Contracts Reviewed

| Contract | Lines | Result |
|----------|-------|--------|
| `contracts/core/BuybackVault.sol` | 338 | 2 findings (G1, G2), 1 micro-opt applied (G3) |
| `contracts/psm/PSMLimits.sol` | 60 | Clean |
| `contracts/core/SafetyAutomata.sol` | 59 | Clean |
| `contracts/core/PegStabilityModule.sol` | ~200 | Informational (G8) |
| `contracts/core/CollateralVault.sol` | ~100 | Clean |

---

## Findings

### G1: Unbounded `strategies[]` loop -- FIXED

**Severity:** Medium-DoS
**Location:** `BuybackVault.sol:237-250` -- `_checkStrategyEnforcement()`

```solidity
for (uint256 i = 0; i < strategies.length; i++) {
    StrategyConfig storage cfg = strategies[i];
    if (cfg.enabled && cfg.asset == address(asset)) {
        found = true;
        break;
    }
}
```

**Issue:** `setStrategy()` (line 307) allows `strategies.push()` with no maximum length cap. A compromised or careless DAO could add hundreds of strategies, causing `executeBuybackPSM` to revert at the block gas limit.

**Mitigation in place:** `onlyDAO` restricts both `setStrategy` and `executeBuybackPSM` -- the DAO would be DoS'ing itself. In v0.51.x with a single buyback asset, `strategies.length` is typically 1.

**Fix applied:** Added `MAX_STRATEGIES = 16` constant and `MAX_STRATEGIES_REACHED()` revert in `setStrategy` when pushing beyond the cap. Misconfig test + happy-path test added.

---

### G2: State write before external call -- ACCEPTED RISK

**Severity:** Low (mitigated by `onlyDAO`)
**Location:** `BuybackVault.sol:166-194` -- `executeBuybackPSM()`

**Issue:** `_checkBuybackWindowCap()` writes `buybackWindowAccumulatedBps` (line 227) and window snapshot state (lines 216-218) BEFORE the external PSM call at line 185 (`psm.swapFrom1kUSD(...)`). This is a Checks-Effects-Interactions (CEI) pattern concern.

**Mitigation in place:** `onlyDAO` modifier ensures only the DAO multisig can invoke this function. Reentrancy from an untrusted caller is impossible. The PSM itself uses `nonReentrant` on its swap functions.

**Decision:** Accepted risk. `onlyDAO` is sufficient mitigation for v0.51.x. Adding `nonReentrant` would cost ~5,000 gas per call for a theoretical attack requiring DAO key compromise + malicious PSM. Revisit if BuybackVault gains permissionless callers.

---

### G3: Redundant `stable.balanceOf()` calls -- FIXED

**Severity:** Info (gas)
**Location:** `BuybackVault.sol:175,200,209`

**Issue:** `executeBuybackPSM` reads `stable.balanceOf(address(this))` at line 175. `_checkPerOpTreasuryCap` read it again (same value, no state change between calls). `_checkBuybackWindowCap` read it again on window reset (same value). Three STATICCALL operations for an identical value.

**Fix applied:** Pass cached `bal` from `executeBuybackPSM` to both internal functions. Saves 2 redundant STATICCALL operations (~400 gas per buyback). Internal-only signature change, zero external behavior change. Verified by 39 BuybackVault tests (34 unit + 5 invariant, 256 runs x 64 depth).

---

### G4: Storage layout -- No action

**Severity:** Info
**Location:** `BuybackVault.sol:70-93`

Storage is already well-packed into 4 non-immutable slots:

| Slot | Variables | Bytes used |
|------|-----------|------------|
| 0 | `strategies[]` (array pointer) | 32/32 |
| 1 | `strategiesEnforced` + `maxBuybackSharePerOpBps` + `oracleHealthModule` + `oracleHealthGateEnforced` + `maxBuybackSharePerWindowBps` | 26/32 |
| 2 | `buybackWindowDuration` + `buybackWindowStart` + `buybackWindowAccumulatedBps` | 32/32 |
| 3 | `buybackWindowStartStableBalance` | 32/32 |

No reordering can reduce slot count. Slot 1 has 6 bytes free but no variable to fill it without breaking packing of slot 2.

---

### G5: Authorization gate cost -- No action

**Severity:** Info
**Location:** `BuybackVault.sol:96-104`

- `onlyDAO`: Single `msg.sender` comparison -- O(1), ~200 gas
- `notPaused`: Single EXTCALL to `safety.isPaused(moduleId)` -- O(1), ~2,600 gas (warm)

Both are minimal and appropriate.

---

### G6: PSMLimits -- No action

**Severity:** Info
**Location:** `contracts/psm/PSMLimits.sol`

60-line contract with O(1) operations only. `checkAndUpdate` is a single comparison + addition + SSTORE. Day boundary reset is a timestamp comparison. No loops, no dynamic arrays, no DoS vectors.

---

### G7: SafetyAutomata -- No action

**Severity:** Info
**Location:** `contracts/core/SafetyAutomata.sol`

59-line contract using OpenZeppelin `AccessControl`. All operations are O(1) mapping lookups. `pauseModule`/`resumeModule` are single SSTORE operations. Guardian sunset check is a timestamp comparison. No loops, no DoS vectors.

---

### G8: PSM registry lookup cascade -- No action

**Severity:** Info
**Location:** `contracts/core/PegStabilityModule.sol`

Each swap performs 4-6 `registry.getUint()` calls (token decimals, fee overrides, spread parameters). Each is an EXTCALL + SLOAD (~2,600 gas warm). Total registry cost per swap: ~10,000-15,000 gas.

This is architectural -- the ParameterRegistry design enables DAO governance over parameters without contract upgrades. Optimizing this would require caching patterns that change the interface or add complexity beyond v0.51.x scope.

---

## Summary

| Finding | Severity | Status |
|---------|----------|--------|
| G1: Unbounded strategies loop | Medium-DoS | Fixed -- `MAX_STRATEGIES = 16` cap added |
| G2: CEI pattern concern | Low | Accepted risk -- mitigated by `onlyDAO` |
| G3: Redundant balanceOf calls | Info | Fixed (micro-optimization) |
| G4: Storage layout | Info | Already optimal |
| G5: Auth gate cost | Info | Already optimal |
| G6: PSMLimits | Info | Clean |
| G7: SafetyAutomata | Info | Clean |
| G8: PSM registry cascade | Info | Architectural -- no action |

**Gas optimization applied:** ~400 gas saved per `executeBuybackPSM` call via `balanceOf` caching.

**Escalation resolution:**
1. G1: Fixed -- `MAX_STRATEGIES = 16` constant + `MAX_STRATEGIES_REACHED()` revert in `setStrategy`
2. G2: Accepted risk -- `onlyDAO` modifier is sufficient mitigation for v0.51.x; revisit if BuybackVault gains permissionless callers
