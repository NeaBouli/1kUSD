// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "contracts/oracle/OracleWatcher.sol";
import "contracts/core/OracleAggregator.sol";
import "contracts/mocks/MockParameterRegistry.sol";
import "contracts/core/SafetyAutomata.sol";

contract OracleRegression_Base is Test {
    OracleWatcher watcher;
    OracleAggregator aggregator;
    MockParameterRegistry registry;
    SafetyAutomata safety;

    function setUp() public {
        safety = new SafetyAutomata(address(this), 0);
        aggregator = registry = new MockParameterRegistry();
        aggregator = new OracleAggregator(address(this), safety, registry);;
        watcher = new OracleWatcher(aggregator, safety);
    }
}
