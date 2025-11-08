#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-42 Patch 7: Implement OracleAggregator.getPrice() =="

awk '
/function isOperational\(\)/ {
    print;
    print "";
    print "    /// @inheritdoc IOracleAggregator";
    print "    function getPrice(address asset) external view override returns (Price memory p) {";
    print "        return _mockPrice[asset];";
    print "    }";
    next
}1
' contracts/core/OracleAggregator.sol > contracts/core/OracleAggregator.tmp && mv contracts/core/OracleAggregator.tmp contracts/core/OracleAggregator.sol

echo "✅ Added getPrice() implementation to OracleAggregator.sol"
