// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/**
 * @title OracleAdapter
 * @notice Minimaler Feed-Adapter mit DAO-Kontrolle. Dient als Eingangsquelle für den OracleAggregator.
 */
contract OracleAdapter {
    address public dao;
    uint256 public lastPrice;
    uint256 public lastUpdate;
    uint256 public heartbeat = 3600; // 1h default

    event PricePushed(uint256 price, uint256 timestamp);
    event HeartbeatChanged(uint256 newHeartbeat);

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    constructor(address _dao) {
        dao = _dao;
    }

    function setPrice(uint256 price) external onlyDAO {
        lastPrice = price;
        lastUpdate = block.timestamp;
        emit PricePushed(price, block.timestamp);
    }

    function setHeartbeat(uint256 seconds_) external onlyDAO {
        heartbeat = seconds_;
        emit HeartbeatChanged(seconds_);
    }

    function latestPrice() external view returns (uint256) {
        require(block.timestamp - lastUpdate <= heartbeat, "stale price");
        return lastPrice;
    }

    function isStale() external view returns (bool) {
        return (block.timestamp - lastUpdate > heartbeat);
    }
}
