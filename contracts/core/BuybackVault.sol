// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IOracleHealthModule { function isHealthy() external view returns (bool); }


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
    error ZERO_AMOUNT(); error BUYBACK_ORACLE_UNHEALTHY(); error BUYBACK_GUARDIAN_STOP();

    // --- Events ---

    /// @notice DAO hat Stable-Tokens in den Vault eingezahlt.
    event StableFunded(address indexed from, uint256 amount);

    /// @notice DAO hat einen Buyback ausgeführt (Stable in, Asset out).
        event StrategyEnforcementUpdated(bool enforced);
event StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled);
    event BuybackExecuted(address indexed recipient, uint256 stableIn, uint256 assetOut);

    struct StrategyConfig {
        address asset;
        uint16 weightBps;
        bool enabled;
    }

    StrategyConfig[] private strategies;
    bool public strategiesEnforced;



    /// @notice DAO hat Stable-Tokens aus dem Vault abgezogen.
    event StableWithdrawn(address indexed to, uint256 amount);

    /// @notice DAO hat Asset-Tokens aus dem Vault abgezogen.
    event AssetWithdrawn(address indexed to, uint256 amount);

    error NOT_DAO();
    error PAUSED();
error INVALID_AMOUNT();
error INSUFFICIENT_BALANCE();
error INVALID_STRATEGY();
error NO_STRATEGY_CONFIGURED();
error NO_ENABLED_STRATEGY_FOR_ASSET();
error BUYBACK_TREASURY_CAP_EXCEEDED();

    IERC20 public immutable stable;
    IERC20 public immutable asset;
    address public immutable dao;
    ISafetyAutomata public immutable safety;
    IPegStabilityModuleLike public immutable psm;
    bytes32 public immutable moduleId;

    /// @notice Maximum share of the vault's stable balance that can be spent
    ///         in a single buyback operation (in basis points, 1% = 100 bps).
    /// @dev A value of 0 disables the per-operation cap check.
    uint16 public maxBuybackSharePerOpBps; address public oracleHealthModule; bool public oracleHealthGateEnforced;
    uint16 public maxBuybackSharePerWindowBps;
    uint64 public buybackWindowDuration;
    uint64 public buybackWindowStart;
    uint128 public buybackWindowAccumulatedBps;

    event BuybackWindowConfigUpdated(
        uint64 oldDuration,
        uint64 newDuration,
        uint16 oldCapBps,
        uint16 newCapBps
    );


    event BuybackTreasuryCapUpdated(uint16 oldCapBps, uint16 newCapBps); event BuybackOracleHealthGateUpdated(address indexed oldModule, address indexed newModule, bool oldEnforced, bool newEnforced);


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

    // --- Stage A: Custody-Layer ---

    function fundStable(uint256 amount) external onlyDAO notPaused {
        if (amount == 0) revert ZERO_AMOUNT();
        stable.safeTransferFrom(msg.sender, address(this), amount);
        emit StableFunded(msg.sender, amount);
        emit FundStable(amount);
    }

    function withdrawStable(address to, uint256 amount) external onlyDAO notPaused {
        if (to == address(0)) revert ZERO_ADDRESS();
        if (amount == 0) revert ZERO_AMOUNT();
        stable.safeTransfer(to, amount);
        emit StableWithdrawn(to, amount);
        emit WithdrawStable(to, amount);
    }

    function withdrawAsset(address to, uint256 amount) external onlyDAO notPaused {
        if (to == address(0)) revert ZERO_ADDRESS();
        if (amount == 0) revert ZERO_AMOUNT();
        asset.safeTransfer(to, amount);
        emit AssetWithdrawn(to, amount);
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
        _checkPerOpTreasuryCap(amount1k); _checkOracleHealthGate();

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

        function _checkPerOpTreasuryCap(uint256 amountStable) internal view {
        uint16 capBps = maxBuybackSharePerOpBps;
        if (capBps == 0) {
            return;
        }
        uint256 bal = stable.balanceOf(address(this));
        uint256 cap = (bal * capBps) / 10_000;
        if (amountStable > cap) {
            revert BUYBACK_TREASURY_CAP_EXCEEDED();
        } } function _checkOracleHealthGate() internal view { if (!oracleHealthGateEnforced) { return; } address module = oracleHealthModule; if (module == address(0)) { revert BUYBACK_ORACLE_UNHEALTHY(); } if (!IOracleHealthModule(module).isHealthy()) { revert BUYBACK_ORACLE_UNHEALTHY(); } } // --- Views ---


        // --- Strategy config ---

    /// @notice Set the maximum share of the vault's stable balance that can be
    ///         spent in a single buyback operation.
    /// @dev Value is expressed in basis points (1% = 100 bps). A value of 0
    ///      disables the check.
    /// @param newCapBps New per-operation cap in basis points.
    function setMaxBuybackSharePerOpBps(uint16 newCapBps) external onlyDAO {
        if (newCapBps > 10_000) revert INVALID_AMOUNT();
        uint16 oldCap = maxBuybackSharePerOpBps;
        maxBuybackSharePerOpBps = newCapBps;
        emit BuybackTreasuryCapUpdated(oldCap, newCapBps);
    }
    /// @notice Configure the rolling buyback window.
    /// @dev A zero cap disables the window; duration is in seconds.
    function setBuybackWindowConfig(uint64 newDuration, uint16 newCapBps) external onlyDAO {
        require(newCapBps <= 10_000, "WINDOW_CAP_BPS_TOO_HIGH");
        uint64 oldDuration = buybackWindowDuration;
        uint16 oldCapBps = maxBuybackSharePerWindowBps;
        buybackWindowDuration = newDuration;
        maxBuybackSharePerWindowBps = newCapBps;
        // Reset window accounting; a later DEV-11 A03 patch will implement enforcement logic.
        buybackWindowStart = 0;
        buybackWindowAccumulatedBps = 0;
        emit BuybackWindowConfigUpdated(oldDuration, newDuration, oldCapBps, newCapBps);
    }
 function setOracleHealthGateConfig(address newModule, bool newEnforced) external onlyDAO { address oldModule = oracleHealthModule; bool oldEnforced = oracleHealthGateEnforced; if (newEnforced && newModule == address(0)) { revert ZERO_ADDRESS(); } oracleHealthModule = newModule; oracleHealthGateEnforced = newEnforced; emit BuybackOracleHealthGateUpdated(oldModule, newModule, oldEnforced, newEnforced); }



    function strategyCount() external view returns (uint256) {
        return strategies.length;
    }

    function getStrategy(uint256 id) external view returns (StrategyConfig memory) {
        if (id >= strategies.length) revert INVALID_STRATEGY();
        return strategies[id];
    }


    function setStrategiesEnforced(bool enforced) external {
        if (msg.sender != dao) revert NOT_DAO();
        strategiesEnforced = enforced;
        emit StrategyEnforcementUpdated(enforced);
    }

    function setStrategy(
        uint256 id,
        address asset_,
        uint16 weightBps_,
        bool enabled_
    ) external {
        if (msg.sender != dao) revert NOT_DAO();
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

function stableBalance() external view returns (uint256) {
        return stable.balanceOf(address(this));
    }

    function assetBalance() external view returns (uint256) {
        return asset.balanceOf(address(this));
    }


    /// @notice Execute a PSM-based buyback of the underlying asset using stable coins held in the vault.
    /// @param recipient Address that will receive the bought-back asset.
    /// @param amountStable Amount of stable (1kUSD) to spend.
    /// @param minAssetOut Minimum acceptable amount of asset to receive from PSM.
    /// @param deadline Unix timestamp after which the buyback is invalid.
    function executeBuyback(
        address recipient,
        uint256 amountStable,
        uint256 minAssetOut,
        uint256 deadline
    ) external {
        if (msg.sender != dao) revert NOT_DAO();
        if (recipient == address(0)) revert ZERO_ADDRESS();
        if (amountStable == 0) revert INVALID_AMOUNT();
        if (safety.isPaused(moduleId)) revert PAUSED();

        uint256 bal = stable.balanceOf(address(this));
        if (bal < amountStable) revert INSUFFICIENT_BALANCE();
        _checkPerOpTreasuryCap(amountStable); _checkOracleHealthGate();

        if (strategiesEnforced) {
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

        // Approve PSM to pull the requested stable amount
        stable.approve(address(psm), amountStable);

        uint256 assetOut = psm.swapFrom1kUSD(
            address(asset),
            amountStable,
            recipient,
            minAssetOut,
            deadline
        );

        emit BuybackExecuted(recipient, amountStable, assetOut);
    }

}
