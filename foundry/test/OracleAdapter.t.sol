// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/oracle/OracleAdapter.sol";

contract OracleAdapterTest is Test {
    OracleAdapter oracle;
    address dao = address(this);

    function setUp() public {
        oracle = new OracleAdapter(dao);
    }

    function testSetPriceUpdatesAndEmits() public {
        vm.expectEmit(true, true, false, true);
        emit OracleAdapter.PriceUpdated(1500e18, block.timestamp);
        oracle.setPrice(1500e18);
        (uint256 p) = oracle.getPrice();
        assertEq(p, 1500e18, "price mismatch");
    }

    function testGetPriceRevertsIfStale() public {
        oracle.setPrice(1000e18);
        vm.warp(block.timestamp + 2 days);
        vm.expectRevert("stale");
        oracle.getPrice();
    }

    function testOnlyDAOCanSetPrice() public {
        vm.prank(address(0xBEEF));
        vm.expectRevert("not DAO");
        oracle.setPrice(42);
    }
}
