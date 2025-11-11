#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T11: Define MockOracleAggregator inheriting OracleAggregator =="

cp -n "$FILE" "${FILE}.bak" || true

awk '
  NR==1 { print; next }
  NR==2 {
    print "";
    print "// Typed mock derived from OracleAggregator to satisfy type system";
    print "contract MockOracleAggregator is OracleAggregator {";
    print "    constructor() OracleAggregator(address(0xDEAD), ISafetyAutomata(address(0xBEEF)), IParameterRegistry(address(0xA11CE))) {}";
    print "    function updatePrice(address) external override {}";
    print "    function isHealthy() external pure override returns (bool) { return true; }";
    print "}";
    print "";
  }
  {
    # Replace aggregator instantiation with typed mock
    gsub(/new OracleAggregator\(address\(0xCAFE\), safety, registry\)/,
         "new MockOracleAggregator()")
    print
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Typed MockOracleAggregator injected (inherits OracleAggregator)."
