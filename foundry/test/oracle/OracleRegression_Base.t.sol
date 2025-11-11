// SPDX-License-Identifier: MIT

// Inline minimal registry to bypass ZERO_ADDRESS() revert
contract MinimalMockRegistry is IParameterRegistry {
    function getParam(bytes32) external pure returns (uint256) { return 0; }
    function admin() external pure returns (address) { return address(0xA11CE); }
}

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
        registry = IParameterRegistry(address(new MinimalMockRegistry()));
        aggregator = new OracleAggregator(address(0xCAFE), safety, registry);
        watcher = new OracleWatcher(address(0xD00D), aggregator, safety);
    }
}
