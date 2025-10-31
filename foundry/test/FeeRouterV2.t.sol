// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/router/FeeRouterV2.sol";

contract FeeRouterV2Test is Test {
    FeeRouterV2 router;
    address dao = address(this);
    address token = address(0xCAFE);
    address vault = address(0xBEEF);

    event FeeRouted(bytes32 indexed tag, address indexed token, uint256 amount, address indexed to);
    event RouteSet(bytes32 indexed tag, address indexed vault);

    function setUp() public {
        router = new FeeRouterV2(dao);
    }

    function testSetRouteOnlyDAO() public {
        bytes32 tag = keccak256("POOL");
        router.setRoute(tag, vault);
        assertEq(router.routeMap(tag), vault);
    }

    function testNonDAOCannotSetRoute() public {
        vm.prank(address(0x123));
        vm.expectRevert("not DAO");
        router.setRoute(keccak256("POOL"), vault);
    }

    function testRouteRevertsOnZero() public {
        vm.expectRevert("amount=0");
        router.route(keccak256("POOL"), token, 0);
    }

    function testRouteRevertsOnMissing() public {
        vm.expectRevert("route missing");
        router.route(keccak256("POOL"), token, 10);
    }

    function testPauseBlocksRoute() public {
        bytes32 tag = keccak256("POOL");
        router.setRoute(tag, vault);
        router.pause();
        vm.expectRevert("Pausable: paused");
        router.route(tag, token, 10);
    }
}
