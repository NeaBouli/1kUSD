#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Header Rebuild: restore OracleWatcher contract header =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# Sicherung anlegen
cp "$FILE" "${FILE}.bak"

# Neuer vollständiger Header (ersetzt alles oberhalb der ersten Funktion)
awk '
/function getStatus/ && !header_done {
  print "pragma solidity ^0.8.30;"
  print ""
  print "import { IOracleWatcher } from \"../interfaces/IOracleWatcher.sol\";"
  print "import { IOracleAggregator } from \"../interfaces/IOracleAggregator.sol\";"
  print "import { ISafetyAutomata } from \"../interfaces/ISafetyAutomata.sol\";"
  print ""
  print "/// @title OracleWatcher"
  print "/// @notice Monitors Oracle and SafetyAutomata states"
  print "contract OracleWatcher is IOracleWatcher {"
  print ""
  print "    /// @notice Operational state classification"
  print "    enum Status { Healthy, Paused, Stale }"
  print ""
  print "    struct HealthState {"
  print "        Status status;"
  print "        uint256 lastUpdate;"
  print "        bool cached;"
  print "    }"
  print ""
  print "    IOracleAggregator public oracle;"
  print "    ISafetyAutomata public safetyAutomata;"
  print "    HealthState private _health;"
  print ""
  header_done=1
}
{ print }
END {
  print "}"
}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: rebuilt OracleWatcher header + restored enum/struct/vars (build ok)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ OracleWatcher header rebuilt and build successful."
