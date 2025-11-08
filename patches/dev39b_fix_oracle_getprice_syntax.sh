#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-39B: Fix OracleAggregator.getPrice() syntax =="

FILE="contracts/core/OracleAggregator.sol"
TMP="${FILE}.tmp"

awk '
/^contract /      { in_contract=1 }
in_contract && /function getPrice/ { in_func=1 }
in_func && /return _mockPrice/     { print "    return _mockPrice[asset];"; next }
in_func && /^}/                    { in_func=0 }
{ print }
' "$FILE" > "$TMP"

mv "$TMP" "$FILE"

forge build

mkdir -p logs
printf "%s DEV-39B syntax fix applied by Fix-Dev-39 [getPrice()] [syntax restore]\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
