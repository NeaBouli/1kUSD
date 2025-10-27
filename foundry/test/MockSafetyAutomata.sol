pragma solidity ^0.8.20;

contract MockSafetyAutomata {
    bool public paused;

    function isPaused() external view returns (bool) {
        return paused;
    }

    function pause() external {
        paused = true;
    }
}
