// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {ICollateralVault} from "../interfaces/ICollateralVault.sol";

contract CollateralVault is AccessControl, ICollateralVault {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DAO_ROLE   = keccak256("DAO_ROLE");
    bytes32 public constant PSM_ROLE   = keccak256("PSM_ROLE");

    ISafetyAutomata public safetyAutomata;
    mapping(address => bool) public supportedAssets;
    mapping(address => uint256) public balances;

    event AssetSupported(address indexed asset, bool supported);
    event AssetDeposited(address indexed asset, address indexed from, uint256 amount);
    event AssetWithdrawn(address indexed asset, address indexed to, uint256 amount);
    event FeesSwept(address indexed asset, address indexed treasury, uint256 amount);

    error UnsupportedAsset();
    error PausedError();
    error Unauthorized();

    constructor(address admin, address safety) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        safetyAutomata = ISafetyAutomata(safety);
    }

    modifier whenNotPaused() {
        if (address(safetyAutomata) != address(0) && safetyAutomata.isPaused()) revert PausedError();
        _;
    }

    function addSupportedAsset(address asset) external whenNotPaused {
        if (!(hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender))) revert Unauthorized();
        supportedAssets[asset] = true;
        emit AssetSupported(asset, true);
    }

    function isSupportedAsset(address asset) public view override returns (bool) {
        return supportedAssets[asset];
    }

    function deposit(address asset, address from, uint256 amount) external override whenNotPaused onlyRole(PSM_ROLE) {
        if (!supportedAssets[asset]) revert UnsupportedAsset();
        IERC20(asset).safeTransferFrom(from, address(this), amount);
        balances[asset] += amount;
        emit AssetDeposited(asset, from, amount);
    }

    function withdraw(address asset, address to, uint256 amount) external override whenNotPaused {
        if (!(hasRole(PSM_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender))) revert Unauthorized();
        if (!supportedAssets[asset]) revert UnsupportedAsset();
        balances[asset] -= amount;
        IERC20(asset).safeTransfer(to, amount);
        emit AssetWithdrawn(asset, to, amount);
    }

    function sweepFees(address asset, address treasury, uint256 amount) external whenNotPaused {
        if (!hasRole(DAO_ROLE, msg.sender)) revert Unauthorized();
        IERC20(asset).safeTransfer(treasury, amount);
        balances[asset] -= amount;
        emit FeesSwept(asset, treasury, amount);
    }
}
