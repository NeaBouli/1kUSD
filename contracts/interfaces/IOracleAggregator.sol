// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IOracleAggregator — price reads with health metadata
interface IOracleAggregator {
    struct Price {
        int256 price;        // 1e8 or 1e18 (impl-defined)
        uint8  decimals;     // decimals of 'price'
        bool   healthy;      // guards passed
        uint256 updatedAt;   // unix seconds
    }
    function getPrice(address asset) external view returns (Price memory);
}
