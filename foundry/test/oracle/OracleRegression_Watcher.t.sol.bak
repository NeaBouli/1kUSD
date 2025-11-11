// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "contracts/oracle/OracleWatcher.sol";
import "contracts/core/SafetyAutomata.sol";
import "contracts/core/OracleAggregator.sol";

contract OracleRegression_Watcher is Test {
    OracleWatcher watcher;
    SafetyAutomata safety;
    OracleAggregator aggregator;

    event HealthUpdated(IOracleWatcher.Status status, uint256 timestamp);

    function setUp() public {
        safety = new SafetyAutomata(address(this), 0);
        aggregator = new OracleAggregator(address(this), safety, keccak256("ORACLE"));
        watcher = new OracleWatcher(aggregator, safety);
    }

    /// @notice Verify default health state after deployment
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

        bool healthy = watcher.isHealthy();
        assertFalse(healthy, "watcher should detect pause");
    }

    /// @notice Verify manual refresh triggers same logic
    function testRefreshAlias() public {
        watcher.refreshState();
        assertTrue(watcher.isHealthy(), "refreshState should not alter state");
    }
}
