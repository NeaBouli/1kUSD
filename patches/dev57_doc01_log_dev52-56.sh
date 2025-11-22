#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV57 DOC01: append DEV-52/55/56 summaries to project.log =="

mkdir -p "$(dirname "$LOG")"

cat <<EOL >> "$LOG"
[DEV-52] $(date -u +"%Y-%m-%dT%H:%M:%SZ") PSM: registry-driven spreads added on top of mint/redeem fees (global + per-token), stack-too-deep resolved via local reduction; PSMRegression_Spreads covers mint+redeem spreads.
[DEV-55] $(date -u +"%Y-%m-%dT%H:%M:%SZ") Oracle: regression harness cleaned up (OracleRegression_Base with fresh Safety+Registry per test) and watcher refresh semantics aligned with health model; all Oracle regression suites green.
[DEV-56] $(date -u +"%Y-%m-%dT%H:%M:%SZ") Docs: README now links Governance Parameter Playbook, PSM parameter map and Economic Layer docs (decimals/fees/spreads + Oracle health gates) under a dedicated Governance & Parameters section.
EOL

echo "✓ DEV-52/55/56 summaries appended to $LOG"
