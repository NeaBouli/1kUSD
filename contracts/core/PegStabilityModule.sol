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
/// @notice Canonical PSM-facade for 1kUSD; DEV-44 version with real price-normalized
///         notional amounts for limits/quotes but without final asset transfers.
/// @dev All notional flows are expressed in 1kUSD (18 decimals) and fed into PSMLimits.
///      Actual token/vault flows are intentionally stubbed and follow in DEV-45.
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
    // 🔧 Oracle / Limits configuration
    // -------------------------------------------------------------

    /// @notice Admin setter for PSMLimits contract used for daily/tx caps.
    function setLimits(address _limits) external onlyRole(ADMIN_ROLE) {
        limits = PSMLimits(_limits);
    }

    /// @notice Admin setter for OracleAggregator used for PSM pricing.
    function setOracle(address _oracle) external onlyRole(ADMIN_ROLE) {
        oracle = IOracleAggregator(_oracle);
    }

    // -------------------------------------------------------------
    // 🔧 Internal helpers — oracle & limits
    // -------------------------------------------------------------

    /// @dev Light health gate: ensures oracle is operational if configured.
    function _requireOracleHealthy(address /*token*/) internal view {
        if (address(oracle) == address(0)) {
            // No oracle configured → do not block swaps (bootstrap/dev mode).
            return;
        }
        require(oracle.isOperational(), "PSM: oracle not operational");
    }

    /// @dev Enforce PSMLimits using 1kUSD notional amounts.
    function _enforceLimits(uint256 notional1k) internal {
        if (address(limits) == address(0)) {
            // No limits configured → no caps enforced.
            return;
        }
        limits.checkAndUpdate(notional1k);
    }

    // -------------------------------------------------------------
    // 🔧 Internal helpers — price & normalization
    // -------------------------------------------------------------

    /// @notice Fetch price for an asset from the oracle.
    /// @dev Returns (price, decimals) where `price` is scaled by `decimals`.
    function _getPrice(address asset) internal view returns (uint256 price, uint8 priceDecimals) {
        if (address(oracle) == address(0)) {
            // Fallback: 1.0 * 10^18 (1 token == 1 1kUSD) for tests/bootstrap.
            return (1e18, 18);
        }

        IOracleAggregator.Price memory p = oracle.getPrice(asset);
        require(p.healthy, "PSM: oracle unhealthy");
        require(p.price > 0, "PSM: bad price");

        return (uint256(p.price), p.decimals);
    }

    /// @notice Normalize a token amount into 1kUSD units using oracle price.
    /// @param amountToken Amount of collateral token in its smallest unit.
    /// @param tokenDecimals ERC-20 decimals for the collateral token.
    /// @param price Oracle price (scaled by priceDecimals).
    /// @param priceDecimals Decimals for price.
    /// @dev For DEV-44 we assume the oracle price is already aligned such that
    ///      1 token (10^tokenDecimals units) * price / 10^priceDecimals yields
    ///      a 1kUSD value with 18 decimals. This keeps math simple and audit-able.
    function _normalizeTo1kUSD(
        uint256 amountToken,
        uint8 tokenDecimals,
        uint256 price,
        uint8 priceDecimals
    ) internal pure returns (uint256 amount1k) {
        // Convert token amount to a 18-decimal representation:
        // amountToken (tokenDecimals) → scaled to 18
        if (tokenDecimals < 18) {
            uint8 diff = 18 - tokenDecimals;
            amountToken = amountToken * (10 ** diff);
        } else if (tokenDecimals > 18) {
            uint8 diff = tokenDecimals - 18;
            amountToken = amountToken / (10 ** diff);
        }

        // Apply price: (amountToken * price) / 10^priceDecimals
        uint256 scale = 10 ** uint256(priceDecimals);
        amount1k = (amountToken * price) / scale;
    }

    /// @notice Denormalize a 1kUSD amount back into token units using oracle price.
    /// @param amount1k Amount in 1kUSD units (18 decimals).
    /// @param tokenDecimals ERC-20 decimals for the collateral token.
    /// @param price Oracle price (scaled by priceDecimals).
    /// @param priceDecimals Decimals for price.
    function _normalizeFrom1kUSD(
        uint256 amount1k,
        uint8 tokenDecimals,
        uint256 price,
        uint8 priceDecimals
    ) internal pure returns (uint256 amountToken) {
        // Reverse of _normalizeTo1kUSD:
        // tokenAmount18 = (amount1k * 10^priceDecimals) / price
        uint256 scale = 10 ** uint256(priceDecimals);
        uint256 tokenAmount18 = (amount1k * scale) / price;

        if (tokenDecimals < 18) {
            uint8 diff = 18 - tokenDecimals;
            amountToken = tokenAmount18 / (10 ** diff);
        } else if (tokenDecimals > 18) {
            uint8 diff = tokenDecimals - 18;
            amountToken = tokenAmount18 * (10 ** diff);
        } else {
            amountToken = tokenAmount18;
        }
    }

    /// @notice Compute mint-side swap (token → 1kUSD) in notional terms.
    function _computeSwapTo1kUSD(
        address tokenIn,
        uint256 amountIn,
        uint16 feeBps,
        uint8 tokenInDecimals
    )
        internal
        view
        returns (
            uint256 notional1k,
            uint256 fee1k,
            uint256 net1k
        )
    {
        if (amountIn == 0) {
            return (0, 0, 0);
        }

        (uint256 px, uint8 pxDec) = _getPrice(tokenIn);
        notional1k = _normalizeTo1kUSD(amountIn, tokenInDecimals, px, pxDec);

        fee1k = (notional1k * feeBps) / 10_000;
        net1k = notional1k - fee1k;
    }

    /// @notice Compute redeem-side swap (1kUSD → token) in notional terms.
    function _computeSwapFrom1kUSD(
        address tokenOut,
        uint256 amountIn1k,
        uint16 feeBps,
        uint8 tokenOutDecimals
    )
        internal
        view
        returns (
            uint256 notional1k,
            uint256 fee1k,
            uint256 netTokenOut
        )
    {
        if (amountIn1k == 0) {
            return (0, 0, 0);
        }

        (uint256 px, uint8 pxDec) = _getPrice(tokenOut);

        // Notional in 1kUSD is the incoming amount itself.
        notional1k = amountIn1k;
        fee1k = (notional1k * feeBps) / 10_000;
        uint256 net1k = notional1k - fee1k;

        netTokenOut = _normalizeFrom1kUSD(net1k, tokenOutDecimals, px, pxDec);
    }

    // -------------------------------------------------------------
    // ✅ IPSM Interface Implementations (price-aware, no transfers)
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
        returns (uint256 netOut)
    {
        require(amountIn > 0, "PSM: amountIn=0");
        _requireOracleHealthy(tokenIn);

        // For DEV-44 we assume 18 decimals for tokenIn until registry wiring is added.
        uint8 tokenInDecimals = 18;

        (uint256 notional1k, uint256 fee1k, uint256 net1k) =
            _computeSwapTo1kUSD(tokenIn, amountIn, uint16(mintFeeBps), tokenInDecimals);

        _enforceLimits(notional1k);

        if (net1k < minOut) revert InsufficientOut();

        // DEV-44: no actual transfers/mints, only return net1k as simulated out.
        netOut = net1k;

        emit SwapTo1kUSD(msg.sender, tokenIn, notional1k, fee1k, net1k, block.timestamp);
        emit PSMSwapExecuted(msg.sender, tokenIn, amountIn, block.timestamp);
    }

    /// @inheritdoc IPSM
    function swapFrom1kUSD(
        address tokenOut,
        uint256 amountIn1k,
        address to,
        uint256 minOut,
        uint256 /*deadline*/
    )
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256 netOut)
    {
        require(amountIn1k > 0, "PSM: amountIn=0");
        _requireOracleHealthy(tokenOut);

        // For DEV-44 we assume 18 decimals for 1kUSD and derive tokenOut via oracle.
        uint8 tokenOutDecimals = 18;

        (uint256 notional1k, uint256 fee1k, uint256 netTokenOut) =
            _computeSwapFrom1kUSD(tokenOut, amountIn1k, uint16(redeemFeeBps), tokenOutDecimals);

        _enforceLimits(notional1k);

        if (netTokenOut < minOut) revert InsufficientOut();

        // DEV-44: no actual burns/withdrawals, only return net token amount.
        netOut = netTokenOut;

        emit SwapFrom1kUSD(msg.sender, tokenOut, notional1k, fee1k, netTokenOut, block.timestamp);
        emit PSMSwapExecuted(msg.sender, tokenOut, amountIn1k, block.timestamp);
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
        (uint256 notional1k, uint256 fee1k, uint256 net1k) =
            _computeSwapTo1kUSD(tokenIn, amountIn, feeBps, tokenInDecimals);

        q = QuoteOut({
            grossOut: notional1k,
            fee: fee1k,
            netOut: net1k,
            outDecimals: 18
        });
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
        (uint256 notional1k, uint256 fee1k, uint256 netTokenOut) =
            _computeSwapFrom1kUSD(tokenOut, amountIn1k, feeBps, tokenOutDecimals);

        q = QuoteOut({
            grossOut: notional1k,
            fee: fee1k,
            netOut: netTokenOut,
            outDecimals: tokenOutDecimals
        });
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
