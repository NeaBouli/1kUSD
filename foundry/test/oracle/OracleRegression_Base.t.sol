// SPDX-License-Identifier: MIT

// Typed mock derived from OracleAggregator to satisfy type system
contract MockOracleAggregator is OracleAggregator {
    constructor() OracleAggregator(address(0xDEAD), ISafetyAutomata(address(0xBEEF)), IParameterRegistry(address(0xA11CE))) {}
    function updatePrice(address) external{}
    function isHealthy() external pure returns (bool) { return true; }
}


// Lightweight mock aggregator to bypass constructor ZERO_ADDRESS checks


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
        OracleAggregator mockAgg = new MockOracleAggregator();
        aggregator = mockAgg;
        watcher = new OracleWatcher(aggregator, safety);
    }
}
