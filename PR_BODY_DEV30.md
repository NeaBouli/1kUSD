# DEV-30 – PSM Limits & Invariants (v0.36)

**Scope**
- `PSMLimits` module with `maxSingleSwap`, `maxDailySwap`, `dailyVolume`, day reset
- Internal `_updateVolume(amount)` with single/daily cap enforcement
- Swap-core integration: call `_updateVolume(amountIn)` before execution
- Tests: single cap, daily cap, daily reset, DAO guard on setLimits

**Notes**
- Limits are unit-agnostic; choose values consistent with collateral units
- Defaults set in constructor; adjustable via `setLimits()`

**Release:** v0.36 — PSM safety caps online
