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
