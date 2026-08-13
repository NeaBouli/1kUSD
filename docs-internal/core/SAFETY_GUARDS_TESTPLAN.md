
Safety Guards — Test Plan (v1)

Status: Spec. Language: EN.

Scope

Rate-limit (sliding window) across modules and global scope

Pause/Resume semantics per module via SafetyAutomata

Guardian sunset: Guardian-only can pause until sunsetTs; at/after sunset only
permanent ADMIN/DAO authority may pause

Pass Criteria

No state-changing op succeeds when paused

Rate-limit enforces cumulative gross within window

After sunsetTs, guardian actions revert GUARDIAN_EXPIRED
