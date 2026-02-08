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

/// @title PSM_Deadline
/// @notice P1 Remediation: deadline enforcement tests for PegStabilityModule
///         Tests PSM_DEADLINE_EXPIRED revert and deadline=0 opt-out passthrough.
contract PSM_Deadline is Test {
    PegStabilityModule internal psm;
    OneKUSD internal oneKUSD;
    CollateralVault internal vault;
    SafetyAutomata internal safety;
    ParameterRegistry internal registry;
    MockOracleAggregator internal oracle;
    MockERC20 internal usdc;

    address internal admin = address(this);
    address internal user = address(0xBEEF);

    function setUp() public {
        // Set a realistic timestamp so deadline math works
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

        // Fund vault for redeem tests: transfer tokens + record accounting
        usdc.mint(address(vault), 500e18);
        vault.deposit(address(usdc), admin, 500e18);

        // Mint 1kUSD to user for redeem tests
        oneKUSD.setMinter(admin, true);
        oneKUSD.mint(user, 500e18);
        oneKUSD.setMinter(admin, false);
        vm.prank(user);
        oneKUSD.approve(address(psm), type(uint256).max);
    }

    // -----------------------------------------------------------------
    // Expired deadline → revert
    // -----------------------------------------------------------------

    function testSwapTo1kUSD_ExpiredDeadline_Reverts() public {
        uint256 pastDeadline = block.timestamp - 1;

        vm.prank(user);
        vm.expectRevert(PegStabilityModule.PSM_DEADLINE_EXPIRED.selector);
        psm.swapTo1kUSD(address(usdc), 100e18, user, 0, pastDeadline);
    }

    function testSwapFrom1kUSD_ExpiredDeadline_Reverts() public {
        uint256 pastDeadline = block.timestamp - 1;

        vm.prank(user);
        vm.expectRevert(PegStabilityModule.PSM_DEADLINE_EXPIRED.selector);
        psm.swapFrom1kUSD(address(usdc), 100e18, user, 0, pastDeadline);
    }

    // -----------------------------------------------------------------
    // deadline == 0 → opt-out (no revert)
    // -----------------------------------------------------------------

    function testSwapTo1kUSD_DeadlineZero_Succeeds() public {
        vm.prank(user);
        uint256 netOut = psm.swapTo1kUSD(address(usdc), 100e18, user, 0, 0);
        assertGt(netOut, 0);
    }

    // -----------------------------------------------------------------
    // Future deadline → success
    // -----------------------------------------------------------------

    function testSwapTo1kUSD_FutureDeadline_Succeeds() public {
        uint256 futureDeadline = block.timestamp + 1 hours;

        vm.prank(user);
        uint256 netOut = psm.swapTo1kUSD(address(usdc), 100e18, user, 0, futureDeadline);
        assertGt(netOut, 0);
    }
}
