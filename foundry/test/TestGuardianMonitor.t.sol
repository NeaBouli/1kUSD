pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../../contracts/core/GuardianMonitor.sol";
import "./MockSafetyAutomata.sol";
import "./MockOracleAggregator.sol";

contract TestGuardianMonitor is Test {
    GuardianMonitor gm;
    MockSafetyAutomata safety;
    MockOracleAggregator oracle;
    address asset = address(11);
    address owner = address(this);

    function setUp() public {
        safety = new MockSafetyAutomata();
        oracle = new MockOracleAggregator();
        gm = new GuardianMonitor(address(safety), address(oracle), owner);
        gm.setRule(asset, 100, 300, true); // 1% / 5min
    }

    function testPauseOnDeviation() public {
        oracle.setPrice(1.03e18); // +3%
        gm.checkAndPauseIfNeeded(asset);
        assertTrue(safety.paused(), "should pause on deviation");
    }

    function testPauseOnStaleness() public {
        safety = new MockSafetyAutomata();
        oracle = new MockOracleAggregator();
        gm = new GuardianMonitor(address(safety), address(oracle), owner);
        gm.setRule(asset, 200, 10, true);
        oracle.setTimestamp(block.timestamp - 60);
        gm.checkAndPauseIfNeeded(asset);
        assertTrue(safety.paused(), "should pause on staleness");
    }

    function testNoPauseIfWithinBounds() public {
        safety = new MockSafetyAutomata();
        oracle = new MockOracleAggregator();
        gm = new GuardianMonitor(address(safety), address(oracle), owner);
        gm.setRule(asset, 500, 300, true);
        gm.checkAndPauseIfNeeded(asset);
        assertFalse(safety.paused(), "no pause expected");
    }
}
