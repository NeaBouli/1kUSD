// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

import "forge-std/Test.sol";

import {BuybackVault} from "../../contracts/core/BuybackVault.sol";
import {ISafetyAutomata} from "../../contracts/interfaces/ISafetyAutomata.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/// @dev Minimal SafetyAutomata-Stub für BuybackVault-Tests.
///      Implementiert nur isPaused(moduleId); Pause-Flag wird lokal gehalten.
contract SafetyStub is ISafetyAutomata {
    mapping(bytes32 => bool) internal paused;

    function setPaused(bytes32 moduleId, bool value) external {
        paused[moduleId] = value;
    }

    function isPaused(bytes32 moduleId) external view override returns (bool) {
        return paused[moduleId];
    }
}

contract BuybackVaultTest is Test {
    BuybackVault internal vault;
    SafetyStub internal safety;
    MockToken internal stable;
    MockToken internal asset;

    address internal dao = address(0xD0A);
    address internal user = address(0xBEEF);

    function setUp() public {
        safety = new SafetyStub();
        stable = new MockToken("1kUSD", "1kUSD");
        asset = new MockToken("GOV", "GOV");

        vault = new BuybackVault(
            dao,
            ISafetyAutomata(address(safety)),
            IERC20(address(stable)),
            IERC20(address(asset))
        );
    }

    // --- Constructor Guards ---

    function testConstructorZeroDaoReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(0),
            ISafetyAutomata(address(safety)),
            IERC20(address(stable)),
            IERC20(address(asset))
        );
    }

    function testConstructorZeroSafetyReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            dao,
            ISafetyAutomata(address(0)),
            IERC20(address(stable)),
            IERC20(address(asset))
        );
    }

    function testConstructorZeroStableReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            dao,
            ISafetyAutomata(address(safety)),
            IERC20(address(0)),
            IERC20(address(asset))
        );
    }

    function testConstructorZeroAssetReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            dao,
            ISafetyAutomata(address(safety)),
            IERC20(address(stable)),
            IERC20(address(0))
        );
    }

    // --- Access Control: fundStable ---

    function testFundStableOnlyDaoCanCall() public {
        uint256 amount = 100e18;

        stable.mint(dao, amount);
        vm.prank(dao);
        stable.approve(address(vault), amount);

        vm.expectRevert(BuybackVault.ACCESS_DENIED.selector);
        vault.fundStable(amount);

        vm.prank(dao);
        vault.fundStable(amount);

        assertEq(stable.balanceOf(address(vault)), amount, "vault stable balance mismatch");
        assertEq(stable.balanceOf(dao), 0, "dao should have transferred funds");
    }

    // --- Pause Semantik ---

    function testFundStableRevertsWhenPaused() public {
        uint256 amount = 50e18;
        stable.mint(dao, amount);

        vm.prank(dao);
        stable.approve(address(vault), amount);

        bytes32 moduleId = vault.MODULE_ID();
        safety.setPaused(moduleId, true);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.PAUSED.selector);
        vault.fundStable(amount);
    }

    // --- Withdraw Stable ---

    function testWithdrawStableOnlyDao() public {
        uint256 amount = 42e18;

        stable.mint(address(vault), amount);

        vm.expectRevert(BuybackVault.ACCESS_DENIED.selector);
        vault.withdrawStable(user, amount);

        vm.prank(dao);
        vault.withdrawStable(user, amount);

        assertEq(stable.balanceOf(user), amount, "user should receive stable");
        assertEq(stable.balanceOf(address(vault)), 0, "vault stable should be empty");
    }

    function testWithdrawStableZeroAddressReverts() public {
        uint256 amount = 1e18;
        stable.mint(address(vault), amount);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.withdrawStable(address(0), amount);
    }

    // --- Withdraw Asset ---

    function testWithdrawAssetOnlyDao() public {
        uint256 amount = 7e18;

        asset.mint(address(vault), amount);

        vm.expectRevert(BuybackVault.ACCESS_DENIED.selector);
        vault.withdrawAsset(user, amount);

        vm.prank(dao);
        vault.withdrawAsset(user, amount);

        assertEq(asset.balanceOf(user), amount, "user should receive asset");
        assertEq(asset.balanceOf(address(vault)), 0, "vault asset should be empty");
    }

    function testWithdrawAssetZeroAddressReverts() public {
        uint256 amount = 3e18;
        asset.mint(address(vault), amount);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.withdrawAsset(address(0), amount);
    }

    // --- View Helpers ---

    function testBalanceViewsReflectHoldings() public {
        stable.mint(address(vault), 11e18);
        asset.mint(address(vault), 22e18);

        assertEq(vault.stableBalance(), 11e18, "stableBalance mismatch");
        assertEq(vault.assetBalance(), 22e18, "assetBalance mismatch");
    }
}
