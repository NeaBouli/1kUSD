# Guardian Sunset Runbook

**Mandate:** `pause()` (and optionally `unpause()` per policy). No parameter writes, no upgrades, no fund movement.

## 1) When to pause
- Critical oracle divergence or stale data
- PSM imbalance / abnormal fees
- Vault anomaly (unexpected outbound)
- Confirmed exploit or invariant breach

## 2) Procedure
1. Assign Incident Commander (IC)
2. Guardian calls `pause()` on affected modules
3. Collect diagnostics: oracles freshness, PSM state, vault balances, safety flags
4. Draft DAO proposal(s) to fix root cause
5. After Timelock delay: execute, verify events + getters
6. If all invariants pass, `unpause()` (per policy)

## 3) Limits & Separation of Duties
- Guardian cannot set params, upgrade, or move funds
- Actions are fully logged and reviewed by DAO

## 4) Sunset Policy
- Guardian role has an explicit expiry (sunset date)
- Extension or renewal requires a DAO proposal

## 5) Pre-GoLive Checklist
- [ ] Pause/unpause events verified
- [ ] Guardian cannot call any write/upgrade/funds functions
- [ ] Timelock flows unaffected by Guardian presence
- [ ] Sunset date recorded in governance docs
