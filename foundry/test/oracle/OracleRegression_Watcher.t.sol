// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "contracts/oracle/OracleWatcher.sol";
import "contracts/core/SafetyAutomata.sol";
import "contracts/core/OracleAggregator.sol";
import "contracts/interfaces/IParameterRegistry.sol";
import "./OracleRegression_Base.t.sol";
contract OracleRegression_Watcher is OracleRegression_Base {
    OracleWatcher watcher;
    event HealthUpdated(IOracleWatcher.Status status, uint256 timestamp);
    function setUp() public override {
        super.setUp();
        // --- DEV-41-T38: use initialized mocks instead of zero address ---
        watcher = new OracleWatcher(aggregator, safety);
    /// @notice Verify default health state after deployment
    }
    function testInitialHealthIsHealthy() public {
        bool healthy = watcher.isHealthy();
        assertTrue(healthy, "initial watcher health should be true");
    }
    /// @notice Verify paused propagation from SafetyAutomata
    function testPausePropagation() public {
        // Simulate SafetyAutomata returning paused
        vm.mockCall(
            address(safety),
            abi.encodeWithSignature("isPaused(uint8)", 1),
            abi.encode(true)
        );
        vm.expectEmit(true, true, false, true);
        emit HealthUpdated(IOracleWatcher.Status.Paused, block.timestamp);
        watcher.updateHealth();
        assertFalse(watcher.isHealthy(), "watcher should detect pause");
    }
    /// @notice Verify manual refresh triggers same logic
    function testRefreshAlias() public {
        watcher.refreshState();
        assertTrue(watcher.isHealthy(), "refreshState should not alter state");
    }
}
