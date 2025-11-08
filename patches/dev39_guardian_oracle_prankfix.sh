#!/usr/bin/env bash
set -euo pipefail

TEST="foundry/test/Guardian_OraclePropagation.t.sol"
BACKUP="$TEST.bak"

echo "== DEV-39: FINAL-FINAL PATCH (Safety-first constructor + full MockRegistry) =="

if [ -f "$TEST" ]; then
  cp "$TEST" "$BACKUP"
  echo "Backup created: $BACKUP"
fi

cat > "$TEST" <<"EOL"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {Guardian} from "../../contracts/security/Guardian.sol";
import {ISafetyAutomata} from "../../contracts/interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../../contracts/interfaces/IParameterRegistry.sol";
import {OracleAggregator} from "../../contracts/core/OracleAggregator.sol";

/// @dev Full mock implementation for IParameterRegistry
contract MockRegistry is IParameterRegistry {
    mapping(bytes32 => uint256) private uintStore;
    mapping(bytes32 => address) private addressStore;

    function setUint(bytes32 key, uint256 value) external {
        uintStore[key] = value;
    }

    function setAddress(bytes32 key, address value) external {
        addressStore[key] = value;
    }

    function getUint(bytes32 key) external view override returns (uint256) {
        return uintStore[key];
    }

    function getAddress(bytes32 key) external view override returns (address) {
        return addressStore[key];
    }
}

contract Guardian_OraclePropagationTest is Test {
    address dao;
    SafetyAutomata safety;
    Guardian guardian;
    OracleAggregator oracle;
    MockRegistry registry;

    bytes32 internal constant ORACLE = keccak256("ORACLE");

    function setUp() public {
        dao = makeAddr("dao");

        // unified prank scope
        vm.startPrank(dao);
        safety = new SafetyAutomata(dao, 1_000_000);
        guardian = new Guardian(dao, 1_000_000);
        guardian.setSafetyAutomata(safety);
        safety.grantGuardian(address(guardian));

        // full mock registry
        registry = new MockRegistry();

        // ✅ Correct constructor order: safety, registry, admin
        oracle = new OracleAggregator(
            ISafetyAutomata(address(safety)),
            IParameterRegistry(address(registry)),
            dao
        );

        vm.stopPrank();
    }

    function testInitialOperationalState() public view {
        bool paused = safety.isPaused(ORACLE);
        bool operational = oracle.isOperational();
        assertFalse(paused, "SafetyAutomata should not be paused initially");
        assertTrue(operational, "Oracle should be operational initially");
    }

    function testPausePropagationStopsOracle() public {
        vm.prank(dao);
        safety.pauseModule(ORACLE);
        assertTrue(safety.isPaused(ORACLE), "Module should be paused");
        assertFalse(oracle.isOperational(), "Oracle must stop when paused");
    }

    function testResumeRestoresOperation() public {
        vm.startPrank(dao);
        safety.pauseModule(ORACLE);
        safety.unpauseModule(ORACLE);
        vm.stopPrank();

        assertFalse(safety.isPaused(ORACLE), "Module should be unpaused");
        assertTrue(oracle.isOperational(), "Oracle must resume when unpaused");
    }
}
EOL

echo "✓ DEV-39 final-final patch written successfully."
echo "== Running Foundry tests =="
forge clean && forge test --match-path "$TEST" -vv
