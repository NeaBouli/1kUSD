// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";

contract MockOracleAggregator is IOracleAggregator {
    Price private _p;

    function setPrice(int256 price, uint8 decimals, bool healthy) external {
        _p = Price({
            price: price,
            decimals: decimals,
            healthy: healthy,
            updatedAt: block.timestamp
        });
    }

    function getPrice(address) external view returns (Price memory p) {
        return _p;
    }

    function isOperational() external view returns (bool) {
        return _p.healthy;
    }
}
