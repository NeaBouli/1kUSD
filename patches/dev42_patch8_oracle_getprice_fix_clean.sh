#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-42 Patch 8: Clean fix for OracleAggregator.getPrice() =="

# Entferne evtl. doppelte oder fehlerhafte Einträge
grep -v "function getPrice" contracts/core/OracleAggregator.sol > contracts/core/OracleAggregator.tmp

mv contracts/core/OracleAggregator.tmp contracts/core/OracleAggregator.sol

# Füge sauberen Block nach isOperational() hinzu
awk '
/function isOperational/ {
    print;
    print "";
    print "    /// @inheritdoc IOracleAggregator";
    print "    function getPrice(address asset) external view override returns (Price memory p) {";
    print "        return _mockPrice[asset];";
    print "    }";
    next
}1
' contracts/core/OracleAggregator.sol > contracts/core/OracleAggregator.tmp && mv contracts/core/OracleAggregator.tmp contracts/core/OracleAggregator.sol

echo "✅ OracleAggregator.getPrice() inserted cleanly."
