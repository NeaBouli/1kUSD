#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Step 3: Connector Variables =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

awk '
/address public immutable deployer;/ {
  print "    IOracleAggregator public oracle;"; 
  print "    address public safetyAutomata;";
  print "";
  print $0;
  next;
}
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

mkdir -p logs
printf "%s DEV-40 step3: added oracle + safetyAutomata connector vars (no builds)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ DEV-40 Step 3 applied – connector variables inserted (no builds)."
