// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @notice Empty stub — see DAO_TIMELOCK_SPEC.md for future implementation.
contract DAOTimelock {
    event Queued(bytes32 indexed opId, uint256 eta);
    event Executed(bytes32 indexed opId);
    event Canceled(bytes32 indexed opId);
    // NOTE: Intentionally no state or logic in DEV29.
}
