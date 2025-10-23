// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IERC2612 — Minimal EIP-2612 Permit interface
interface IERC2612 {
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external;
}
