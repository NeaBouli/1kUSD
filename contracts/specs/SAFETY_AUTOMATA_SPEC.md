# Safety-Automata — Functional Specification

**Scope:** Central policy enforcement for pausing/resuming modules, setting caps and rate limits, and guarding oracle-dependent actions.  
**Status:** Spec (no code). **Language:** EN.

---

## 1. Goals & Non-Goals
- **Goals:** Single control-plane for: `pause/resume(module)`, `setCap(target,key,value)`, `setRateLimit(target,windowSec,maxAmount)`, readonly policy checks for oracles. No asset custody. Immutable audit trail via events.
- **Non-goals:** Moving funds; direct mint/burn; governance decision-making (delegated to DAO/Timelock).

## 2. Actors & AuthZ
- **DAO/Timelock Executor**: ultimate authority for parameter changes; binds roles.
- **Guardian (Temporary, Sunset)**: can only `pause(module)` and **cannot** move funds; expires automatically at `sunsetTs`.
- **Public Users**: no write access; read policy state.
- **Modules**: PSM, Vault, AutoConverter, Oracle, Treasury read safety state.

AuthZ model:
- `ROLE_PAUSE`: Guardian (+ DAO executor).  
- `ROLE_PARAMS`: DAO executor only.  
- `ROLE_RESUME`: DAO executor only (Guardian cannot resume).  

## 3. State & Parameters
- `paused[moduleId: bytes32] -> bool`
- `caps[target: bytes32][key: bytes32] -> uint256`  (e.g., target="PSM", key=asset)
- `rateLimit[target] -> { windowSec:uint256, maxAmount:uint256, rolling:uint256, lastUpdate:uint256 }`
- `oracleGuards[asset] -> { maxDeviationBps:uint256, maxAgeSec:uint256 }` (authoritative copy; OracleAggregator enforces liveness, Safety checks thresholding)
- `guardianSunsetTs:uint256`

## 4. Interfaces
- `pause(moduleId: bytes32, reason: string)` — requires `ROLE_PAUSE`. Idempotent.
- `resume(moduleId: bytes32)` — requires `ROLE_RESUME`.
- `setCap(target: bytes32, key: bytes32, value: uint256)` — requires `ROLE_PARAMS`.
- `setRateLimit(target: bytes32, windowSec: uint256, maxAmount: uint256)` — requires `ROLE_PARAMS`.
- `setOracleGuards(asset: address, maxDeviationBps: uint256, maxAgeSec: uint256)` — requires `ROLE_PARAMS`.
- `isPaused(moduleId) -> bool` (view)
- `getCap(target,key) -> uint256` (view)
- `getRateLimit(target) -> (windowSec,maxAmount,rolling,lastUpdate)` (view)
- `getOracleGuards(asset) -> (maxDeviationBps,maxAgeSec)` (view)

**Hooks (read-only) consumed by modules:**
- `assertRateLimit(target, deltaAmount)` — pure/view guidance; modules must enforce locally (PSM calls before swap).
- `assertOracle(asset, price, lastUpdateTs)` — modules call with oracle snapshot; Safety evaluates guards.

## 5. State Machine
Per `moduleId`: `Active` ↔ `Paused`.
- **Pause:** Guardian or DAO can pause; emits `ModulePaused(moduleId, actor, reason, ts)`.
- **Resume:** only DAO executor; emits `ModuleResumed(moduleId, actor, ts)`.
- **Guardian Sunset:** if `block.timestamp >= guardianSunsetTs`, `pause()` from Guardian reverts `GUARDIAN_EXPIRED`.

## 6. Policy Tables (Examples)
| Policy                      | Target       | Set By   | Enforced In     |
|----------------------------|--------------|----------|-----------------|
| PSM Exposure Cap           | PSM/asset    | DAO      | PSM (swap path) |
| PSM Global Rate Limit      | PSM (global) | DAO      | PSM (swap path) |
| Oracle Deviation/Max Age   | asset        | DAO      | PSM/Converter   |
| Vault Withdraw Pause       | Vault        | Guardian/DAO | Vault         |
| AutoConverter Pause        | Converter    | Guardian/DAO | Converter     |

## 7. Events (must match ONCHAIN_EVENTS.md)
- `ModulePaused(module (indexed) string, actor (indexed) address, reason string, ts uint256)`
- `ModuleResumed(module (indexed) string, actor (indexed) address, ts uint256)`
- `CapSet(target (indexed) string, key (indexed) bytes32, value uint256, ts uint256)`
- `RateLimitSet(target (indexed) string, windowSec uint256, maxAmount uint256, ts uint256)`
- `EmergencyTriggered(module (indexed) string, actor (indexed) address, details string, ts uint256)`

## 8. Error Conditions
- `UNAUTHORIZED_ROLE`
- `MODULE_ALREADY_PAUSED` / `MODULE_NOT_PAUSED`
- `GUARDIAN_EXPIRED`
- `INVALID_PARAMS` (e.g., zero windowSec or inconsistencies)

## 9. Interactions & Ordering
- Modules must call safety assertions **before** state changes with external effects.
- Safety changes (caps/limits) are effective immediately after `Timelock.execute()`.

## 10. Incident Runbook (High-level)
1. **Detect**: Monitoring flags oracle stale / peg drift / abnormal flow.
2. **Mitigate**: Guardian pauses affected module(s) (if before sunset) — else DAO executes pause via Timelock fast-track if configured.
3. **Diagnose**: Root-cause analysis; oracle feeds checked; indexer confirms reserves.
4. **Remediate**: DAO adjusts caps/limits/feeds via proposals.
5. **Resume**: DAO resumes module(s); communicate via release notes.

## 11. Threat Model (Summary)
- **Reentrancy**: Safety has no external token calls; modules must be nonReentrant.
- **Key misuse**: Guardian limited to `pause` only; sunset prevents long-term risk.
- **Governance capture**: Timelock delay; multi-sig executor; on-chain transparency.
- **Oracle manipulation**: deviation/age guards; multi-source median in OracleAggregator.
