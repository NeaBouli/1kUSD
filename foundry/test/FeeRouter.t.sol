// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {FeeRouter} from "../contracts/core/FeeRouter.sol";
import {IFeeRouter} from "../contracts/interfaces/IFeeRouter.sol";
import {TreasuryVault} from "../contracts/core/TreasuryVault.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract FeeRouterTest is Test {
    FeeRouter router;
    TreasuryVault treasury;
    MockERC20 token;

    address admin = address(0xA11CE);
    address module = address(0xBEEF);

    bytes32 constant TAG = keccak256("PSM_MINT_FEE");

    function setUp() public {
        router   = new FeeRouter();
        treasury = new TreasuryVault(admin);
        token    = new MockERC20("Mock", "MOCK");

        vm.label(admin, "ADMIN");
        vm.label(module, "MODULE");
        vm.label(address(router), "FEE_ROUTER");
        vm.label(address(treasury), "TREASURY");
        vm.label(address(token), "TOKEN");

        // Modul erhält Token
        token.mint(module, 1_000e18);
    }

    function test_routeToTreasury_emits_and_transfers() public {
        uint256 fee = 123e18;

        // Modul überweist Fee zuerst an den Router (Push)
        vm.startPrank(module);
        token.transfer(address(router), fee);

        // Erwartung: Event & Weiterleitung an Treasury
        vm.expectEmit(true, true, true, true);
        emit IFeeRouter.FeeRouted(address(token), module, address(treasury), fee, TAG);

        router.routeToTreasury(address(token), address(treasury), fee, TAG);
        vm.stopPrank();

        assertEq(token.balanceOf(address(treasury)), fee, "treasury should receive fee");
        assertEq(token.balanceOf(address(router)), 0, "router should forward all");
    }

    function test_routeToTreasury_zero_amount_reverts() public {
        vm.expectRevert(FeeRouter.ZeroAmount.selector);
        router.routeToTreasury(address(token), address(treasury), 0, TAG);
    }

    function test_routeToTreasury_zero_address_reverts() public {
        vm.expectRevert(FeeRouter.ZeroAddress.selector);
        router.routeToTreasury(address(0), address(treasury), 1, TAG);

        vm.expectRevert(FeeRouter.ZeroAddress.selector);
        router.routeToTreasury(address(token), address(0), 1, TAG);
    }
}
