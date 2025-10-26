# Safety & Guardian Layer (DEV-5)

**Components**
- **SafetyNet**: Event hub for alerts (no state changes besides roles). Indexer-friendly.
- **GuardianMonitor**: Deterministic rule checks (deviation / staleness) → requests `SafetyAutomata.pause()`.

**Rules**
- R1: Deviation (|price - 1.0| in BPS) > `maxDeviationBps` → pause.
- R2: Staleness (`now - lastUpdated`) > `maxStalenessSec` → pause.

**Roles**
- DAO/Owner configures rules; GuardianMonitor must have `GUARDIAN` in SafetyAutomata.

**Events**
- `AlertRaised`, `RuleUpdated`, `OracleChecked`, `PauseRequested`.

**Notes**
- No custody. Fail-closed escalation to pause. All calls are to fixed, known contracts.
