#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-42 Patch 5: Guardian_OraclePropagation.t.sol =="

cat > foundry/test/Guardian_OraclePropagation.t.sol <<"EOL"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "forge-std/Test.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {Guardian} from "../../contracts/security/Guardian.sol";
import {OracleAggregator} from "../../contracts/core/OracleAggregator.sol";
import {ISafetyAutomata} from "../../contracts/interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../../contracts/interfaces/IParameterRegistry.sol";

contract MockParameterRegistry is IParameterRegistry {
    function getUint(bytes32) external pure returns (uint256) { return 0; }
    function getAddress(bytes32) external pure returns (address) { return address(0); }
}

contract Guardian_OraclePropagationTest is Test {
    SafetyAutomata internal safety;
    Guardian internal guardian;
    OracleAggregator internal oracle;
    MockParameterRegistry internal registry;
    address internal dao = makeAddr("dao");
    address internal guardianOperator = makeAddr("guardianOperator");
    bytes32 internal constant ORACLE_MODULE = keccak256("ORACLE");

    function setUp() public {
        uint256 sunset = block.timestamp + 1_000_000;
        vm.startPrank(dao);
        safety = new SafetyAutomata(dao, sunset);
        guardian = new Guardian(dao, sunset);
        guardian.setSafetyAutomata(safety);
        guardian.setOperator(guardianOperator);
        safety.grantGuardian(address(guardian));
        vm.stopPrank();
        registry = new MockParameterRegistry();
        ISafetyAutomata safetyInterface = ISafetyAutomata(address(safety));
        IParameterRegistry registryInterface = IParameterRegistry(address(registry));
        oracle = new OracleAggregator(dao, safetyInterface, registryInterface);
    }

    function testInitialOperationalState() public {
        assertTrue(oracle.isOperational(), "oracle should start operational");
    }

    function testPausePropagationStopsOracle() public {
        vm.prank(guardianOperator);
        guardian.pauseOracle();
        assertTrue(safety.isPaused(ORACLE_MODULE));
        assertFalse(oracle.isOperational());
    }

    function testResumeRestoresOperation() public {
        vm.prank(guardianOperator);
        guardian.pauseOracle();
        vm.prank(dao);
        guardian.resumeOracle();
        assertFalse(safety.isPaused(ORACLE_MODULE));
        assertTrue(oracle.isOperational());
    }
}
EOL
echo "✅ Guardian_OraclePropagation.t.sol created."
