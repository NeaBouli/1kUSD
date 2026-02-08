// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {FeeRouter} from "../../contracts/core/FeeRouter.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

/// @title FeeRouter_Auth
/// @notice P1 Remediation: misconfiguration tests for FeeRouter
///         Tests exact revert reasons for unauthorized callers and zero-address validation.
contract FeeRouter_Auth is Test {
    FeeRouter internal router;
    MockERC20 internal token;

    address internal adminAddr = address(this);
    address internal authorizedCaller = address(0xCAFE);
    address internal unauthorizedCaller = address(0xDEAD);
    address internal treasury = address(0xBEEF);

    function setUp() public {
        router = new FeeRouter(adminAddr);
        token = new MockERC20("USDC", "USDC");
        router.setAuthorizedCaller(authorizedCaller, true);
    }

    // -----------------------------------------------------------------
    // routeToTreasury authorization tests
    // -----------------------------------------------------------------

    function testRouteToTreasury_UnauthorizedCaller_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(FeeRouter.NotAuthorized.selector);
        router.routeToTreasury(address(token), treasury, 1e18, bytes32("FEE"));
    }

    function testRouteToTreasury_AuthorizedCaller_Succeeds() public {
        token.mint(address(router), 10e18);

        vm.prank(authorizedCaller);
        router.routeToTreasury(address(token), treasury, 10e18, bytes32("FEE"));
        assertEq(token.balanceOf(treasury), 10e18);
    }

    // -----------------------------------------------------------------
    // Admin-only setter tests
    // -----------------------------------------------------------------

    function testSetAuthorizedCaller_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(FeeRouter.NotAuthorized.selector);
        router.setAuthorizedCaller(address(0x1234), true);
    }

    function testSetAdmin_NonAdmin_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(FeeRouter.NotAuthorized.selector);
        router.setAdmin(unauthorizedCaller);
    }

    // -----------------------------------------------------------------
    // Zero address validation tests
    // -----------------------------------------------------------------

    function testSetAuthorizedCaller_ZeroAddress_Reverts() public {
        vm.expectRevert(FeeRouter.ZeroAddress.selector);
        router.setAuthorizedCaller(address(0), true);
    }

    function testSetAdmin_ZeroAddress_Reverts() public {
        vm.expectRevert(FeeRouter.ZeroAddress.selector);
        router.setAdmin(address(0));
    }

    function testRouteToTreasury_ZeroTokenAddress_Reverts() public {
        vm.prank(authorizedCaller);
        vm.expectRevert(FeeRouter.ZeroAddress.selector);
        router.routeToTreasury(address(0), treasury, 1e18, bytes32("FEE"));
    }

    function testRouteToTreasury_ZeroAmount_Reverts() public {
        vm.prank(authorizedCaller);
        vm.expectRevert(FeeRouter.ZeroAmount.selector);
        router.routeToTreasury(address(token), treasury, 0, bytes32("FEE"));
    }
}
