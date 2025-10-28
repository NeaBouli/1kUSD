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
 */
contract FeeRouter is IFeeRouter {
    using SafeERC20 for IERC20;

    error ZeroAddress();
    error ZeroAmount();

    function routeToTreasury(
        address token,
        address treasury,
        uint256 amount,
        bytes32 tag
    ) external override {
        if (token == address(0) || treasury == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();

        // Token müssen bereits auf diesem Contract liegen (Push-Modell).
        // Transferiere weiter in den TreasuryVault.
        IERC20(token).safeTransfer(treasury, amount);

        emit FeeRouted(token, msg.sender, treasury, amount, tag);
    }
}
