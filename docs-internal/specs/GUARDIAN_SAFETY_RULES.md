# Guardian Safety Rules (Spec v0.1)

**Goal:** Centralize system-wide pause/unpause control for PSM and Vault.

## Roles
- `GUARDIAN_ROLE` → temporary emergency authority (time-limited)
- `DAO_ROLE` → permanent governance owner

## Core Rules
- Guardian may call `pause()` and `unpause()` on any Pausable module.
- Guardian authority expires automatically after sunset block (set by DAO).
- DAO may always override or renew Guardian.

## Security
- Each pause/unpause emits `SystemPaused` or `SystemResumed`.
- No fund movement allowed while paused.
- Guardian cannot mint, burn, or withdraw.
