#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-42 Patch 10: Correct placement of getPrice() inside contract body =="

# Entferne evtl. alte fehlerhafte getPrice()-Definitionen
grep -v "function getPrice" contracts/core/OracleAggregator.sol > contracts/core/OracleAggregator.tmp
mv contracts/core/OracleAggregator.tmp contracts/core/OracleAggregator.sol

# Füge den Block direkt VOR der letzten schließenden Klammer ein
awk '
/^}/ && !done {
    print "    /// @inheritdoc IOracleAggregator";
    print "    function getPrice(address asset) external view override returns (Price memory p) {";
    print "        return _mockPrice[asset];";
    print "    }";
    done=1;
}
{ print }
' contracts/core/OracleAggregator.sol > contracts/core/OracleAggregator.tmp && mv contracts/core/OracleAggregator.tmp contracts/core/OracleAggregator.sol

echo "✅ OracleAggregator.getPrice() now correctly inside contract."
