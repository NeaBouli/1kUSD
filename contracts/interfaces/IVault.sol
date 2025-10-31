// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

interface IVault {
    /// @notice Called by PSM to deposit collateral into the TreasuryVault.
    /// @param token The ERC20 token address of the collateral.
    /// @param amount The amount to deposit.
    function depositCollateral(address token, uint256 amount) external;
}
