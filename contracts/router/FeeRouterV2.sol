// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title FeeRouterV2 (Stub)
/// @notice Temporary placeholder for routing fees from modules (DEV-31)
contract FeeRouterV2 {
    event FeeRouted(bytes32 indexed key, address token, uint256 amount);

    function route(bytes32 key, address token, uint256 amount) external returns (bool) {
        emit FeeRouted(key, token, amount);
        return true;
    }
}
