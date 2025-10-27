// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../../contracts/core/GuardianMonitor.sol";

contract TestGuardianMonitor is Test {
    GuardianMonitor gm;

    function setUp() public {
        gm = new GuardianMonitor();
    }

    function testPingReturnsActive() public {
        string memory response = gm.ping();
        assertEq(response, "GuardianMonitor active", "GuardianMonitor.ping() should return expected string");
    }
}
