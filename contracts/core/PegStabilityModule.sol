// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {CollateralVault} from "./CollateralVault.sol";
import {OneKUSD} from "./OneKUSD.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {ParameterRegistry} from "./ParameterRegistry.sol";
import {PSMLimits} from "../psm/PSMLimits.sol";
import {IOracleAggregator} from "../interfaces/IOracleAggregator.sol";
import {IPSM} from "../interfaces/IPSM.sol";
import {IPSMEvents} from "../interfaces/IPSMEvents.sol";

/// @title PegStabilityModule
/// @notice Canonical PSM-Fassade für 1kUSD; DEV-43-Version mit Oracle-/Limits-Stubs.
contract PegStabilityModule is IPSM, IPSMEvents, AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MODULE_PSM = keccak256("PSM");

    OneKUSD public oneKUSD;
    CollateralVault public vault;
    ISafetyAutomata public safetyAutomata;
    ParameterRegistry public registry;
    PSMLimits public limits;
    IOracleAggregator public oracle;

    uint256 public mintFeeBps;
    uint256 public redeemFeeBps;

    event FeesUpdated(uint256 mintFeeBps, uint256 redeemFeeBps);

    error PausedError();
    error InsufficientOut();

    modifier whenNotPaused() {
        if (
            address(safetyAutomata) != address(0) &&
            safetyAutomata.isPaused(MODULE_PSM)
        ) {
            revert PausedError();
        }
        _;
    }

    constructor(
        address admin,
        address _oneKUSD,
        address _vault,
        address _auto,
        address _reg
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);

        oneKUSD = OneKUSD(_oneKUSD);
        vault = CollateralVault(_vault);
        safetyAutomata = ISafetyAutomata(_auto);
        registry = ParameterRegistry(_reg);
    }

    // -------------------------------------------------------------
    // 🔧 DEV-43: Oracle- und Limits-Stubs
    // -------------------------------------------------------------

    /// @notice Admin-Setter für PSMLimits-Contract
    function setLimits(address _limits) external onlyRole(ADMIN_ROLE) {
        limits = PSMLimits(_limits);
    }

    /// @notice Admin-Setter für OracleAggregator
    function setOracle(address _oracle) external onlyRole(ADMIN_ROLE) {

    // -------------------------------------------------------------n
    // 🔧 DEV-44 Price & Decimals Helpers (Skeletons, no logic yet)n
    // -------------------------------------------------------------n
    /// @notice Convert token amount to 1kUSD notional (18 decimals)n
    /// @dev DEV-44: logic added in next stepn
    function _tokenToStableNotional(n
        address token,n
        uint256 amountInn
    ) internal view returns (n
        uint256 notional1k,n
        IOracleAggregator.Price memory p,n
        uint8 tokenDecimalsn
    ) {n
        // TODO DEV-44: real math in next stepn
        notional1k = amountIn; // stubn
        tokenDecimals = 18; // stubn
        p = oracle.getPrice(token);n
    }n
n
    /// @notice Convert 1kUSD (18 dec) to token amountn
    /// @dev DEV-44: logic added in next stepn
    function _stableToTokenAmount(n
        address token,n
        uint256 amount1k,n
        IOracleAggregator.Price memory p,n
        uint8 tokenDecimalsn
    ) internal pure returns (uint256 amountToken) {n
        // TODO DEV-44: real math in next stepn
        amountToken = amount1k; // stubn
    }n
n
    /// @notice Compute mint-side swap (token → 1kUSD)n
    function _computeSwapTo1kUSD(n
        address tokenIn,n
        uint256 amountIn,n
        uint16 feeBpsn
    ) internal view returns (n
        uint256 notional1k,n
        uint256 fee1k,n
        uint256 net1kn
    ) {n
        // TODO DEV-44: real math in next stepn
        notional1k = amountIn;n
        fee1k = (notional1k * feeBps) / 10000;n
        net1k = notional1k - fee1k;n
    }n
n
    /// @notice Compute redeem-side swap (1kUSD → token)n
    function _computeSwapFrom1kUSD(n
        address tokenOut,n
        uint256 amountIn1k,n
        uint16 feeBpsn
    ) internal view returns (n
        uint256 notional1k,n
        uint256 fee1k,n
        uint256 netTokenOutn
    ) {n
        // TODO DEV-44: real math in next stepn
        notional1k = amountIn1k;n
        fee1k = (notional1k * feeBps) / 10000;n
        netTokenOut = notional1k - fee1k;n
    }n
        oracle = IOracleAggregator(_oracle);
    }

    /// @dev DEV-43 stub: nur Health-Check, keine Preis-Mathematik.
    function _requireOracleHealthy(address token) internal view {
        if (address(oracle) == address(0)) {
            // DEV-43: Wenn kein Oracle gesetzt ist, nicht blockieren.
            return;
        }
        IOracleAggregator.Price memory p = oracle.getPrice(token);
        require(p.healthy, "PSM: oracle unhealthy");
        // Stale-Handling kann in DEV-44/45 ergänzt werden.
    }

    /// @dev DEV-43 stub: Limits nur, wenn PSMLimits gesetzt ist.
    function _enforceLimits(uint256 notionalAmount) internal {
        if (address(limits) == address(0)) {
            return;
        }
        limits.checkAndUpdate(notionalAmount);
    }

    // -------------------------------------------------------------
    // ✅ IPSM Interface Implementations (DEV-43 stub logic)
    // -------------------------------------------------------------

    /// @inheritdoc IPSM
    function swapTo1kUSD(
        address tokenIn,
        uint256 amountIn,
        address to,
        uint256 minOut,
        uint256 /*deadline*/
    )
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "PSM: amountIn=0");

        // DEV-43: Health + Limits Stubs
        _requireOracleHealthy(tokenIn);
        _enforceLimits(amountIn);

        // DEV-43: einfache Gebührenberechnung (Stub)
        uint256 fee = (amountIn * mintFeeBps) / 10_000;
        uint256 netOut = amountIn - fee;

        if (netOut < minOut) revert InsufficientOut();

        // DEV-43: keine echten Transfers/Mint/Burn – folgt in DEV-44/45
        amountOut = netOut;

        emit PSMSwapExecuted(msg.sender, tokenIn, amountIn, block.timestamp);
    }

    /// @inheritdoc IPSM
    function swapFrom1kUSD(
        address tokenOut,
        uint256 amountIn,
        address to,
        uint256 minOut,
        uint256 /*deadline*/
    )
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "PSM: amountIn=0");

        // DEV-43: Health + Limits Stubs
        _requireOracleHealthy(tokenOut);
        _enforceLimits(amountIn);

        uint256 fee = (amountIn * redeemFeeBps) / 10_000;
        uint256 netOut = amountIn - fee;

        if (netOut < minOut) revert InsufficientOut();

        // DEV-43: Stub – reale Asset-Flows in DEV-44/45
        amountOut = netOut;

        emit PSMSwapExecuted(msg.sender, tokenOut, amountIn, block.timestamp);
    }

    /// @inheritdoc IPSM
    function quoteTo1kUSD(
        address tokenIn,
        uint256 amountIn,
        uint16 feeBps,
        uint8 tokenInDecimals
    )
        external
        view
        override
        returns (QuoteOut memory q)
    {
        uint256 fee = (amountIn * feeBps) / 10_000;
        uint256 net = amountIn - fee;
        q = QuoteOut(amountIn, fee, net, tokenInDecimals);
    }

    /// @inheritdoc IPSM
    function quoteFrom1kUSD(
        address tokenOut,
        uint256 amountIn1k,
        uint16 feeBps,
        uint8 tokenOutDecimals
    )
        external
        view
        override
        returns (QuoteOut memory q)
    {
        uint256 fee = (amountIn1k * feeBps) / 10_000;
        uint256 net = amountIn1k - fee;
        q = QuoteOut(amountIn1k, fee, net, tokenOutDecimals);
    }

    // -------------------------------------------------------------
    // 🔐 Admin Management
    // -------------------------------------------------------------

    function setFees(uint256 mintFee, uint256 redeemFee)
        external
        onlyRole(ADMIN_ROLE)
    {
        mintFeeBps = mintFee;
        redeemFeeBps = redeemFee;
        emit FeesUpdated(mintFee, redeemFee);
    }
}
