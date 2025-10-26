pragma solidity ^0.8.20;

contract MockOracleAggregator {
    uint256 public priceWAD = 1e18;
    uint256 public lastUpdated = block.timestamp;
    function getPriceWAD(address) external view returns (uint256, uint256) {
        return (priceWAD, lastUpdated);
    }
    function setPrice(uint256 p) external { priceWAD = p; }
    function setTimestamp(uint256 t) external { lastUpdated = t; }
}
