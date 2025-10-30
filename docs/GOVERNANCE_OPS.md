# Governance Ops (Runbook)

**Scope:** Operational procedures for parameter changes via Timelock/DAO, incident handling with a pause-only Guardian, and rollback discipline. No direct control over user funds.

## 1. Roles
- **DAO / TimelockController:** Sole executor of parameter changes and upgrades (min. 72h delay).
- **Guardian (sunset):** *pause-only* authority; no parameter writes, no upgrades, no fund movement.
- **Operators:** Prepare proposals and simulations; cannot bypass the Timelock.

## 2. Standard Change Procedure
1) **Pre-check:** Validate key, type, bounds in `GOVERNANCE_PARAM_WRITES.md`. Run local simulation (no mainnet state change).  
2) **Proposal:** Encode function + args; queue with `eta >= now + 72h`.  
3) **Queue:** No overlapping writes to the same key during the waiting period.  
4) **Pre-exec guards:** System not paused (unless intended), invariants passing, fresh oracle state.  
5) **Execute:** Timelock executes; verify emitted events and read-back getters.  
6) **Record:** Append to `docs/logs/CHANGE_RECORD.md` and `logs/project.log` (block/tx, before/after, proposer).

## 3. Rollback
- Prefer **inverse parameter write** via Timelock (same process).  
- Emergency only: `pause()` → diagnose → fix via proposal → `unpause()` after invariants return green.

## 4. Incident Flow
Alarm → assign Incident Commander → Guardian `pause()` (if truly needed) → root-cause analysis (Oracle/PSM/Vault/Safety) → proposal(s) → execute after delay → verify → `unpause()`.

## 5. Read-Back (examples)
- PSM: `getFeeInBps()`, `priceBand()`, `mintLimitDaily()`  
- Vault: `assets(token).balance`, `sweepThreshold(token)`  
- Oracle: `medianPrice()`, `minAnswers()`, `heartbeatSec()`  
- Safety: `circuitBreakerLevel()`, `killSwitchArmed()`

## 6. Guardian Limits & Sunset
Guardian may **only** pause (and optionally unpause per policy). Sunset date is mandatory; extension requires a DAO decision.

## 7. Audit Trail
Every change must be documented with function signature, args, before/after values, block/tx, and responsible role. No silent changes.
