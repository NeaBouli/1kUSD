// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/vault/TreasuryVault.sol";

contract MockERC20 is IERC20 {
    string public constant name = "MockToken";
    string public constant symbol = "MCK";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply = 1e24;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(balanceOf[msg.sender] >= amount, "insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function approve(address, uint256) external pure override returns (bool) { return true; }
    function transferFrom(address, address, uint256) external pure override returns (bool) { return true; }
}

contract Vault_WithdrawTest is Test {
    TreasuryVault vault;
    MockERC20 token;
    address dao = address(0xD00);
    address psm = address(0xBEEF);
    address user = address(0xCAFE);

    function setUp() public {
        token = new MockERC20();
        vault = new TreasuryVault(psm, dao);
        token.transfer(address(vault), 1e21);
        vm.prank(psm);
        vault.depositCollateral(address(token), 1000);
    }

    function testWithdrawByDAO() public {
        vm.prank(dao);
        vault.withdrawCollateral(address(token), user, 500);
        assertEq(vault.balances(address(token)), 500);
    }

    function testWithdrawByNonDAOReverts() public {
        vm.expectRevert("not DAO");
        vault.withdrawCollateral(address(token), user, 100);
    }

    function testWithdrawZeroReverts() public {
        vm.prank(dao);
        vm.expectRevert("amount=0");
        vault.withdrawCollateral(address(token), user, 0);
    }

    function testWithdrawInsufficientReverts() public {
        vm.prank(dao);
        vm.expectRevert("insufficient");
        vault.withdrawCollateral(address(token), user, 999999);
    }
}
