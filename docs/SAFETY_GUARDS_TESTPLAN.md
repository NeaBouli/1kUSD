
Safety Guards — Test Plan (v1)

Status: Spec. Language: EN.

Scope

Rate-limit (sliding window) across modules and global scope

Pause/Resume semantics per module via SafetyAutomata

Guardian sunset: guardian can pause until sunsetTs; after that only DAO may pause

Pass Criteria

No state-changing op succeeds when paused

Rate-limit enforces cumulative gross within window

After sunsetTs, guardian actions revert GUARDIAN_EXPIRED
