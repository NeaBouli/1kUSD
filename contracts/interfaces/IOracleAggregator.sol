pragma solidity ^0.8.20;

interface IOracleAggregator {
    /// @notice Returns price in WAD (1e18) and last update timestamp (unix)
    function getPriceWAD(address asset) external view returns (uint256 priceWAD, uint256 lastUpdated);
}
