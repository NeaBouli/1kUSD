# Known Limitations -- v0.51.x

---

## L1: BuybackVault CEI Pattern (G2 -- Accepted Risk)

**Location:** `BuybackVault.sol:211-229` -- `_checkBuybackWindowCap()`

**Issue:** `_checkBuybackWindowCap()` writes `buybackWindowAccumulatedBps`, `buybackWindowStart`, and `buybackWindowStartStableBalance` BEFORE the external `psm.swapFrom1kUSD()` call at line 188. This violates the Checks-Effects-Interactions pattern.

**Mitigation:** `onlyDAO` modifier ensures only the DAO multisig can invoke `executeBuybackPSM`. Reentrancy from an untrusted caller is impossible. The PSM itself uses `nonReentrant` on its swap functions.

**Residual risk:** Requires DAO key compromise AND a malicious PSM replacement to exploit. Adding `nonReentrant` would cost ~5,000 gas per call for a theoretical attack path.

**Decision:** Accepted for v0.51.x. Revisit if BuybackVault gains permissionless callers.

---

## L2: PSM Registry Lookup Cascade (G8 -- Architectural)

**Location:** `PegStabilityModule.sol` -- `_getMintFeeBps`, `_getRedeemFeeBps`, `_getMintSpreadBps`, `_getRedeemSpreadBps`, `_getTokenDecimals`

**Issue:** Each swap performs 4-6 `registry.getUint()` EXTCALL + SLOAD operations for token decimals, fee overrides, and spread parameters. Total registry cost per swap: ~10,000-15,000 gas.

**Mitigation:** None. This is architectural -- the ParameterRegistry design enables DAO governance over parameters without contract upgrades.

**Impact:** Gas overhead, not a security concern. Optimizing requires caching patterns that would add complexity beyond v0.51.x scope.

---

## L3: FeeRouterV2 Stub (No Real Fee Routing)

**Location:** `contracts/router/FeeRouterV2.sol`

**Issue:** The PSM calls `feeRouter.route(moduleId, token, amount)` for fee routing, but the FeeRouterV2 implementation is a stub that only emits events. No tokens are actually transferred to the treasury.

**Current behavior:** `psm.feeRouter()` defaults to `address(0)`, making fee routing a complete no-op. Fees are computed and deducted from the user's output but not collected or routed anywhere. In the mint path, fee1k worth of 1kUSD is simply not minted. In the redeem path, fee1k worth of collateral remains in the vault.

**Impact:** No protocol revenue collection in v0.51.x. Fees effectively improve the collateral ratio rather than funding operations.

**v0.52+ item:** Implement a real IFeeRouterV2 that transfers fee tokens to TreasuryVault.

---

## L4: PSMSwapCore Legacy Contract

**Location:** `contracts/psm/PSMSwapCore.sol`

**Issue:** PSMSwapCore is a separate, older swap implementation that coexists with the canonical PegStabilityModule. If accidentally deployed and wired instead of PegStabilityModule, swaps would bypass: spreads, oracle health checks, deadline enforcement, and the ParameterRegistry fee cascade.

**Mitigation:** Deployment checklist specifies PegStabilityModule as the canonical PSM. PSMSwapCore should not be deployed.

**v0.52+ item:** Mark as deprecated or remove from the codebase.

---

## L5: DAOTimelock Skeleton

**Location:** `contracts/core/DAO_Timelock.sol`

**Issue:** `execute()` reverts with `NOT_IMPLEMENTED`. The contract can queue and cancel operations via events, but cannot actually execute any on-chain actions.

**Impact:** No enforced timelock on governance actions in v0.51.x. Admin changes take effect immediately.

**v0.52+ item:** Implement real execution logic with configurable delay.

---

## L6: OneKUSD Unchecked Addition (B1)

**Location:** `OneKUSD.sol:243-246` -- `_transfer()`

```solidity
unchecked {
    _balances[from] = bal - amount;
    _balances[to] += amount;     // unchecked addition
}
```

**Issue:** `_balances[to] += amount` in an `unchecked` block could theoretically overflow if a single address accumulates 2^256 tokens.

**Practical risk:** Zero. `_totalSupply` is bounded by the sum of all mints, which are controlled by the PSM. Reaching 2^256 on a single address is computationally infeasible.

**v0.52+ item:** If refactoring OneKUSD, move addition outside `unchecked`.

---

## L7: CollateralVault No ReentrancyGuard

**Location:** `CollateralVault.sol`

**Issue:** The vault's `withdraw()` function calls `IERC20(asset).safeTransfer()` which could invoke a callback on a malicious token contract. The vault has no `ReentrancyGuard`.

