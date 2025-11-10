#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Step 6: Internal State Struct + Flags =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

awk '
/IOracleAggregator public oracle;/ {
  print $0
  print ""
  print "    /// @notice Possible states derived from OracleAggregator and SafetyAutomata."
  print "    enum Status { Healthy, Paused, Stale }"
  print ""
  print "    struct HealthState {"
  print "        Status status;"
  print "        uint256 lastUpdate;"
  print "        bool cached;"
  print "    }"
  print ""
  print "    HealthState internal _health;"
  next
}
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

mkdir -p logs
printf "%s DEV-40 step6: added internal HealthState struct + Status enum (no builds)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ DEV-40 Step 6 applied – internal state struct + flags added (no builds)."
