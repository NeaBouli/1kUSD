// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/vault/TreasuryVault.sol";

contract Vault_AccountingTest is Test {
    TreasuryVault vault;
    address psm = address(0xBEEF);
    address token = address(0xCAFE);

    function setUp() public {
        vault = new TreasuryVault(psm);
    }

    function testDepositByPSMUpdatesBalance() public {
        vm.prank(psm);
        vault.depositCollateral(token, 100);
        assertEq(vault.balances(token), 100);
    }

    function testDepositByNonPSMReverts() public {
        vm.expectRevert("not PSM");
        vault.depositCollateral(token, 100);
    }

    function testDepositZeroAmountReverts() public {
        vm.prank(psm);
        vm.expectRevert("amount=0");
        vault.depositCollateral(token, 0);
    }
}
