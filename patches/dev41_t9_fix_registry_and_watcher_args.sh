#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T9: Complete MinimalMockRegistry + correct OracleWatcher args =="

cp -n "$FILE" "${FILE}.bak" || true

awk '
  BEGIN {in_contract=0}
  /contract MinimalMockRegistry/ {in_contract=1}
  {
    if (in_contract && /}/) {
      print "    function getUint(bytes32) external pure returns (uint256) { return 0; }"
      print "    function getAddress(bytes32) external pure returns (address) { return address(0xA11CE); }"
      in_contract=0
    }
    # remove any 3-arg watcher calls
    gsub(/new OracleWatcher\(address\(0xD00D\), aggregator, safety\)/,
         "new OracleWatcher(aggregator, safety)")
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Registry completed & watcher args corrected."
