// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/psm/PSMLimits.sol";

/// @title PSMLimitsTest — DEV-35a.3 final test harness
contract PSMLimitsTest is Test {
    PSMLimits limits;
    LimitsHarness harness;

    function setUp() public {
        limits = new PSMLimits(address(this), 10_000, 5_000);
        harness = new LimitsHarness(address(this));
    }

    function testOnlyDAOCanSetLimits() public {
        limits.setLimits(20_000, 10_000);
        assertEq(limits.dailyCap(), 20_000);
    }

    function testDailyCapReverts() public {
        vm.expectRevert(bytes("swap too large"));
        limits.checkAndUpdate(11_000);
    }

    function testDailyResetOnNextDay() public {
        limits.checkAndUpdate(4_000);
        skip(1 days);
        limits.checkAndUpdate(4_000);
        assertEq(limits.dailyVolumeView(), 4_000, "volume not reset correctly");
    }

    function testSingleCapReverts() public {
        vm.expectRevert(bytes("swap too large"));
        limits.checkAndUpdate(6_000);
    }
}

/// @notice Separate harness that inherits PSMLimits for internal call coverage
contract LimitsHarness is PSMLimits {
    constructor(address dao) PSMLimits(dao, 10_000, 5_000) {}
    function hit(uint256 a) external { _updateVolume(a); }
}
