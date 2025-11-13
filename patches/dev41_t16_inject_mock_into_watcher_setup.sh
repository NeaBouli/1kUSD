#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T16: Inject instantiated MockOracleAggregator into OracleWatcher setup =="

cp -n "$FILE" "${FILE}.bak.t16" || true

awk '
  {
    # 1️⃣ Ersetze alle Aggregator-Initialisierungen mit dem Mock
    gsub(/OracleAggregator\(address\(0xCAFE\), safety, registry\)/, "MockOracleAggregator()")

    # 2️⃣ Füge vor Watcher-Erzeugung sicherheitshalber eine Instanz-Zuweisung hinzu
    if ($0 ~ /new OracleWatcher/) {
      print "        OracleAggregator mockAgg = new MockOracleAggregator();"
      print "        aggregator = mockAgg;"
    }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ MockOracleAggregator instance now properly injected into OracleWatcher setup."
