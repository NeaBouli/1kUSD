# ADR-040: OracleWatcher – Health & State Projection Layer (Scaffold)

**Status:** Draft (Scaffold committed)  
**Context:** DEV-40 starts a thin projection layer on top of OracleAggregator to expose a stable, cache-friendly health signal for off-chain consumers (bots, dashboards, monitors).

## Decision
- Introduce `contracts/oracle/OracleWatcher.sol` (stub).
- Keep interface stable (`isHealthy()`), fill logic in small steps.

## Consequences
- No behavior change today.
- Next steps: wire to SafetyAutomata/OracleAggregator; add stale checks; minimal tests.

