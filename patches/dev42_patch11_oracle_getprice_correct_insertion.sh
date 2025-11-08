#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-42 Patch 11: Verified final insertion of getPrice() inside OracleAggregator =="

# Entferne alte Implementierungen
grep -v "function getPrice" contracts/core/OracleAggregator.sol > contracts/core/OracleAggregator.tmp
mv contracts/core/OracleAggregator.tmp contracts/core/OracleAggregator.sol

# Entferne evtl. doppelte leere Klammern am Dateiende
sed -i '' -e '${/^}$/!b;N;/\n}$/d;}' contracts/core/OracleAggregator.sol || true

# Füge Block exakt vor der allerletzten geschlossenen Contract-Klammer ein
awk '
/^}/ && !done {
    print "    /// @inheritdoc IOracleAggregator";
    print "    function getPrice(address asset) external view override returns (Price memory p) {";
    print "        return _mockPrice[asset];";
    print "    }";
    print "";
    print "}";
    done=1;
    next;
}
{ print }
' contracts/core/OracleAggregator.sol > contracts/core/OracleAggregator.tmp && mv contracts/core/OracleAggregator.tmp contracts/core/OracleAggregator.sol

echo "✅ getPrice() block inserted cleanly inside OracleAggregator body."
