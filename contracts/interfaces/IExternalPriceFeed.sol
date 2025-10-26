// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Generic pull-based oracle interface used by OracleAggregator.
/// Implementations (adapters) should wrap Chainlink/Pyth/DEX-TWAP, etc.
interface IExternalPriceFeed {
    /// @return price  price as signed integer in feed-native decimals
    /// @return updatedAt unix timestamp of the last update
    /// @return decimals number of decimals the price uses
    function latestPrice() external view returns (int256 price, uint256 updatedAt, uint8 decimals);
}
