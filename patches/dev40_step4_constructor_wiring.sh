#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Step 4: Constructor Wiring =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

awk '
/constructor\(\)/ {
  print "    constructor(address _oracle, address _safetyAutomata) {";
  print "        deployer = msg.sender;";
  print "        oracle = IOracleAggregator(_oracle);";
  print "        safetyAutomata = _safetyAutomata;";
  print "    }";
  in_old=1;
  next;
}
in_old && /^\}/ { in_old=0; next }
!in_old { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

mkdir -p logs
printf "%s DEV-40 step4: constructor wiring for oracle + safetyAutomata added (no builds)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ DEV-40 Step 4 applied – constructor wiring inserted (no builds)."
