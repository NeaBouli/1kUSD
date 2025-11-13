// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../../contracts/core/SafetyAutomata.sol";
import "../../contracts/core/PegStabilityModule.sol";
import "../../contracts/security/Guardian.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// ---- Mock Dependencies ----
contract MockToken is ERC20 {
    constructor(string memory n, string memory s) ERC20(n, s) {
        _mint(msg.sender, 1_000_000e18);
    }
}

contract MockVault {
    function deposit(address, address, uint256) external {}
    function withdraw(address, address, uint256, bytes32) external {}
}

contract MockRegistry {
    function getParam(bytes32) external pure returns (uint256) { return 0; }
}

// ---- Test ----
contract MockMintableToken is ERC20 {
    constructor(string memory n, string memory s) ERC20(n, s) {
        _mint(msg.sender, 1_000_000e18);
    }
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
contract Guardian_PSMUnpauseTest is Test {
    SafetyAutomata internal safety;
    Guardian internal guardian;
    PegStabilityModule internal psm;
    MockMintableToken internal token;
    MockMintableToken internal oneKUSD;
    MockVault internal vault;
    MockRegistry internal reg;

    address internal dao = address(0xdead);

    function setUp() public {
        guardian = new Guardian(dao, block.number + 100_000);
        safety = new SafetyAutomata(dao, block.timestamp + 10000);
        vault = new MockVault();
        reg = new MockRegistry();
        oneKUSD = new MockMintableToken("1kUSD", "1KUSD");
        psm = new PegStabilityModule(dao, address(oneKUSD), address(vault), address(safety), address(reg));
        // PSM mit 1kUSD auffüllen, damit Swap funktioniert
        oneKUSD.transfer(address(psm), 1_000_000e18);
        token = new MockMintableToken("MockToken", "MOCK");

        // initial pause
        vm.prank(dao);
        safety.pauseModule(keccak256("PSM"));
        assertTrue(safety.isPaused(keccak256("PSM")));
    }

    function testUnpauseRestoresPSMOperation() public {
        bytes32 MODULE_PSM = keccak256("PSM");

        // Unpause
        vm.prank(dao);
        safety.resumeModule(MODULE_PSM);
        assertFalse(safety.isPaused(MODULE_PSM));

        // Approve & simulate swap
        token.approve(address(psm), 1000e18);

        // should NOT revert now
        psm.swapTo1kUSD(address(token), 1000e18, address(this), 0, 18);
    }
}
