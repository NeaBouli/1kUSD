
Guardian Sunset — Rehearsal Runbook (v1)

Status: Ops doc.

Purpose

Ensure temporary Guardian (pause-only) cannot act after sunset timestamp and that DAO retains full control.

Preconditions

PARAM_GUARDIAN_SUNSET_TS configured in registry

Safety-Automata checks guardian expiry on pause()

Steps

Read current PARAM_GUARDIAN_SUNSET_TS and block.timestamp.

Before sunset:

Trigger pause(moduleId) via Guardian → expect success, events emitted.

Unpause via DAO path (Timelock) → expect success.

After sunset:

Attempt pause(moduleId) via Guardian → expect revert GUARDIAN_EXPIRED.

DAO can still pause/resume via Timelock.

Log all tx hashes; attach to release notes.

Exit Criteria

Guardian cannot pause after sunset

DAO pause/resume unaffected

Indexer captures ModulePaused/Unpaused timeline consistently
