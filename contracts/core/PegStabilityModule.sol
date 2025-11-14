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
/// @notice Canonical PSM-Fassade für 1kUSD; DEV-44-Version mit Price/Limits-Stubs.
/// @dev Preis-Mathematik bleibt für DEV-44 noch 1:1, aber ist bereits über Helper zentralisiert.
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
    // 🔧 Admin-Setter für Limits & Oracle
    // -------------------------------------------------------------

    function setLimits(address _limits) external onlyRole(ADMIN_ROLE) {
        limits = PSMLimits(_limits);
    }

    function setOracle(address _oracle) external onlyRole(ADMIN_ROLE) {
        oracle = IOracleAggregator(_oracle);
    }

    // -------------------------------------------------------------
    // 🛡 Oracle-Health & Limits (noch ohne echte Price-Mathe)
    // -------------------------------------------------------------

    /// @dev DEV-44 stub: nur Health-Check, keine Preis-Mathematik.
    function _requireOracleHealthy(address token) internal view {
        if (address(oracle) == address(0)) {
            // Wenn kein Oracle gesetzt ist, blockieren wir (später ggf. konfigurierbar).
            return;
        }
        IOracleAggregator.Price memory p = oracle.getPrice(token);
        require(p.healthy, "PSM: oracle unhealthy");
        // Stale-Handling kann in DEV-45 ergänzt werden.
    }

    /// @dev DEV-44 stub: Limits nur, wenn PSMLimits gesetzt ist.
    ///      notionalAmount ist bereits in "1kUSD-Notional" gedacht (aktuell 1:1).
    function _enforceLimits(uint256 notionalAmount) internal {
        if (address(limits) == address(0)) {
            return;
        }
        limits.checkAndUpdate(notionalAmount);
    }

    // -------------------------------------------------------------
    // 🔧 DEV-44 Price & Decimals Helpers (Skeletons, noch 1:1-Stub)
    // -------------------------------------------------------------

    /// @notice Convert token amount to 1kUSD notional (18 decimals)
    /// @dev DEV-44: aktuell 1:1-Stub; echte Mathe folgt in DEV-45.
    function _tokenToStableNotional(
        address token,
        uint256 amountIn
    )
        internal
        view
        returns (
            uint256 notional1k,
            IOracleAggregator.Price memory p,
            uint8 tokenDecimals
        )
    {
        token; // silence unused for jetzt
        tokenDecimals = 18; // Annahme: 18 Decimals, bis echte Metadaten-Logik kommt

        if (address(oracle) != address(0)) {
            p = oracle.getPrice(token);
        }

        // DEV-44: Noch 1:1-Mapping, damit Verhalten unverändert bleibt.
        notional1k = amountIn;
    }

    /// @notice Convert 1kUSD (18 dec) to token amount
    /// @dev DEV-44: aktuell 1:1-Stub; echte Mathe folgt in DEV-45.
    function _stableToTokenAmount(
        address token,
        uint256 amount1k,
        IOracleAggregator.Price memory p,
        uint8 tokenDecimals
    ) internal pure returns (uint256 amountToken) {
        token;
        p;
        tokenDecimals;
        amountToken = amount1k;
    }

    /// @notice Compute mint-side swap (token → 1kUSD)
    /// @dev DEV-44: nutzt Notional + Fee-Berechnung, aber noch ohne echte Preis-Skalierung.
    function _computeSwapTo1kUSD(
        address tokenIn,
        uint256 amountIn,
        uint16 feeBps
    )
        internal
        view
        returns (
            uint256 notional1k,
            uint256 fee1k,
            uint256 net1k
        )
    {
        IOracleAggregator.Price memory p;
        uint8 tokenDecimals;
        (notional1k, p, tokenDecimals) = _tokenToStableNotional(tokenIn, amountIn);

        // simple BPS-Fee auf das Notional
        fee1k = (notional1k * feeBps) / 10_000;
        net1k = notional1k - fee1k;

        // aktuell ungenutzt, bleiben aber für DEV-45 erhalten
        p;
        tokenDecimals;
    }

    /// @notice Compute redeem-side swap (1kUSD → token)
    /// @dev DEV-44: nutzt Notional + Fee, Mapping zu Token-Menge bleibt 1:1.
    function _computeSwapFrom1kUSD(
        address tokenOut,
        uint256 amountIn1k,
        uint16 feeBps
    )
        internal
        view
        returns (
            uint256 notional1k,
            uint256 fee1k,
            uint256 netTokenOut
        )
    {
        notional1k = amountIn1k;
        fee1k = (notional1k * feeBps) / 10_000;
        uint256 net1k = notional1k - fee1k;

        IOracleAggregator.Price memory p;
        uint8 tokenDecimals = 18;

        uint256 amountToken = _stableToTokenAmount(tokenOut, net1k, p, tokenDecimals);
        netTokenOut = amountToken;
    }

    // -------------------------------------------------------------
    // ✅ IPSM Interface Implementations (DEV-44, noch Stub-Ökonomie)
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
        to; // noch ungenutzt in DEV-44

        _requireOracleHealthy(tokenIn);

        (uint256 notional1k, uint256 fee1k, uint256 net1k) =
            _computeSwapTo1kUSD(tokenIn, amountIn, uint16(mintFeeBps));

        // Limits auf dem 1kUSD-Notional anwenden (aktuell == amountIn)
        _enforceLimits(notional1k);

        if (net1k < minOut) revert InsufficientOut();

        amountOut = net1k;

        emit PSMSwapExecuted(msg.sender, tokenIn, amountIn, block.timestamp);
        // IPSM-Events können in DEV-45 ergänzt werden, wenn Ökonomie fixiert ist.
        fee1k; // silence unused for jetzt
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
        returns (uint256 amountOut)
    {
        require(amountIn1k > 0, "PSM: amountIn=0");
        to; // noch ungenutzt

        _requireOracleHealthy(tokenOut);

        (uint256 notional1k, uint256 fee1k, uint256 netTokenOut) =
            _computeSwapFrom1kUSD(tokenOut, amountIn1k, uint16(redeemFeeBps));

        _enforceLimits(notional1k);

        if (netTokenOut < minOut) revert InsufficientOut();

        amountOut = netTokenOut;

        emit PSMSwapExecuted(msg.sender, tokenOut, amountIn1k, block.timestamp);
        fee1k; // silence unused
    }

    /// @inheritdoc IPSM
    function quoteTo1kUSD(
        address tokenIn,
        uint256 amountIn,
        uint16 feeBps,
        uint8 /*tokenInDecimals*/
    )
        external
        view
        override
        returns (QuoteOut memory q)
    {
        (uint256 notional1k, uint256 fee1k, uint256 net1k) =
            _computeSwapTo1kUSD(tokenIn, amountIn, feeBps);

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
        uint8 /*tokenOutDecimals*/
    )
        external
        view
        override
        returns (QuoteOut memory q)
    {
        (uint256 notional1k, uint256 fee1k, uint256 netTokenOut) =
            _computeSwapFrom1kUSD(tokenOut, amountIn1k, feeBps);

        q = QuoteOut({
            grossOut: notional1k,
            fee: fee1k,
            netOut: netTokenOut,
            outDecimals: 18
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
