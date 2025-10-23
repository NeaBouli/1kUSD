# Emergency Drills (v1)
**Status:** Runbook. **Language:** EN.

## Objectives
- Validate pause/unpause via SafetyAutomata (through Timelock) across all modules.
- Validate oracle outage and deviation handling without fund movement.
- Validate parameter changes flow (fee/caps) through Timelock -> Registry -> Modules.

## Scenarios
1) **Global Pause/Resume**
   - Queue `SafetyAutomata.pause(MODULE_ID)` for PSM and VAULT.
   - Verify: swaps/deposits revert with `PAUSED`.
   - Queue `unpause(...)`; verify state changes allowed again.

2) **Oracle Outage**
   - On staging: set Oracle mock `healthy=false` for USDC.
   - Verify: PSM quotes remain read-only; swaps remain NOT_IMPLEMENTED at this stage.
   - Later: ensure PSM swap guards prevent execution when unhealthy.

3) **Deviation Spike**
   - On staging: set `PARAM_ORACLE_MAX_DEVIATION_BPS` to a low value via Timelock.
   - Verify: guarded paths detect deviation and block economic actions.

4) **Rate-Limit/Caps (future when implemented)**
   - Increase traffic in fuzz/sim; verify sliding window enforcement and per-asset caps.

## Evidence Checklist
- CI artifacts attached to release candidate.
- On-chain events captured (Paused/Unpaused/Param Set).
- CHANGELOG updated with drill outcomes and mitigations (if any).

## Communication
- Pre-announce drill window and impact scope (staging/testnet).
- Post-mortem doc within 48h, linked from CHANGELOG.
