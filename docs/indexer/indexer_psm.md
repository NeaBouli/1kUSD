# PSM indexer guide

This document describes how an indexer can
track PegStabilityModule (PSM) activity for the 1kUSD system.
## OracleRequired telemetry (Phase B preview)

This document is part of the OracleRequired observability effort
(DEV-11 Phase B). Indexers SHOULD treat oracle-related failures as
first-class signals, not as generic errors.

### PSM_ORACLE_MISSING

When PSM operations revert with the `PSM_ORACLE_MISSING` reason:

- Decode the revert reason and store it explicitly, e.g.:
  - `reason_code = "PSM_ORACLE_MISSING"`
  - `oracle_required_blocked = true`
- Derive metrics such as:
  - count of `PSM_ORACLE_MISSING` events per time window,
  - per-caller / per-route breakdowns (where applicable).
- Use these metrics as inputs for dashboards and alerts, so that:
  - running the PSM without a valid oracle pricefeed is visible
    immediately,
  - governance / operations can correlate incidents with config changes.

### PSM_DEADLINE_EXPIRED

When PSM swap operations revert with the `PSM_DEADLINE_EXPIRED` reason
(`block.timestamp > deadline`; opt-out with `deadline=0`): **(v0.51.x normative)**

- Decode the revert reason and store it explicitly, e.g.:
  - `reason_code = "PSM_DEADLINE_EXPIRED"`
  - `deadline_expired = true`
- Derive metrics such as:
  - count of `PSM_DEADLINE_EXPIRED` events per time window,
  - per-caller breakdowns (to identify callers with consistently tight deadlines),
  - distribution of deadline deltas (`block.timestamp - deadline`) where traceable.
- Use these metrics as inputs for dashboards and alerts, so that:
  - patterns of expired deadlines (e.g., chain congestion, keeper misconfiguration)
    are visible immediately,
  - governance / operations can distinguish deadline failures from oracle or
    slippage failures in incident triage.

### References

- `DEV11_PhaseB_Telemetry_TestPlan_r1.md`
- `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`
- `docs/integrations/index.md` (OracleRequired telemetry section)

