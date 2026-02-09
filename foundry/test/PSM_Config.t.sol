// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {PegStabilityModule} from "../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../contracts/core/OneKUSD.sol";
import {CollateralVault} from "../../contracts/core/CollateralVault.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {ParameterRegistry} from "../../contracts/core/ParameterRegistry.sol";
import {MockOracleAggregator} from "./mocks/MockOracleAggregator.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/// @title PSM_Config
/// @notice Sprint 1 — misconfiguration tests for PegStabilityModule
///         Tests admin setters, oracle misconfiguration, pause gate, fee bounds.
contract PSM_Config is Test {
    PegStabilityModule internal psm;
    OneKUSD internal oneKUSD;
    CollateralVault internal vault;
    SafetyAutomata internal safety;
    ParameterRegistry internal registry;
    MockOracleAggregator internal oracle;
    MockERC20 internal usdc;

    address internal admin = address(this);
    address internal unauthorizedCaller = address(0xDEAD);
    address internal user = address(0xBEEF);

    bytes32 internal adminRole;

    function setUp() public {
        vm.warp(1_700_000_000);

        // Deploy infrastructure
        safety = new SafetyAutomata(admin, block.timestamp + 365 days);
        registry = new ParameterRegistry(admin);
        oneKUSD = new OneKUSD(admin);
        vault = new CollateralVault(admin, safety, registry);
        oracle = new MockOracleAggregator();
        usdc = new MockERC20("USDC", "USDC");

        // Deploy PSM
        psm = new PegStabilityModule(
            admin,
            address(oneKUSD),
            address(vault),
            address(safety),
            address(registry)
        );

        // Cache ADMIN_ROLE for expectRevert encoding
        adminRole = psm.ADMIN_ROLE();

        // Configure oracle: 1:1 price, 18 decimals, healthy
        oracle.setPrice(1e18, 18, true);
        psm.setOracle(address(oracle));

        // Configure roles: PSM is minter + burner on OneKUSD
        oneKUSD.setMinter(address(psm), true);
        oneKUSD.setBurner(address(psm), true);

        // Configure vault: support USDC, authorize PSM
        vault.setAssetSupported(address(usdc), true);
        vault.setAuthorizedCaller(address(psm), true);

        // Fund user with USDC and approve PSM
        usdc.mint(user, 1000e18);
        vm.prank(user);
        usdc.approve(address(psm), type(uint256).max);
    }

    // -----------------------------------------------------------------
    // Non-admin config setter tests (OZ AccessControl)
    // -----------------------------------------------------------------

    function testSetOracle_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                unauthorizedCaller,
                adminRole
            )
        );
        psm.setOracle(address(0x1234));
    }

    function testSetLimits_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                unauthorizedCaller,
                adminRole
            )
        );
        psm.setLimits(address(0x1234));
    }

    function testSetFees_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                unauthorizedCaller,
                adminRole
            )
        );
        psm.setFees(50, 75);
    }

    // -----------------------------------------------------------------
    // Oracle misconfiguration tests
    // -----------------------------------------------------------------

    function testSwap_OracleNotSet_Reverts() public {
        // Deploy a fresh PSM without oracle
        PegStabilityModule freshPsm = new PegStabilityModule(
            admin,
            address(oneKUSD),
            address(vault),
            address(safety),
            address(registry)
        );
        // Do NOT call setOracle

        vm.prank(user);
        vm.expectRevert(PegStabilityModule.PSM_ORACLE_MISSING.selector);
        freshPsm.swapTo1kUSD(address(usdc), 100e18, user, 0, 0);
    }

    function testSwap_OracleNotOperational_Reverts() public {
        oracle.setPrice(1e18, 18, false);

        vm.prank(user);
        vm.expectRevert("PSM: oracle not operational");
        psm.swapTo1kUSD(address(usdc), 100e18, user, 0, 0);
    }

    // -----------------------------------------------------------------
    // Paused module tests
    // -----------------------------------------------------------------

    function testSwapTo1kUSD_WhenPaused_Reverts() public {
        safety.pauseModule(keccak256("PSM"));

        vm.prank(user);
        vm.expectRevert(PegStabilityModule.PausedError.selector);
        psm.swapTo1kUSD(address(usdc), 100e18, user, 0, 0);
    }

    function testSwapFrom1kUSD_WhenPaused_Reverts() public {
        safety.pauseModule(keccak256("PSM"));

        vm.prank(user);
        vm.expectRevert(PegStabilityModule.PausedError.selector);
        psm.swapFrom1kUSD(address(usdc), 100e18, user, 0, 0);
    }

    // -----------------------------------------------------------------
    // Admin config succeeds tests
    // -----------------------------------------------------------------

    function testSetOracle_Admin_Succeeds() public {
        address newOracle = address(0x1234);
        psm.setOracle(newOracle);
        assertEq(address(psm.oracle()), newOracle);
    }

    function testSetLimits_Admin_Succeeds() public {
        address newLimits = address(0x1234);
        psm.setLimits(newLimits);
        assertEq(address(psm.limits()), newLimits);
    }

    function testSetFees_Admin_Succeeds() public {
        psm.setFees(50, 75);
        assertEq(psm.mintFeeBps(), 50);
        assertEq(psm.redeemFeeBps(), 75);
    }

    // -----------------------------------------------------------------
    // Fee bounds validation tests
    // -----------------------------------------------------------------

    function testSetFees_MintFeeTooHigh_Reverts() public {
        vm.expectRevert("PSM: mintFee too high");
        psm.setFees(10_001, 0);
    }

    function testSetFees_RedeemFeeTooHigh_Reverts() public {
        vm.expectRevert("PSM: redeemFee too high");
        psm.setFees(0, 10_001);
    }
}
