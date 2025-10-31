// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/psm/PSMLimits.sol";

contract LimitsHarness is PSMLimits {
    constructor(address dao_, uint256 s, uint256 d) PSMLimits(dao_, s, d) {}
    function hit(uint256 a) external { _updateVolume(a); }
}

contract PSMLimitsTest is Test {
    LimitsHarness limits;
    address dao = address(this);

    function setUp() public {
        limits = new LimitsHarness(dao, 1_000, 5_000); // single=1000, daily=5000
    }

    function testSingleCapReverts() public {
        vm.expectRevert(bytes("swap too large"));
        limits.hit(1_001);
    }

    function testDailyCapReverts() public {
        limits.hit(3_000);
        limits.hit(2_000);
        vm.expectRevert(bytes("daily limit"));
        limits.hit(1);
    }

    function testDailyResetOnNextDay() public {
        limits.hit(4_000);
        uint256 beforeDay = limits.lastDay();
        vm.warp(block.timestamp + 1 days + 1);
        limits.hit(4_000); // should pass after reset
        assertGt(limits.lastDay(), beforeDay, "day not advanced");
        assertEq(limits.dailyVolume(), 4_000, "volume not reset correctly");
    }

    function testOnlyDAOCanSetLimits() public {
        vm.prank(address(0xBEEF));
        vm.expectRevert(bytes("not DAO"));
        limits.setLimits(2_000, 10_000);
    }
}
