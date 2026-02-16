# Protocol Invariants -- v0.51.x

This document consolidates all invariants from specifications, economic analysis, and Foundry fuzz/invariant tests into a single reference for auditors.

---

## Economic Invariants (E1--E7)

Source: [`audit/ECONOMIC_MODEL.md`](ECONOMIC_MODEL.md), [`docs/specs/PSM_LIMITS_AND_INVARIANTS.md`](../docs/specs/PSM_LIMITS_AND_INVARIANTS.md)

### E1: Supply Conservation

```
1kUSD.totalSupply() == sum(mints via PSM) - sum(burns via PSM)
```

No free minting exists. Every `totalSupply` increase passes through `swapTo1kUSD` which requires a collateral deposit. Every decrease passes through `swapFrom1kUSD` which burns the full input amount.

### E2: Collateral Backing

```
vault.balanceOf(asset) >= sum(deposits[asset]) - sum(withdrawals[asset])
```

Per-asset accounting. The vault tracks `_balances[asset]` internally. The only withdrawal path is via authorized callers (PSM, admin). Note: this invariant breaks for fee-on-transfer tokens (see KNOWN_LIMITATIONS.md L9).

### E3: Fee Bounds

```
fee + spread <= 10,000 bps
```

Enforced per swap in `PegStabilityModule._computeFeeAndSpread()`. Both `mintFeeBps` and `mintSpreadBps` (and their redeem counterparts) are capped at 10,000 individually. Combined cap prevents > 100% total deduction.

### E4: Rate Limit -- Daily Volume

```
PSMLimits.dailyVolume <= PSMLimits.dailyCap
```

Enforced in `PSMLimits._checkAndUpdate()`. On each swap, `dailyVolume + amount` must not exceed `dailyCap`. Day boundary reset occurs when `block.timestamp / 1 days` changes.

### E5: Rate Limit -- Single Transaction

```
amount <= PSMLimits.singleTxCap
```

Enforced per swap. Prevents large single-transaction drains even within daily cap.

### E6: Buyback Per-Op Cap

```
stableIn <= (stableBalance * maxBuybackSharePerOpBps) / 10,000
```

Enforced in `BuybackVault._checkBuybackTreasuryCap()`. Limits how much of the vault balance a single buyback can spend.

### E7: Buyback Window Cap

```
buybackWindowAccumulatedBps <= maxBuybackSharePerWindowBps
```

Enforced in `BuybackVault._checkBuybackWindowCap()`. Rolling window (configurable duration) limits cumulative buyback as a fraction of the starting window balance. Uses ceiling division BPS.

---

## Safety Invariants (S1--S5)

Source: [`audit/ARCHITECTURE_OVERVIEW.md`](ARCHITECTURE_OVERVIEW.md), contract analysis

### S1: Pause Blocks State Changes

When `SafetyAutomata.isPaused(moduleId) == true`, no state-changing operations succeed on the corresponding module:
- PSM: `swapTo1kUSD` and `swapFrom1kUSD` revert with `PausedError()`
- CollateralVault: `deposit` and `withdraw` revert with `PAUSED()`
- OneKUSD: `transfer`, `mint`, `burn` revert with `PAUSED()`
- BuybackVault: `executeBuybackPSM` reverts with `PAUSED()`

### S2: Guardian Sunset Enforcement

```
block.timestamp > guardianSunset => guardian cannot call pauseModule()
```

After the sunset timestamp, `SafetyAutomata.pauseModule()` reverts with `GuardianExpired()` when called by the guardian. Admin/DAO retain pause authority indefinitely.

### S3: No Reentrancy on PSM Swaps

`PegStabilityModule` inherits OpenZeppelin `ReentrancyGuard`. Both `swapTo1kUSD` and `swapFrom1kUSD` use the `nonReentrant` modifier. No nested swap execution is possible.

### S4: Authorized Caller Enforcement

Critical state changes are restricted to whitelisted callers:
- `CollateralVault.withdraw()` -- `onlyAuthorized` (PSM, admin)
- `PSMLimits._checkAndUpdate()` -- `onlyAuthorized` (PSM)
- `FeeRouter.route()` -- `onlyAuthorized` (PSM)
- `OneKUSD.mint()` / `burn()` -- `onlyMinter` / `onlyBurner` (PSM)

