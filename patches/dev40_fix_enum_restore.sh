#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Fix: restore Status enum inside OracleWatcher =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

# 1️⃣ Entferne evtl. alte Enum-Definition außerhalb des Contract-Bereichs
perl -0777 -pe 's/enum\s+Status\s*\{[^}]*\}//g' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 2️⃣ Füge die Enum sauber innerhalb des Contracts ein, direkt nach den Imports und vor den Variablen
awk '
/contract[[:space:]]+OracleWatcher/ {
  print $0
  print ""
  print "    /// @notice Operational state classification"
  print "    enum Status { Healthy, Paused, Stale }"
  next
}
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

forge clean && forge build

mkdir -p logs
printf "%s DEV-40 fix: restored Status enum inside OracleWatcher (build successful)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Enum restored and build successful."
