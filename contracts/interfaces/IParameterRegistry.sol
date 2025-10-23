// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IParameterRegistry — on-chain parameters map (interface)
/// @notice Minimal read surface; write surface is governance-gated elsewhere.
interface IParameterRegistry {
    /// @notice Get an uint parameter by key.
    function getUint(bytes32 key) external view returns (uint256);

    /// @notice Get an address parameter by key.
    function getAddress(bytes32 key) external view returns (address);

    /// @notice Optional: composite per-asset key derivation (recommended off-chain).
    /// @dev Clients may use keccak256("PARAM_CAP_PER_ASSET", asset) convention.
}
