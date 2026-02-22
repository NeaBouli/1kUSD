# Guardian Sunset Hooks (Design Notes)
**Status:** Docs. **Language:** EN.

## Goal
Make the guardian strictly temporary and auditable. After sunset:
- Guardian can no longer pause modules.
- Only DAO/Timelock can change parameters or pause/unpause.

## Mechanisms (options)
1. **Timestamp gate** in SafetyAutomata:
   - `guardianSunsetTs` immutable (or set-once).
   - `if (msg.sender == guardian && block.timestamp >= guardianSunsetTs) revert GUARDIAN_EXPIRED();`
2. **Role drop via Timelock**:
   - Timelock executes `setGuardian(address(0))` at sunset.
3. **Circuit preference**:
   - Permit guardian to only `pause` (never `unpause`), even before sunset.
   - Unpause must go through Timelock to ensure transparency.

## Events
- `GuardianSet(old, new, sunsetTs)`
- `GuardianSunsetExecuted(ts)`

## Ops Checklist
- Announce sunset date/time in CHANGELOG.
- Dry-run on staging (see `ops/runbooks/EMERGENCY_DRILLS.md`).
- Archive Timelock tx hashes and module admin states.
