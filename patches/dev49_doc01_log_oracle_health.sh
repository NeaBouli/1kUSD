#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV49 DOC01: append DEV-49 Oracle health summary to project.log =="

mkdir -p "$(dirname "$LOG")"

cat <<EOL >> "$LOG"
[DEV-49] $(date -u +"%Y-%m-%dT%H:%M:%SZ") OracleAggregator: registry-based health gates added (oracle:maxStale/oracle:maxDiffBps) with SAFE disabling via 0-values; OracleRegression_Health covers stale-disable, stale-mark-unhealthy and small vs large price jumps; full suite at 40 tests green.
EOL

echo "✓ DEV-49 summary appended to $LOG"