### S5: Oracle Health Gate

BuybackVault enforces oracle health before execution:
```
oracleHealthEnforced == true => oracleHealthModule.isHealthy() must return true
```

If the oracle is unhealthy, `executeBuybackPSM` reverts with `BUYBACK_ORACLE_UNHEALTHY()`.

---

## Foundry Invariant Tests (F1--F13)

Source: `foundry/test/*_Invariant.t.sol` | Config: 256 runs, 64 depth

### BuybackVault (5 invariants)

**F1: `invariant_windowAccumulatedBpsNeverExceedsCap`**
```
vault.buybackWindowAccumulatedBps() <= vault.maxBuybackSharePerWindowBps()
```
Verifies E7 holds after arbitrary sequences of fund/withdraw/buyback operations.

**F2: `invariant_stableBalanceAccounting`**
```
stable.balanceOf(vault) == ghost_totalFunded - ghost_totalWithdrawn - ghost_totalBuybacksSpent
```
Ghost-tracked accounting: every token entering/leaving the vault is accounted for exactly.

**F3: `invariant_totalOutflowBounded`**
```
ghost_totalFunded >= ghost_totalWithdrawn + ghost_totalBuybacksSpent
```
Outflow can never exceed inflow. The vault cannot distribute more tokens than it received.

**F4: `invariant_perOpCapBounded`**
```
vault.maxBuybackSharePerOpBps() <= 10,000
```
Per-operation cap BPS is always a valid percentage.

**F5: `invariant_windowCapBounded`**
```
vault.maxBuybackSharePerWindowBps() <= 10,000
```
Window cap BPS is always a valid percentage.

### PSMLimits (4 invariants)

**F6: `invariant_dailyVolumeNeverExceedsCap`**
```
limits.dailyVolume() <= limits.dailyCap()
```
Verifies E4 holds after arbitrary sequences of swaps and day boundary crossings.

**F7: `invariant_singleCapLeDailyCap`**
```
limits.singleTxCap() <= limits.dailyCap()
```
Configuration invariant: single-tx cap is always bounded by the daily cap.

**F8: `invariant_lastUpdatedDayNotInFuture`**
```
limits.lastUpdatedDay() <= block.timestamp / 1 days
```
The day counter never advances past the current day.

**F9: `invariant_volumeConsistency`**
```
limits.dailyVolume() <= limits.dailyCap()
```
Redundant safety assertion (same as F6, guards against state corruption).

### SafetyAutomata (4 invariants)

**F10: `invariant_pausedAndEnabledComplementary`**
```
isPaused(module) != isModuleEnabled(module)    // for all tracked modules
```
Paused and enabled states are always complementary. A module is never both paused and enabled, nor neither.

**F11: `invariant_ghostMatchesOnChain`**
```
safety.isPaused(module) == handler.ghost_paused(module)    // for all modules
```
Ghost state in the fuzz handler always matches actual on-chain state, verifying no state desynchronization after arbitrary pause/resume sequences.

**F12: `invariant_noGuardianPauseAfterSunset`**
```
handler.ghost_guardianPausedAfterSunset() == 0
```
Verifies S2: the fuzz handler tracks guardian pause attempts after sunset. The count must always be zero (all such attempts must revert).

**F13: `invariant_unpausedModulesAreEnabled`**
```
!safety.isPaused(module) => safety.isModuleEnabled(module) == true
```
Unpaused modules always report as enabled. Redundant with F10 but explicitly tests the `isModuleEnabled` view function.

---

## Specification Invariants (P1--P10)

Source: [`docs/specs/PSM_LIMITS_AND_INVARIANTS.md`](../docs/specs/PSM_LIMITS_AND_INVARIANTS.md), protocol specifications

### P1: Reserve Backing

```
stableReserves >= collateralValue
```

The total stable reserves must always cover or exceed the collateral value. In v0.51.x with 1:1 pegged stables, this simplifies to: vault balance >= outstanding 1kUSD supply.

