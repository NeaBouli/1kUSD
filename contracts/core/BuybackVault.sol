// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IOracleHealthModule {
    function isHealthy() external view returns (bool);
}

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

/// @title BuybackVault
/// @notice DAO-controlled vault for executing buybacks via PSM.
///         Stable tokens are custodied here and swapped for the buyback asset.
contract BuybackVault {
    using SafeERC20 for IERC20;

    // --- Errors ---
    error ZERO_ADDRESS();
    error ZERO_AMOUNT();
    error NOT_DAO();
    error PAUSED();
    error INVALID_AMOUNT();
    error INSUFFICIENT_BALANCE();
    error INVALID_STRATEGY();
    error NO_STRATEGY_CONFIGURED();
    error NO_ENABLED_STRATEGY_FOR_ASSET();
    error BUYBACK_TREASURY_CAP_EXCEEDED();
    error BUYBACK_TREASURY_WINDOW_CAP_EXCEEDED();
    error BUYBACK_ORACLE_UNHEALTHY();

    // --- Events ---
    event StableFunded(address indexed from, uint256 amount);
    event StableWithdrawn(address indexed to, uint256 amount);
    event AssetWithdrawn(address indexed to, uint256 amount);
    event BuybackExecuted(address indexed recipient, uint256 stableIn, uint256 assetOut);
    event StrategyEnforcementUpdated(bool enforced);
    event StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled);
    event BuybackTreasuryCapUpdated(uint16 oldCapBps, uint16 newCapBps);
    event BuybackOracleHealthGateUpdated(
        address indexed oldModule,
        address indexed newModule,
        bool oldEnforced,
        bool newEnforced
    );
    event BuybackWindowConfigUpdated(
        uint64 oldDuration,
        uint64 newDuration,
        uint16 oldCapBps,
        uint16 newCapBps
    );

    // --- Strategy ---
    struct StrategyConfig {
        address asset;
        uint16 weightBps;
        bool enabled;
    }

    StrategyConfig[] private strategies;
    bool public strategiesEnforced;

    // --- Immutables ---
    IERC20 public immutable stable;
    IERC20 public immutable asset;
    address public immutable dao;
    ISafetyAutomata public immutable safety;
    IPegStabilityModuleLike public immutable psm;
    bytes32 public immutable moduleId;

    // --- Per-operation treasury cap ---
    uint16 public maxBuybackSharePerOpBps;

    // --- Oracle health gate ---
    address public oracleHealthModule;
    bool public oracleHealthGateEnforced;

    // --- Rolling window cap ---
    uint16 public maxBuybackSharePerWindowBps;
    uint64 public buybackWindowDuration;
    uint64 public buybackWindowStart;
    uint128 public buybackWindowAccumulatedBps;
    uint256 public buybackWindowStartStableBalance;

    // --- Modifiers ---
    modifier onlyDAO() {
        if (msg.sender != dao) revert NOT_DAO();
        _;
    }

    modifier notPaused() {
        if (safety.isPaused(moduleId)) revert PAUSED();
        _;
    }

    // --- Constructor ---
    constructor(
        address _stable,
        address _asset,
        address _dao,
        address _safety,
        address _psm,
        bytes32 _moduleId
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

    // -------------------------------------------------------------
    // Custody Layer
    // -------------------------------------------------------------

    function fundStable(uint256 amount) external onlyDAO notPaused {
        if (amount == 0) revert ZERO_AMOUNT();
        stable.safeTransferFrom(msg.sender, address(this), amount);
        emit StableFunded(msg.sender, amount);
    }

    function withdrawStable(address to, uint256 amount) external onlyDAO notPaused {
        if (to == address(0)) revert ZERO_ADDRESS();
        if (amount == 0) revert ZERO_AMOUNT();
        stable.safeTransfer(to, amount);
        emit StableWithdrawn(to, amount);
    }

    function withdrawAsset(address to, uint256 amount) external onlyDAO notPaused {
        if (to == address(0)) revert ZERO_ADDRESS();
        if (amount == 0) revert ZERO_AMOUNT();
        asset.safeTransfer(to, amount);
        emit AssetWithdrawn(to, amount);
    }

    // -------------------------------------------------------------
    // Buyback Execution (single canonical path via PSM)
    // -------------------------------------------------------------

    /// @notice Execute a DAO-controlled buyback via PSM: 1kUSD -> asset.
    /// @param amount1k  Amount of stable (1kUSD) to spend from the vault.
    /// @param recipient Recipient of the bought-back asset.
    /// @param minOut    Minimum acceptable asset amount (slippage guard).
    /// @param deadline  Swap deadline forwarded to the PSM.
    function executeBuybackPSM(
        uint256 amount1k,
        address recipient,
        uint256 minOut,
        uint256 deadline
    ) external onlyDAO notPaused returns (uint256 amountAssetOut) {
        if (recipient == address(0)) revert ZERO_ADDRESS();
        if (amount1k == 0) revert ZERO_AMOUNT();

        uint256 bal = stable.balanceOf(address(this));
        if (bal < amount1k) revert INSUFFICIENT_BALANCE();

        _checkPerOpTreasuryCap(amount1k, bal);
        _checkBuybackWindowCap(amount1k, bal);
        _checkOracleHealthGate();
        _checkStrategyEnforcement();

        stable.safeIncreaseAllowance(address(psm), amount1k);

        amountAssetOut = psm.swapFrom1kUSD(
            address(asset),
            amount1k,
            recipient,
            minOut,
            deadline
        );

        emit BuybackExecuted(recipient, amount1k, amountAssetOut);
    }

    // -------------------------------------------------------------
    // Internal guards
    // -------------------------------------------------------------

    function _checkPerOpTreasuryCap(uint256 amountStable, uint256 bal) internal view {
        uint16 capBps = maxBuybackSharePerOpBps;
        if (capBps == 0) return;
        uint256 cap = (bal * capBps) / 10_000;
        if (amountStable > cap) revert BUYBACK_TREASURY_CAP_EXCEEDED();
    }

    /// @dev Rolling window cap expressed in BPS of a snapshot treasury basis.
    function _checkBuybackWindowCap(uint256 amountStable, uint256 bal) internal {
        uint64 dur = buybackWindowDuration;
        uint16 capBps = maxBuybackSharePerWindowBps;
        if (dur == 0 || capBps == 0) return;

        uint64 start = buybackWindowStart;
        if (start == 0 || block.timestamp >= uint256(start) + uint256(dur)) {
            buybackWindowStart = uint64(block.timestamp);
            buybackWindowAccumulatedBps = 0;
            buybackWindowStartStableBalance = bal;
        }

        uint256 basis = buybackWindowStartStableBalance;
        if (basis == 0) revert INSUFFICIENT_BALANCE();

        uint256 deltaBps = (amountStable * 10_000 + (basis - 1)) / basis;
        uint256 next = uint256(buybackWindowAccumulatedBps) + deltaBps;
        if (next > capBps) revert BUYBACK_TREASURY_WINDOW_CAP_EXCEEDED();
        buybackWindowAccumulatedBps = uint128(next);
    }

    function _checkOracleHealthGate() internal view {
        if (!oracleHealthGateEnforced) return;
        address module = oracleHealthModule;
        if (module == address(0)) revert BUYBACK_ORACLE_UNHEALTHY();
        if (!IOracleHealthModule(module).isHealthy()) revert BUYBACK_ORACLE_UNHEALTHY();
    }

    function _checkStrategyEnforcement() internal view {
        if (!strategiesEnforced) return;
        if (strategies.length == 0) revert NO_STRATEGY_CONFIGURED();

        bool found;
        for (uint256 i = 0; i < strategies.length; i++) {
            StrategyConfig storage cfg = strategies[i];
            if (cfg.enabled && cfg.asset == address(asset)) {
                found = true;
                break;
            }
        }
        if (!found) revert NO_ENABLED_STRATEGY_FOR_ASSET();
    }

    // -------------------------------------------------------------
    // Configuration
    // -------------------------------------------------------------

    function setMaxBuybackSharePerOpBps(uint16 newCapBps) external onlyDAO {
        if (newCapBps > 10_000) revert INVALID_AMOUNT();
        uint16 oldCap = maxBuybackSharePerOpBps;
        maxBuybackSharePerOpBps = newCapBps;
        emit BuybackTreasuryCapUpdated(oldCap, newCapBps);
    }

    function setBuybackWindowConfig(uint64 newDuration, uint16 newCapBps) external onlyDAO {
        require(newCapBps <= 10_000, "WINDOW_CAP_BPS_TOO_HIGH");
        uint64 oldDuration = buybackWindowDuration;
        uint16 oldCapBps = maxBuybackSharePerWindowBps;
        buybackWindowDuration = newDuration;
        maxBuybackSharePerWindowBps = newCapBps;
        buybackWindowStart = 0;
        buybackWindowAccumulatedBps = 0;
        buybackWindowStartStableBalance = 0;
        emit BuybackWindowConfigUpdated(oldDuration, newDuration, oldCapBps, newCapBps);
    }

    function setOracleHealthGateConfig(address newModule, bool newEnforced) external onlyDAO {
        address oldModule = oracleHealthModule;
        bool oldEnforced = oracleHealthGateEnforced;
        if (newEnforced && newModule == address(0)) revert ZERO_ADDRESS();
        oracleHealthModule = newModule;
        oracleHealthGateEnforced = newEnforced;
        emit BuybackOracleHealthGateUpdated(oldModule, newModule, oldEnforced, newEnforced);
    }

    // -------------------------------------------------------------
    // Strategy management
    // -------------------------------------------------------------

    function setStrategiesEnforced(bool enforced) external onlyDAO {
        strategiesEnforced = enforced;
        emit StrategyEnforcementUpdated(enforced);
    }

    function setStrategy(
        uint256 id,
        address asset_,
        uint16 weightBps_,
        bool enabled_
    ) external onlyDAO {
        if (asset_ == address(0)) revert ZERO_ADDRESS();

        StrategyConfig memory cfg = StrategyConfig({
            asset: asset_,
            weightBps: weightBps_,
            enabled: enabled_
        });

        if (id == strategies.length) {
            strategies.push(cfg);
        } else if (id < strategies.length) {
            strategies[id] = cfg;
        } else {
            revert INVALID_STRATEGY();
        }

        emit StrategyUpdated(id, asset_, weightBps_, enabled_);
    }

    function strategyCount() external view returns (uint256) {
        return strategies.length;
    }

    function getStrategy(uint256 id) external view returns (StrategyConfig memory) {
        if (id >= strategies.length) revert INVALID_STRATEGY();
        return strategies[id];
    }

    // -------------------------------------------------------------
    // Views
    // -------------------------------------------------------------

    function stableBalance() external view returns (uint256) {
        return stable.balanceOf(address(this));
    }

    function assetBalance() external view returns (uint256) {
        return asset.balanceOf(address(this));
    }
}
