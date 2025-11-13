#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T20: Fix mock constructor args + interface casts =="

cp -n "$FILE" "${FILE}.bak.t20" || true

# Ersetze die defekten Zeilenblock
awk '
  {
    if ($0 ~ /SafetyAutomata mockSafety/) {
      print "        SafetyAutomata mockSafety = new SafetyAutomata(address(this), 0);"
      next
    }
    if ($0 ~ /safety =/) {
      print "        safety = ISafetyAutomata(address(mockSafety));"
      next
    }
    if ($0 ~ /registry =/) {
      print "        registry = IParameterRegistry(address(mockRegistry));"
      next
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Fixed constructor parameters + proper interface casts."
