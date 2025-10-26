// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {OneKUSD} from "./OneKUSD.sol";
import {ICollateralVault} from "../interfaces/ICollateralVault.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";

interface IParameterRegistry {
    function getUint(bytes32 key) external view returns (uint256);
}

contract PegStabilityModule is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DAO_ROLE   = keccak256("DAO_ROLE");

    OneKUSD public immutable oneKUSD;
    ICollateralVault public vault;
    ISafetyAutomata public safetyAutomata;
    IParameterRegistry public registry;

    uint256 public mintFeeBps;
    uint256 public redeemFeeBps;

    event FeesUpdated(uint256 mintFeeBps, uint256 redeemFeeBps);
    event SwappedTo1kUSD(address indexed user, address indexed asset, uint256 inAmount, uint256 out1kUSD, uint256 fee);
    event SwappedToCollateral(address indexed user, address indexed asset, uint256 in1kUSD, uint256 outAmount, uint256 fee);

    error PausedError();
    error UnsupportedAsset();
    error InsufficientOut();

    constructor(address admin, address oneKAddr, address vaultAddr, address safetyAddr, address regAddr) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        oneKUSD = OneKUSD(oneKAddr);
        vault = ICollateralVault(vaultAddr);
        safetyAutomata = ISafetyAutomata(safetyAddr);
        registry = IParameterRegistry(regAddr);
    }

    modifier whenNotPaused() {
        if (address(safetyAutomata) != address(0) && safetyAutomata.isPaused()) revert PausedError();
        _;
    }

    function setFees(uint256 _mint, uint256 _redeem) external {
        require(hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender), "unauthorized");
        mintFeeBps = _mint;
        redeemFeeBps = _redeem;
        emit FeesUpdated(_mint, _redeem);
    }

    function swapTo1kUSD(address asset, uint256 collateralAmount, uint256 minOut) external nonReentrant whenNotPaused {
        if (!vault.isSupportedAsset(asset)) revert UnsupportedAsset();
        vault.deposit(asset, msg.sender, collateralAmount);
        uint256 fee = (collateralAmount * mintFeeBps) / 10_000;
        uint256 outAmt = collateralAmount - fee;
        if (outAmt < minOut) revert InsufficientOut();
        oneKUSD.mint(msg.sender, outAmt);
        emit SwappedTo1kUSD(msg.sender, asset, collateralAmount, outAmt, fee);
    }

    function swapToCollateral(address asset, uint256 oneKAmount, uint256 minOut) external nonReentrant whenNotPaused {
        if (!vault.isSupportedAsset(asset)) revert UnsupportedAsset();
        oneKUSD.burn(msg.sender, oneKAmount);
        uint256 fee = (oneKAmount * redeemFeeBps) / 10_000;
        uint256 outAmt = oneKAmount - fee;
        if (outAmt < minOut) revert InsufficientOut();
        vault.withdraw(asset, msg.sender, outAmt);
        emit SwappedToCollateral(msg.sender, asset, oneKAmount, outAmt, fee);
    }
}
