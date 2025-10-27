// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../../contracts/core/SafetyNet.sol";

contract TestSafetyNet is Test {
    SafetyNet net;
    address admin = address(1);

    function setUp() public {
        vm.prank(admin);
        net = new SafetyNet();
    }

    function testStatusReturnsTrue() public {
        bool s = net.status();
        assertTrue(s, "SafetyNet.status() should return true");
    }
}
