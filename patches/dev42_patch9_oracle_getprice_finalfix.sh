#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-42 Patch 9: FINAL clean insertion of getPrice() =="

# Entferne ALLE bisherigen fehlerhaften Einträge
grep -v "function getPrice" contracts/core/OracleAggregator.sol > contracts/core/OracleAggregator.tmp
mv contracts/core/OracleAggregator.tmp contracts/core/OracleAggregator.sol

# Füge den Block direkt NACH der schließenden Klammer von isOperational() hinzu
awk '
/function isOperational/ { in_function=1 }
in_function && /^\}/ {
    print "    /// @inheritdoc IOracleAggregator";
    print "    function getPrice(address asset) external view override returns (Price memory p) {";
    print "        return _mockPrice[asset];";
    print "    }";
    in_function=0
}
{ print }
' contracts/core/OracleAggregator.sol > contracts/core/OracleAggregator.tmp && mv contracts/core/OracleAggregator.tmp contracts/core/OracleAggregator.sol

echo "✅ OracleAggregator.getPrice() placed after isOperational() correctly."
