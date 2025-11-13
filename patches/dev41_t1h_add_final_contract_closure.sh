#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-41-T1h: add final contract-closing brace to OracleRegression_Watcher.t.sol =="

FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"

# Backup + Append missing closure
cp "$FILE" "${FILE}.bak"
echo "}" >> "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-41-T1h: added final contract-closing brace in OracleRegression_Watcher.t.sol\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Final contract closure added – build should now succeed."
