# Guardian Sunset Checklist (v1)
**Status:** Docs. **Language:** EN.

## Purpose
Define a clear, auditable path to decommission the temporary emergency guardian and hand off all controls to DAO Timelock.

## Preconditions
- ✅ All core modules deployed and wired to `DAOTimelock` as `admin`.
- ✅ ParameterRegistry keys populated via queued+executed Timelock ops.
- ✅ SafetyAutomata pause tested (pause/unpause) across modules in staging.
- ✅ OracleAggregator has no dev-only mocks on mainnet (or they are gated off).
- ✅ Incident runbooks rehearsed (see `ops/runbooks/EMERGENCY_DRILLS.md`).

## Sunset Steps
1. **Freeze Guardian Powers (staging first):**
   - Disable any direct guardian ownerships; ensure only Timelock retains admin role.
   - Verify: `admin` of Token/PSM/Vault/Oracle/Safety/Registry == `DAOTimelock`.
2. **Set Sunset Block/Timestamp:**
   - Publish exact block/timestamp and rationale in CHANGELOG.
   - Queue Timelock transaction that revokes remaining guardian permissions at T+Δ.
3. **Dry-Run Rehearsal:**
   - Simulate emergency pause/unpause via Timelock delay (no guardian).
   - Verify no hidden code paths rely on guardian.
4. **Execute Sunset:**
   - Execute queued revocations.
   - Confirm events and on-chain state: no guardian privileges remain.
5. **Post-Sunset Monitoring:**
   - Heightened monitoring for 7 days; verify no elevated error rates or failed governance actions.

## Evidence to Archive
- Timelock tx hashes (queue/execute).
- Module `AdminChanged` events (admin -> Timelock).
- Screenshots/logs from dry-run and post-sunset monitoring.

## Rollback (if needed)
- Only via Timelock: queue temporary emergency policy (short-lived), with public disclosure and new sunset date.
