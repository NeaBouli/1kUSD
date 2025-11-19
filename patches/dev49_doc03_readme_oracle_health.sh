#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV49 DOC03: append Oracle health summary to README =="

cat <<'EOL' >> "$FILE"

### Oracle Layer (DEV-49 – Health Gates)

The OracleAggregator now applies registry-driven health gates:

- **Staleness thresholds** via `oracle:maxStale` (seconds):
  - `0` disables stale checks,
  - `> 0` marks prices older than the threshold as unhealthy.
- **Diff thresholds** via `oracle:maxDiffBps` (basis points):
  - `0` disables diff checks,
  - `> 0` marks large jumps (relative to the previous price) as unhealthy.

These parameters are configured via the same `ParameterRegistry` used by the PSM.  
OracleRegression_Health.t.sol verifies that:
- disabling thresholds with `0` behaves as a no-op,
- stale prices are correctly downgraded,
- small moves remain healthy while large jumps are flagged.

Combined with SafetyAutomata pause/resume gating and the OracleWatcher,  
the price feed is now guarded against both operational failures and pathological market inputs.
EOL

echo "✓ Oracle health summary appended to $FILE"
