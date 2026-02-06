// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IFeeRouter} from "../interfaces/IFeeRouter.sol";

/**
 * @title FeeRouter
 * @notice Minimaler, zustandsloser Router im Push-Modell.
 *         Das Modul überweist die Fee zuerst an diesen Contract
 *         und ruft anschließend routeToTreasury(...) auf.
 *         Only whitelisted callers (e.g. PSM, FeeRouterV2) may invoke routeToTreasury.
 */
contract FeeRouter is IFeeRouter {
    using SafeERC20 for IERC20;

    address public admin;
    mapping(address => bool) public authorizedCallers;

    error ZeroAddress();
    error ZeroAmount();
    error NotAuthorized();

    event AuthorizedCallerSet(address indexed caller, bool enabled);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAuthorized();
        _;
    }

    modifier onlyAuthorized() {
        if (!authorizedCallers[msg.sender]) revert NotAuthorized();
        _;
    }

    constructor(address _admin) {
        if (_admin == address(0)) revert ZeroAddress();
        admin = _admin;
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert ZeroAddress();
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    function setAuthorizedCaller(address caller, bool enabled) external onlyAdmin {
        if (caller == address(0)) revert ZeroAddress();
        authorizedCallers[caller] = enabled;
        emit AuthorizedCallerSet(caller, enabled);
    }

    function routeToTreasury(
        address token,
        address treasury,
        uint256 amount,
        bytes32 tag
    ) external override onlyAuthorized {
        if (token == address(0) || treasury == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();

        // Tokens must already reside on this contract (push model).
        // Forward to the TreasuryVault.
        IERC20(token).safeTransfer(treasury, amount);

        emit FeeRouted(token, msg.sender, treasury, amount, tag);
    }
}
