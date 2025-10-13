// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @notice Empty stub — see ORACLE_AGGREGATOR_SPEC.md for future implementation.
contract OracleAggregator {
    event OracleUpdated(address indexed asset, int256 price, uint8 decimals, bool healthy, uint256 updatedAt);
    // NOTE: Intentionally no state or logic in DEV29.
}
