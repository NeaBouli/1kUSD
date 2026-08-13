# Guardian Safety Rules (Spec v0.1)

**Goal:** Centralize system-wide pause/unpause control for PSM and Vault.

## Roles
- `GUARDIAN_ROLE` → temporary emergency authority (time-limited)
- `ADMIN_ROLE` / `DAO_ROLE` → permanent DAO/Timelock authority

## Core Rules
- Guardian may call `pause()` before the configured sunset timestamp.
- Guardian cannot resume modules, either before or after sunset.
- Guardian authority expires at `block.timestamp >= guardianSunset`.
- DAO/Timelock may always pause or resume modules.
- If an account has both a permanent role and `GUARDIAN_ROLE`, its permanent
  authority takes precedence and remains valid after sunset.

## Security
- Each pause/unpause emits `SystemPaused` or `SystemResumed`.
- No fund movement allowed while paused.
- Guardian cannot mint, burn, or withdraw.