### P2: No Free Mint

Every mint requires an approved stable deposit reaching the vault. There is no `mint()` callable without a corresponding `safeTransferFrom` of collateral.

### P3: No Unauthorized Burn

Burns occur only through PSM redeem (`swapFrom1kUSD`) or authorized protocol modules. The `onlyBurner` role gate on `OneKUSD.burn()` enforces this.

### P4: Atomicity

Each swap uses a single coherent oracle snapshot. No mixed feeds mid-call. The PSM reads oracle state once at the beginning of the swap and uses it throughout.

### P5: Event Consistency -- Swap Events

For every successful swap, exactly one of `SwapTo1kUSD` or `SwapFrom1kUSD` is emitted with correct parameters.

### P6: Event Consistency -- Fee Accounting

```
amountIn = amountOut + fee    (normalized to 18 decimals, +/- 1 wei rounding)
```

The `fee1k` and `net1k` / `netTokenOut` fields in swap events always satisfy conservation.

### P7: Rounding Direction

Fee computation truncates (rounds down). Net output truncates (rounds down). The protocol never underpays itself by more than 1 wei per swap. Rounding always favors the protocol.

### P8: CEI Compliance

Checks-Effects-Interactions order is maintained in all PSM operations. State updates precede external calls. Exception: BuybackVault (see KNOWN_LIMITATIONS.md L1, mitigated by `onlyDAO`).

### P9: No Direct Vault Withdrawal

No direct vault withdrawals except via PSM redeem or admin/DAO emergency actions. The `onlyAuthorized` modifier on `CollateralVault.withdraw()` enforces this.

### P10: Parameter Governance

Parameter changes only via `ParameterRegistry` (admin/DAO controlled). Runtime parameter reads by consumers do not modify state.

---

## Invariant Coverage Matrix

| Invariant | Specified | Fuzz Tested | Test ID |
|-----------|-----------|-------------|---------|
| Supply conservation | E1, P2, P3 | -- | (verified via regression tests) |
| Collateral backing | E2, P1 | -- | (verified via regression tests) |
| Fee bounds | E3 | -- | PSM_Config tests |
| Daily volume cap | E4 | Yes | F6, F9 |
| Single-tx cap | E5 | Yes | F7 |
| Buyback per-op cap | E6 | Yes | F4 |
| Buyback window cap | E7 | Yes | F1, F5 |
| Balance accounting | -- | Yes | F2, F3 |
| Pause blocks state | S1 | -- | SafetyAutomata_Config tests |
| Guardian sunset | S2 | Yes | F12 |
| No reentrancy | S3 | -- | (structural: nonReentrant modifier) |
| Authorized callers | S4 | -- | Auth test suites |
| Oracle health gate | S5 | -- | BuybackVault unit tests |
| Pause/enabled complementary | -- | Yes | F10, F13 |
| Ghost state consistency | -- | Yes | F11 |
| Event conservation | P5, P6 | -- | Regression tests |
| Rounding direction | P7 | -- | PSMRegression_Fees tests |
| CEI compliance | P8 | -- | (structural review) |
| No direct vault withdrawal | P9 | -- | CollateralVault_Auth tests |
| Parameter governance | P10 | -- | ParameterRegistry_Config tests |

---

## Auditor Notes

1. **F6 and F9 are intentionally duplicated** -- defense-in-depth against fuzz harness bugs.
2. **F10 and F13 test the same property** from different angles (negation vs implication).
3. **E1 (supply conservation) is not fuzz-tested** due to the complexity of wiring a full PSM + Vault + Token setup in an invariant handler. It is verified by 19 regression tests covering mint/redeem flows.
4. **Oracle invariants (staleness, deviation)** are tested in `OracleRegression_Health.t.sol` but not in invariant/fuzz tests. The mock oracle in v0.51.x does not support fuzz-driven price feeds.
5. **The BuybackVault CEI exception (P8)** is documented in KNOWN_LIMITATIONS.md L1. The `onlyDAO` modifier makes the non-CEI pattern unexploitable without admin key compromise.
