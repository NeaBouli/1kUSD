// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/interfaces/IVault.sol";
import "../../contracts/psm/PSM.sol";

contract MockVault is IVault {
    address public lastToken;
    uint256 public lastAmount;
    event VaultDeposit(address indexed from, address indexed token, uint256 amount);
    function depositCollateral(address token, uint256 amount) external override {
        lastToken = token; lastAmount = amount;
        emit VaultDeposit(msg.sender, token, amount);
    }
}

// Test helper exposing the internal hook
contract PSM_Exposed is PSM {
    constructor(address v) PSM(v) {}
    function call_forward(address t, uint256 a) external { _forwardToVault(t, a); }
}

contract VaultPSM_SettlementTest is Test {
    MockVault vault;
    PSM_Exposed psm;
    address token = address(0xCAFE);
    uint256 amount = 42;

    function setUp() public {
        vault = new MockVault();
        psm = new PSM_Exposed(address(vault));
    }

    function testForwardToVault() public {
        vm.recordLogs();
        psm.call_forward(token, amount);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertGt(entries.length, 0, "expected event emitted");
        assertEq(vault.lastToken, token, "token mismatch");
        assertEq(vault.lastAmount, amount, "amount mismatch");
    }
}
