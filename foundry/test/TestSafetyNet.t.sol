pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../../contracts/core/SafetyNet.sol";

contract TestSafetyNet is Test {
    SafetyNet net;
    address admin = address(1);
    address watcher = address(2);

    function setUp() public {
        vm.prank(admin);
        net = new SafetyNet(admin);
        vm.startPrank(admin);
        address ;
        w[0] = watcher;
        net.grantWatchers(w);
        vm.stopPrank();
    }

    function testRaiseAlertEmitsEvent() public {
        vm.startPrank(watcher);
        vm.expectEmit(true, true, true, true);
        emit SafetyNet.AlertRaised(watcher, keccak256("TEST"), "ok", false);
        net.raiseAlert(keccak256("TEST"), "ok", false);
        vm.stopPrank();
    }

    function testRevertIfNotWatcher() public {
        vm.expectRevert();
        net.raiseAlert(keccak256("FAIL"), "x", false);
    }
}
