// SPDX-License-Identifier: MIT

// Lightweight mock aggregator to bypass constructor ZERO_ADDRESS checks
contract MockOracleAggregator {
    function updatePrice(address) external {}
    function isHealthy() external pure returns (bool) { return true; }
}


// Inline minimal registry to bypass ZERO_ADDRESS() revert
contract MinimalMockRegistry is IParameterRegistry {
    function getUint(bytes32) external pure returns (uint256) { return 0; }
    function getAddress(bytes32) external pure returns (address) { return address(0xA11CE); }
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
        aggregator = MockOracleAggregator(address(new MockOracleAggregator()));
        watcher = new OracleWatcher(aggregator, safety);
    }
}
