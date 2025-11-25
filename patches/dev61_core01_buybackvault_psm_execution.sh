#!/usr/bin/env bash
set -euo pipefail

echo "== DEV61 CORE01: add PSM-based buyback execution to BuybackVault =="

FILE="contracts/core/BuybackVault.sol"

cat <<'SOL' > "$FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";

interface IPegStabilityModuleLike {
    function swapFrom1kUSD(
        address tokenOut,
        uint256 amountIn1k,
        address recipient,
        uint256 minOut,
        uint256 deadline
    ) external returns (uint256 amountOut);
}

contract BuybackVault {
    using SafeERC20 for IERC20;

    error ZERO_ADDRESS();
    error ZERO_AMOUNT();
    error NOT_DAO();
    error PAUSED();

    IERC20 public immutable stable;
    IERC20 public immutable asset;
    address public immutable dao;
    ISafetyAutomata public immutable safety;
    IPegStabilityModuleLike public immutable psm;
    uint8 public immutable moduleId;

    event FundStable(uint256 amount);
    event WithdrawStable(address indexed to, uint256 amount);
    event WithdrawAsset(address indexed to, uint256 amount);
    event BuybackExecuted(uint256 amount1k, uint256 amountAsset, address indexed recipient);

    modifier onlyDAO() {
        if (msg.sender != dao) revert NOT_DAO();
        _;
    }

    modifier notPaused() {
        if (safety.isPaused(moduleId)) revert PAUSED();
        _;
    }

    constructor(
        address _stable,
        address _asset,
        address _dao,
        address _safety,
        address _psm,
        uint8 _moduleId
    ) {
        if (
            _stable == address(0) ||
            _asset == address(0) ||
            _dao == address(0) ||
            _safety == address(0) ||
            _psm == address(0)
        ) {
            revert ZERO_ADDRESS();
        }

        stable = IERC20(_stable);
        asset = IERC20(_asset);
        dao = _dao;
        safety = ISafetyAutomata(_safety);
        psm = IPegStabilityModuleLike(_psm);
        moduleId = _moduleId;
    }

    // --- Stage A: Custody-Layer ---

    function fundStable(uint256 amount) external onlyDAO notPaused {
        if (amount == 0) revert ZERO_AMOUNT();
        stable.safeTransferFrom(msg.sender, address(this), amount);
        emit FundStable(amount);
    }

    function withdrawStable(address to, uint256 amount) external onlyDAO notPaused {
        if (to == address(0)) revert ZERO_ADDRESS();
        if (amount == 0) revert ZERO_AMOUNT();
        stable.safeTransfer(to, amount);
        emit WithdrawStable(to, amount);
    }

    function withdrawAsset(address to, uint256 amount) external onlyDAO notPaused {
        if (to == address(0)) revert ZERO_ADDRESS();
        if (amount == 0) revert ZERO_AMOUNT();
        asset.safeTransfer(to, amount);
        emit WithdrawAsset(to, amount);
    }

    // --- Stage B: PSM-basierter Buyback-Execution-Endpunkt ---

    /// @notice Führt einen DAO-gesteuerten Buyback via PSM aus:
    ///         1kUSD -> Buyback-Asset (asset)
    /// @param amount1k  Notional in 1kUSD, der aus dem Vault verwendet wird
    /// @param recipient Empfänger des gekauften Assets (z.B. Treasury, Burn-Box)
    /// @param minOut    Mindestmenge des Assets (Slippage-Grenze)
    /// @param deadline  Swap-Deadline (wird direkt an den PSM weitergereicht)
    function executeBuybackPSM(
        uint256 amount1k,
        address recipient,
        uint256 minOut,
        uint256 deadline
    ) external onlyDAO notPaused returns (uint256 amountAssetOut) {
        if (recipient == address(0)) revert ZERO_ADDRESS();
        if (amount1k == 0) revert ZERO_AMOUNT();

        // Vault genehmigt dem PSM, 1kUSD zu ziehen
        stable.safeIncreaseAllowance(address(psm), amount1k);

        // PSM: 1kUSD -> Asset, alle Fees/Spreads/Limits/Health werden dort erzwungen
        amountAssetOut = psm.swapFrom1kUSD(
            address(asset),
            amount1k,
            recipient,
            minOut,
            deadline
        );

        emit BuybackExecuted(amount1k, amountAssetOut, recipient);
    }

    // --- Views ---

    function stableBalance() external view returns (uint256) {
        return stable.balanceOf(address(this));
    }

    function assetBalance() external view returns (uint256) {
        return asset.balanceOf(address(this));
    }
}
SOL

TEST_FILE="foundry/test/BuybackVault.t.sol"

cat <<'SOL' > "$TEST_FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BuybackVault, IPegStabilityModuleLike} from "../../contracts/core/BuybackVault.sol";

contract MintableToken is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract SafetyStub {
    bool public paused;

    function setPaused(bool value) external {
        paused = value;
    }

    function isPaused(uint8) external view returns (bool) {
        return paused;
    }
}

contract PSMStub is IPegStabilityModuleLike {
    MintableToken public immutable stable;
    MintableToken public immutable asset;

    uint256 public lastAmountIn;
    address public lastRecipient;

    constructor(MintableToken _stable, MintableToken _asset) {
        stable = _stable;
        asset = _asset;
    }

    function swapFrom1kUSD(
        address tokenOut,
        uint256 amountIn1k,
        address recipient,
        uint256 minOut,
        uint256
    ) external override returns (uint256 amountOut) {
        require(tokenOut == address(asset), "PSMStub: tokenOut mismatch");
        require(recipient != address(0), "PSMStub: zero recipient");

        // Ziehe 1kUSD vom Vault ein
        stable.transferFrom(msg.sender, address(this), amountIn1k);

        // Einfacher 1:1-Swap für Tests
        amountOut = amountIn1k;
        require(amountOut >= minOut, "PSMStub: slippage");

        asset.mint(recipient, amountOut);

        lastAmountIn = amountIn1k;
        lastRecipient = recipient;
    }
}

