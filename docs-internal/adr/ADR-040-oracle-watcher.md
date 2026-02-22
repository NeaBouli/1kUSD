# ADR-040: OracleWatcher – Health & State Projection Layer (Scaffold)

**Status:** Draft (Scaffold committed)  
**Context:** DEV-40 starts a thin projection layer on top of OracleAggregator to expose a stable, cache-friendly health signal for off-chain consumers (bots, dashboards, monitors).

## Decision
- Introduce `contracts/oracle/OracleWatcher.sol` (stub).
- Keep interface stable (`isHealthy()`), fill logic in small steps.

## Consequences

## Implementation Notes (Phase 1-2)

- OracleWatcher scaffold, wiring, and neutral health view complete.
- Added connector variables (oracle, safetyAutomata) and constructor wiring.
- Introduced HealthState struct and Status enum.
- Added functional skeleton methods (updateHealth, refreshState).
- Implemented neutral read-only accessors:
  - isHealthy() → returns true until cache active
  - getStatus(), lastUpdate(), hasCache()

Next: Phase 3 will implement actual binding logic to OracleAggregator and SafetyAutomata.
- No behavior change today.
- Next steps: wire to SafetyAutomata/OracleAggregator; add stale checks; minimal tests.

