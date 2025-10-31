// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

contract OracleAdapter {
    address public immutable dao;
    uint256 public price;
    uint256 public lastUpdated;

    event PriceUpdated(uint256 newPrice, uint256 timestamp);

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    constructor(address _dao) {
        dao = _dao;
    }

    function setPrice(uint256 newPrice) external onlyDAO {
        price = newPrice;
        lastUpdated = block.timestamp;
        emit PriceUpdated(newPrice, block.timestamp);
    }

    function getPrice() external view returns (uint256) {
        require(block.timestamp - lastUpdated < 1 days, "stale");
        return price;
    }
}