contract BuybackVaultTest is Test {
    MintableToken internal stable;
    MintableToken internal asset;
    SafetyStub internal safety;
    PSMStub internal psm;
    BuybackVault internal vault;

    address internal dao = address(0xDA0);
    address internal user = address(0xBEEF);
    uint8 internal constant MODULE_ID = 1;

    function setUp() public {
        stable = new MintableToken("1kUSD", "1K");
        asset = new MintableToken("GOV", "GOV");
        safety = new SafetyStub();
        psm = new PSMStub(stable, asset);

        vault = new BuybackVault(
            address(stable),
            address(asset),
            dao,
            address(safety),
            address(psm),
            MODULE_ID
        );
    }

    // --- Constructor guards ---

    function testConstructorZeroStableReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(0),
            address(asset),
            dao,
            address(safety),
            address(psm),
            MODULE_ID
        );
    }

    function testConstructorZeroAssetReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(stable),
            address(0),
            dao,
            address(safety),
            address(psm),
            MODULE_ID
        );
    }

    function testConstructorZeroDaoReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(stable),
            address(asset),
            address(0),
            address(safety),
            address(psm),
            MODULE_ID
        );
    }

    function testConstructorZeroSafetyReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(stable),
            address(asset),
            dao,
            address(0),
            address(psm),
            MODULE_ID
        );
    }

    function testConstructorZeroPsmReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(stable),
            address(asset),
            dao,
            address(safety),
            address(0),
            MODULE_ID
        );
    }

    // --- Helpers ---

    function _fundStableAsDao(uint256 amount) internal {
        stable.mint(dao, amount);
        vm.startPrank(dao);
        stable.approve(address(vault), amount);
        vault.fundStable(amount);
        vm.stopPrank();
    }

    // --- Access & Pause: Stage A ---

    function testFundStableOnlyDaoCanCall() public {
        uint256 amount = 1e18;
        stable.mint(user, amount);

        vm.startPrank(user);
        stable.approve(address(vault), amount);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.fundStable(amount);
        vm.stopPrank();
    }

    function testFundStableRevertsWhenPaused() public {
        uint256 amount = 1e18;
        stable.mint(dao, amount);

        vm.startPrank(dao);
        stable.approve(address(vault), amount);
        safety.setPaused(true);
        vm.expectRevert(BuybackVault.PAUSED.selector);
        vault.fundStable(amount);
        vm.stopPrank();
    }

    function testWithdrawStableOnlyDao() public {
        _fundStableAsDao(5e18);

        vm.prank(user);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.withdrawStable(user, 1e18);
    }

    function testWithdrawStableZeroAddressReverts() public {
        _fundStableAsDao(5e18);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.withdrawStable(address(0), 1e18);
    }

    function testWithdrawAssetOnlyDao() public {
        asset.mint(address(vault), 10e18);

        vm.prank(user);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.withdrawAsset(user, 1e18);
    }

    function testWithdrawAssetZeroAddressReverts() public {
        asset.mint(address(vault), 10e18);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.withdrawAsset(address(0), 1e18);
    }

    // --- Stage B: PSM-basierter Buyback ---

    function testExecuteBuybackOnlyDaoCanCall() public {
        _fundStableAsDao(10e18);

        vm.prank(user);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.executeBuybackPSM(5e18, user, 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackRevertsWhenPaused() public {
        _fundStableAsDao(10e18);
        safety.setPaused(true);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.PAUSED.selector);
        vault.executeBuybackPSM(5e18, user, 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackZeroRecipientReverts() public {
        _fundStableAsDao(10e18);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.executeBuybackPSM(5e18, address(0), 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackZeroAmountReverts() public {
        _fundStableAsDao(10e18);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_AMOUNT.selector);
        vault.executeBuybackPSM(0, user, 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackTransfersStableAndMintsAsset() public {
        _fundStableAsDao(10e18);

        uint256 amount1k = 4e18;
        uint256 vaultStableBefore = stable.balanceOf(address(vault));
        uint256 userAssetBefore = asset.balanceOf(user);
        uint256 psmStableBefore = stable.balanceOf(address(psm));

        vm.prank(dao);
        uint256 out = vault.executeBuybackPSM(
            amount1k,
            user,
            0,
            block.timestamp + 1 days
        );

        assertEq(out, amount1k, "buyback out should be 1:1 in stub");
        assertEq(
            stable.balanceOf(address(vault)),
            vaultStableBefore - amount1k,
            "vault stable balance mismatch"
        );
        assertEq(
            stable.balanceOf(address(psm)),
            psmStableBefore + amount1k,
            "PSM stable balance mismatch"
        );
        assertEq(
            asset.balanceOf(user) - userAssetBefore,
            amount1k,
            "user asset balance mismatch"
        );
    }

    // --- View-Helper ---

    function testBalanceViewsReflectHoldings() public {
        stable.mint(address(vault), 11e18);
        asset.mint(address(vault), 22e18);

        assertEq(vault.stableBalance(), 11e18, "stableBalance mismatch");
        assertEq(vault.assetBalance(), 22e18, "assetBalance mismatch");
    }
}
SOL

echo "✓ DEV61 CORE01: BuybackVault PSM execution wired + tests updated"
