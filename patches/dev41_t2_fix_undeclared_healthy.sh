#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T2: Fix undeclared identifier 'healthy' & split chained assignment =="

cp -n "$FILE" "${FILE}.bak" || true

awk '
  {
    line=$0

    # 1) Replace the undeclared identifier usage:
    #    assertFalse(healthy, "...")  ->  assertFalse(watcher.isHealthy(), "...")
    gsub(/assertFalse\(healthy, "watcher should detect pause"\);/,
         "assertFalse(watcher.isHealthy(), \"watcher should detect pause\");", line)

    # 2) Split chained assignment that may cause a type mismatch:
    #    aggregator = registry = IParameterRegistry(address(0));
    # -> registry = IParameterRegistry(address(0));
    #    // aggregator wird direkt darunter ohnehin neu erstellt
    if (line ~ /aggregator[[:space:]]*=[[:space:]]*registry[[:space:]]*=[[:space:]]*IParameterRegistry\(address\(0\)\);/) {
      print "        registry = IParameterRegistry(address(0));"
      next
    }

    print line
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# Quick sanity check: braces still balanced?
opens=$(grep -o '{' "$FILE" | wc -l | tr -d ' ')
closes=$(grep -o '}' "$FILE" | wc -l | tr -d ' ')
echo "Braces => {:$opens }:$closes"
[ "$opens" -eq "$closes" ] || { echo "ERROR: Unbalanced braces!"; exit 1; }

echo "✅ Patch applied."
