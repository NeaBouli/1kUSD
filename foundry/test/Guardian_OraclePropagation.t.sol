// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "forge-std/Test.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {Guardian} from "../../contracts/security/Guardian.sol";
import {OracleAggregator} from "../../contracts/core/OracleAggregator.sol";
import {ISafetyAutomata} from "../../contracts/interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../../contracts/interfaces/IParameterRegistry.sol";

contract MockParameterRegistry is IParameterRegistry {
    function getUint(bytes32) external pure returns (uint256) {
        return 0;
    }

    function getAddress(bytes32) external pure returns (address) {
        return address(0);
    }
}

contract Guardian_OraclePropagationTest is Test {
    SafetyAutomata internal safety;
    Guardian internal guardian;
    OracleAggregator internal oracle;
    MockParameterRegistry internal registry;
    address internal admin = makeAddr("admin");
    address internal dao = makeAddr("dao");
    address internal guardianOperator = makeAddr("guardianOperator");
    bytes32 internal constant ORACLE_MODULE = keccak256("ORACLE");

    function setUp() public {
        uint256 sunset = block.timestamp + 1_000_000;
        vm.prank(admin);
        safety = new SafetyAutomata(admin, sunset);
        guardian = new Guardian(dao, sunset);

        vm.startPrank(dao);
        guardian.setSafetyAutomata(safety);
        guardian.setOperator(guardianOperator);
        vm.stopPrank();

        vm.startPrank(admin);
        safety.grantGuardian(address(guardian));
        safety.grantRole(safety.DAO_ROLE(), dao);
        vm.stopPrank();

        vm.prank(dao);
        guardian.selfRegister();

        registry = new MockParameterRegistry();
        ISafetyAutomata safetyInterface = ISafetyAutomata(address(safety));
        IParameterRegistry registryInterface = IParameterRegistry(address(registry));
        oracle = new OracleAggregator(dao, safetyInterface, registryInterface);
    }

    function testGuardianHasOnlyTemporaryRole() public view {
        assertTrue(safety.hasGuardianRole(address(guardian)));
        assertFalse(safety.hasRole(safety.ADMIN_ROLE(), address(guardian)));
        assertFalse(safety.hasRole(safety.DAO_ROLE(), address(guardian)));
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
        safety.resumeModule(ORACLE_MODULE);

        assertFalse(safety.isPaused(ORACLE_MODULE));
        assertTrue(oracle.isOperational());
    }

    function testLegacyResumeRelayIsDisabled() public {
        vm.prank(dao);
        vm.expectRevert(Guardian.DirectResumeRequired.selector);
        guardian.resumeOracle();
    }

    function testRevocationImmediatelyStopsGuardianContract() public {
        vm.prank(admin);
        safety.revokeGuardian(address(guardian));

        vm.prank(guardianOperator);
        vm.expectRevert("ACCESS_DENIED");
        guardian.pauseOracle();
    }

    function testPauseAtSunsetReverts() public {
        vm.warp(guardian.guardianSunset());

        vm.prank(guardianOperator);
        vm.expectRevert(Guardian.GuardianExpired.selector);
        guardian.pauseOracle();
    }
}
