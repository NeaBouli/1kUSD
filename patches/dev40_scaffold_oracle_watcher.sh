#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40: Scaffold OracleWatcher =="

# 1) Minimaler Contract-Skeleton (keine Logik, keine externen Abhängigkeiten, build-neutral)
mkdir -p contracts/oracle
cat > contracts/oracle/OracleWatcher.sol <<'SRC'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title OracleWatcher (DEV-40 Scaffold)
/// @notice Lightweight watcher stub that will subscribe to OracleAggregator state
///         and expose a clean "healthy / paused / stale" view for off-chain consumers.
/// @dev Implementation will be added in DEV-40 steps without changing this interface.
interface IOracleWatcher {
    /// @notice Returns true if the oracle path is considered operational.
    function isHealthy() external view returns (bool);
}

contract OracleWatcher is IOracleWatcher {
    // Placeholder: will be wired to OracleAggregator in subsequent steps
    address public immutable deployer;

    constructor() {
        deployer = msg.sender;
    }

    /// @inheritdoc IOracleWatcher
    function isHealthy() external pure returns (bool) {
        // Stub: will read from OracleAggregator / SafetyAutomata later
        return true;
    }
}
SRC

# 2) ADR/Report-Stub
mkdir -p docs/adr
cat > docs/adr/ADR-040-oracle-watcher.md <<'DOC'
# ADR-040: OracleWatcher – Health & State Projection Layer (Scaffold)

**Status:** Draft (Scaffold committed)  
**Context:** DEV-40 starts a thin projection layer on top of OracleAggregator to expose a stable, cache-friendly health signal for off-chain consumers (bots, dashboards, monitors).

## Decision
- Introduce `contracts/oracle/OracleWatcher.sol` (stub).
- Keep interface stable (`isHealthy()`), fill logic in small steps.

## Consequences
- No behavior change today.
- Next steps: wire to SafetyAutomata/OracleAggregator; add stale checks; minimal tests.

DOC

# 3) Kurz-Log (UTC)
mkdir -p logs
printf "%s DEV-40 scaffold: OracleWatcher stub + ADR-040 added [DEV-6A]\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ DEV-40 scaffold applied (no builds triggered)."
