// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IOracleAggregator — unified price access (interface)
interface IOracleAggregator {
    /// @notice Canonical price struct.
    /// @dev price uses `decimals` for fixed-point scaling; healthy=true if guards are satisfied.
    struct Price {
        int256 price;
        uint8 decimals;
        bool healthy;
        uint256 updatedAt;
    }

    /// @notice Get the current price snapshot for an asset.
    function getPrice(address asset) external view returns (Price memory p);
}
