// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/psm/PSM.sol";
import "../../contracts/interfaces/IVault.sol";

contract MockVault is IVault {
    address public lastToken;
    uint256 public lastAmount;
    event VaultDeposit(address indexed from, address indexed token, uint256 amount);

    function depositCollateral(address token, uint256 amount) external override {
        lastToken = token;
        lastAmount = amount;
        emit VaultDeposit(msg.sender, token, amount);
    }
}

contract VaultPSM_SettlementTest is Test {
    MockVault vault;
    PSM psm;
    address token = address(0xCAFE);
    uint256 amount = 42;

    function setUp() public {
        vault = new MockVault();
        psm = new PSM(address(vault));
    }

    function testForwardToVault() public {
        vm.recordLogs();
        psm._forwardToVault(token, amount);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertGt(entries.length, 0, "expected event emitted");
    }
}
