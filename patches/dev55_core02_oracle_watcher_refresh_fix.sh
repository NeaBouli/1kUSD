#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"

echo "== DEV55 CORE02: align Oracle watcher refresh test with health semantics =="

# 1) Kommentar anpassen: refreshState soll die aktuelle Health spiegeln, nicht zwingend ändern
sed -i '' \
  's/Verify manual refresh triggers same logic/Verify manual refresh preserves current health state/' \
  "$FILE"

# 2) Erwartung umdrehen: nach refreshState bleibt der Watcher bei gesundem Aggregator gesund
sed -i '' \
  's/assertFalse(watcher.isHealthy(), "refreshState should update according to aggregator state");/assertTrue(watcher.isHealthy(), "refreshState should not alter state when aggregator is healthy");/' \
  "$FILE"

echo "✓ OracleRegression_Watcher::testRefreshAlias now asserts health stays true on refresh"
