// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title TreasuryVault
 * @notice Multi-Asset Sink für Fees/Reserven. Empfang passiv (kein Role nötig),
 *         Auszahlungen/Sweeps nur über DAO_ROLE.
 */
contract TreasuryVault is AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DAO_ROLE   = keccak256("DAO_ROLE");

    event Swept(address indexed token, address indexed to, uint256 amount);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(DAO_ROLE, admin);
    }

    /**
     * @notice DAO kann Bestände an ein Ziel auszahlen (z. B. Treasury-Multisig).
     */
    function sweep(address token, address to, uint256 amount) external onlyRole(DAO_ROLE) {
        IERC20(token).safeTransfer(to, amount);
        emit Swept(token, to, amount);
    }
}
