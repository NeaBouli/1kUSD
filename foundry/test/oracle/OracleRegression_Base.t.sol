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
import "contracts/core/ParameterRegistry.sol";
import "contracts/interfaces/IParameterRegistry.sol";
import "contracts/interfaces/ISafetyAutomata.sol";
import "contracts/core/SafetyAutomata.sol";
contract OracleRegression_Base is Test {
    OracleWatcher watcher;
    OracleAggregator aggregator;
    IParameterRegistry registry;
    ISafetyAutomata safety;
    function setUp() public {
        // --- DEV-41-T25 injection: ensure mockSafety and mockRegistry initialized ---
        if (address(mockSafety) == address(0)) mockSafety = new SafetyAutomata(address(this), 0);
        if (address(mockRegistry) == address(0)) mockRegistry = new ParameterRegistry(address(this));
        safety = mockSafety;
        registry = mockRegistry;
        // Reordered: declare mocks before assignment
        SafetyAutomata mockSafety = new SafetyAutomata(address(this), 0);
        ParameterRegistry mockRegistry = new ParameterRegistry(address(this));
        safety = mockSafety;
        registry = mockRegistry;
        OracleAggregator mockAgg = new MockOracleAggregator();
        aggregator = mockAgg;
        aggregator = mockAgg;
        // Reordered: declare mocks before assignment
    }
}
