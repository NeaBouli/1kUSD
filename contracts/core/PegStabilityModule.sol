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
import {IPSM} from "../interfaces/IPSM.sol";
import {IPSMEvents} from "../interfaces/IPSMEvents.sol"

contract PegStabilityModule is IPSM, IPSMEvents, AccessControl, ReentrancyGuard {
    bytes32 public constant MODULE_PSM = keccak256("PSM");

    modifier whenNotSafetyPaused() {
        require(!safetyAutomata.isPaused(MODULE_PSM), "PSM: paused by SafetyAutomata");
        _;
    }
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    OneKUSD public oneKUSD;
    CollateralVault public vault;
    ISafetyAutomata public safetyAutomata;
    ParameterRegistry public registry;

    uint256 public mintFeeBps;
    uint256 public redeemFeeBps;

    event FeesUpdated(uint256 mintFeeBps, uint256 redeemFeeBps);

    error PausedError();
    error InsufficientOut();

    modifier whenNotPaused() {
        if (address(safetyAutomata) != address(0) && safetyAutomata.isPaused(keccak256("PSM"))) {
            revert PausedError();
        }
        _;
    }

    constructor(address admin, address _oneKUSD, address _vault, address _auto, address _reg) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        oneKUSD = OneKUSD(_oneKUSD);
        vault = CollateralVault(_vault);
        safetyAutomata = ISafetyAutomata(_auto);
        registry = ParameterRegistry(_reg);
    }


    function _requireOracleHealthy(address token) internal view {
        /* DEV-43 stub: only health check, no price math yet */
        (, bool healthy, bool stale, ) = oracle.getPrice(token);
        require(healthy, "PSM: oracle unhealthy");
        require(!stale, "PSM: oracle price stale");
    }

    function _enforceLimits(address token, uint256 amount) internal {
        uint256 notional = amount; /* stub – DEV-44 real math */
        limits.checkAndUpdate(notional);
    }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        oneKUSD = OneKUSD(_oneKUSD);
        vault = CollateralVault(_vault);
        safetyAutomata = ISafetyAutomata(_auto);
        registry = ParameterRegistry(_reg);
    }

    // -------------------------------------------------------------
    // ✅ Interface Implementations
    // -------------------------------------------------------------

        emit SwapTo1kUSD(msg.sender, tokenIn, amountIn, fee, netOut, block.timestamp);
        return netOut;
    }

        view
        override
        returns (QuoteOut memory q)
    {
        uint256 fee = (amountIn * feeBps) / 10_000;
        uint256 net = amountIn - fee;
        q = QuoteOut(amountIn, fee, net, tokenInDecimals);
    }

    function quoteFrom1kUSD(
        address tokenOut,
        uint256 amountIn1k,
        uint16 feeBps,
        uint8 tokenOutDecimals
    ) external view override returns (QuoteOut memory q) {
        uint256 fee = (amountIn1k * feeBps) / 10_000;
        uint256 net = amountIn1k - fee;
        q = QuoteOut(amountIn1k, fee, net, tokenOutDecimals);
    }

    // -------------------------------------------------------------
    // ✅ Admin Management
    // -------------------------------------------------------------

    function setFees(uint256 mintFee, uint256 redeemFee) external onlyRole(ADMIN_ROLE) {
        mintFeeBps = mintFee;
        redeemFeeBps = redeemFee;
        emit FeesUpdated(mintFee, redeemFee);
    }
}
