// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

interface IOracleAggregator {
    struct Price {
        int256 price;
        uint8 decimals;
        bool healthy;
        uint256 updatedAt;
    }
    function getPrice(address asset) external view returns (Price memory p);
    function isOperational() external view returns (bool);
}
