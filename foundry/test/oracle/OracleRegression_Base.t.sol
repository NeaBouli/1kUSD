// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "contracts/oracle/OracleWatcher.sol";
import "contracts/core/OracleAggregator.sol";
import "contracts/core/SafetyAutomata.sol";

contract OracleRegression_Base is Test {
    OracleWatcher watcher;
    OracleAggregator aggregator;
    SafetyAutomata safety;

    function setUp() public {
        safety = new SafetyAutomata(address(this), 0);
        aggregator = new OracleAggregator(address(this), safety, keccak256("ORACLE"));
        watcher = new OracleWatcher(aggregator, safety);
    }
}
