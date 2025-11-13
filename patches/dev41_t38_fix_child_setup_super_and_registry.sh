#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Watcher.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T38: Fix child test setUp() to call super and use mock registry =="

cp -n "$FILE" "${FILE}.bak.t38" || true

awk '
  BEGIN {replaced=0}
  {
    if ($0 ~ /function setUp\(\)/ && !replaced) {
      print $0
      print "        super.setUp();"
      print "        // --- DEV-41-T38: use initialized mocks instead of zero address ---"
      print "        watcher = new OracleWatcher(aggregator, safety);"
      replaced=1
      skip=1
      next
    }
    if (skip && $0 !~ /}/) next
    else if (skip && $0 ~ /}/) { skip=0; next }
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Child test now calls super.setUp() and no longer passes ZERO_ADDRESS registry."
