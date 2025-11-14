// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IFeeRouterV2 — minimal interface for PSM fee routing
interface IFeeRouterV2 {
    /// @notice Route module-specific fees for a given token/amount
    /// @param moduleId keccak256 module identifier (e.g. keccak256("PSM"))
    /// @param token ERC20 token used for fee accounting
    /// @param amount nominal fee amount
    function route(bytes32 moduleId, address token, uint256 amount) external;
}
