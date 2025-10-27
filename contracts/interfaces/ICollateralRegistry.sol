// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title ICollateralRegistry — canonical whitelist and metadata pointer for collateral assets
/// @notice Read-only surface for protocol modules; writes are governance-gated elsewhere.
interface ICollateralRegistry {
    /// @notice Emitted when an asset is (de)listed or metadata updated.
    event AssetListed(address indexed asset, bool listed);
    event AssetMetadataUpdated(address indexed asset, bytes32 metaHash);

    /// @notice Check if an asset is supported by the protocol.
    function isSupported(address asset) external view returns (bool);

    /// @notice Return ERC-20 decimals as cached/normalized info (advisory; prefer on-chain query on first use).
    function decimalsOf(address asset) external view returns (uint8);

    /// @notice Optional metadata content-address (e.g., keccak256 of JSON in /schemas).
    function metadataHash(address asset) external view returns (bytes32);
}
