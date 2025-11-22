#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV58 DOC03: append governance proposal template summary to project.log =="

mkdir -p "$(dirname "$LOG")"

cat <<EOL >> "$LOG"
[DEV-58] $(date -u +"%Y-%m-%dT%H:%M:%SZ") Governance: added psm_parameter_change_template.json and linked it from parameter_playbook + README as canonical proposal format for PSM/Oracle parameter changes.
EOL

echo "✓ DEV-58 governance proposal template summary appended to $LOG"
