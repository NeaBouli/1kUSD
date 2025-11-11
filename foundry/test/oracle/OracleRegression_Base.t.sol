// SPDX-License-Identifier: MIT
import "contracts/core/mocks/MockRegistry.sol";
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "contracts/oracle/OracleWatcher.sol";
import "contracts/core/OracleAggregator.sol";
import "contracts/interfaces/IParameterRegistry.sol";
import "contracts/core/SafetyAutomata.sol";
contract OracleRegression_Base is Test {
    OracleWatcher watcher;
    OracleAggregator aggregator;
    IParameterRegistry registry;
    SafetyAutomata safety;
    function setUp() public {
        safety = new SafetyAutomata(address(0xBEEF), 0);
        registry = IParameterRegistry(address(new MockRegistry()));
        aggregator = new OracleAggregator(address(0xCAFE), safety, registry);
        watcher = new OracleWatcher(aggregator, safety);
    }
}
