
Invariants Harness Notes (v1)
General

Deterministic time — control timestamp advance per step.

Snapshot/rollback — store minimal state deltas to replay failing traces.

Event capture — decode with clients/sdk/events.ts and include in reports.

PSM Paths

Randomize direction, asset, amount within caps/rate limits.

Inject faults: pause, stale oracle, deviation spike, FoT deposit.

Vault Paths

Track balance deltas across assets; verify Deposit/Withdraw parity.

Governance Paths

Random param changes via Timelock mock (respect delays) within safe ranges.

Reporting

On violation: dump JSON with balances, supply, last N events, current params, and oracle snapshot.