**Mitigation:** (1) Only PSM can call `withdraw()` via `onlyAuthorized`, and PSM has `nonReentrant`. (2) Only admin-whitelisted assets are accepted via `onlySupported`. (3) Balance is decremented before the transfer (partial CEI compliance).

**Residual risk:** If a whitelisted token has a transfer callback, the callback could re-enter other vault functions. However, the attacker would need to be an authorized caller (PSM or admin) to invoke any state-changing vault function.

**v0.52+ item:** Add ReentrancyGuard as defense-in-depth.

---

## L8: ParameterRegistry No Value Validation

**Location:** `ParameterRegistry.sol:48-61`

**Issue:** `setUint()`, `setAddress()`, `setBool()` accept any value with no range checks. Admin can set `oracle:maxStale` to 1 second (making all prices stale), or fee BPS to any uint256 (though consumers validate `<= 10_000`).

**Mitigation:** Consumer contracts validate parameter values when reading: PSM requires `feeBps <= 10_000`, `tokenDecimals <= 255`. Oracle parameters have no consumer-side validation (0 = disabled).

**Residual risk:** Admin can set parameters that cause protocol dysfunction (e.g., `maxStale = 1` blocks all swaps). This is by design -- ParameterRegistry is explicitly a "no validations" skeleton (DEV37).

**v0.52+ item:** Add optional range constraints per key.

---

## L9: No Fee-on-Transfer Token Support

**Location:** `CollateralVault.sol:116-125` -- `deposit()`

**Issue:** `deposit()` records `amount` in `_balances[asset]` without measuring the actual received amount (`balanceAfter - balanceBefore`). For fee-on-transfer tokens, the recorded balance exceeds the actual held balance.

**Impact:** Over time, `_balances[asset] > IERC20(asset).balanceOf(vault)`. Redeems will eventually fail with `INSUFFICIENT_VAULT_BALANCE` when the vault tries to transfer more than it holds.

**Mitigation:** Only standard ERC-20 tokens should be whitelisted via `setAssetSupported()`. Deployment checklist and documentation specify this requirement.

**v0.52+ item:** Implement received-amount accounting (`balanceAfter - balanceBefore`).

---

## L10: PSMLimits Has No Events

**Location:** `PSMLimits.sol`

**Issue:** The contract emits zero events. Daily volume updates, cap changes, day boundary resets, and authorized caller changes are all invisible to off-chain monitoring.

**Impact:** Off-chain monitoring must poll `dailyVolumeView()` and `lastDay()` to track limit state. Cap changes via `setLimits()` cannot be detected without transaction tracing.

**v0.52+ item:** Add events for `LimitsUpdated(daily, single)`, `VolumeUpdated(amount, dailyTotal)`, `DayReset(oldDay, newDay)`, `AuthorizedCallerSet(caller, bool)`.

---

## L11: Single-Step Admin Transfer

**Location:** All contracts with `setAdmin(address)` pattern

**Issue:** Admin transfer is a single-step operation. If the admin accidentally sets `newAdmin` to an incorrect address (e.g., zero -- though most check for this, or a typo), admin access is permanently lost.

**Contracts affected:** CollateralVault, OracleAggregator, ParameterRegistry, FeeRouter, OneKUSD.

**Mitigation:** All contracts validate `newAdmin != address(0)`. No protection against setting admin to a valid but uncontrolled address.

**v0.52+ item:** Implement two-step transfer pattern (`proposeAdmin` + `acceptAdmin`).

---

## L12: FeeRouterV2 Stub Has No Access Control

**Location:** `FeeRouterV2.sol:9`

**Issue:** `route(key, token, amount)` is public with no access control. Any caller can invoke it.

**Impact:** None in v0.51.x -- the stub only emits events and moves no tokens. If replaced with a real implementation that transfers tokens, access control would be required.

---

## v0.52+ Roadmap Summary

| Item | Description | Priority |
|------|-------------|----------|
| FeeRouterV2 implementation | Real fee routing to TreasuryVault | High |
| Received-amount vault accounting | FoT token support | Medium |
| ParameterRegistry value validation | Range constraints per key | Medium |
| Two-step admin transfer | Prevent accidental admin loss | Medium |
| CollateralVault ReentrancyGuard | Defense-in-depth | Low |
| PSMLimits events | Off-chain monitoring | Low |
| PSMSwapCore deprecation/removal | Codebase cleanup | Low |
| DAOTimelock real execution | Governance enforcement | High |
| BuybackVault nonReentrant (if permissionless) | Only if callers change | Conditional |
