#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-41 Init: create oracle regression test skeleton =="

mkdir -p foundry/test/oracle

cat <<'EOT' > foundry/test/oracle/OracleRegression_Base.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../../contracts/oracle/OracleWatcher.sol";
import "../../contracts/core/OracleAggregator.sol";
import "../../contracts/core/SafetyAutomata.sol";

contract OracleRegression_Base is Test {
    OracleWatcher watcher;
    OracleAggregator aggregator;
    SafetyAutomata safety;

    function setUp() public {
        safety = new SafetyAutomata(address(this), 0);
        aggregator = new OracleAggregator(address(this), safety);
        watcher = new OracleWatcher(aggregator, safety);
    }
}
EOT

echo "✅ Oracle regression suite skeleton created."
