// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IParameterRegistry — canonical parameter map (read-only surface)
interface IParameterRegistry {
    function getUint(bytes32 key) external view returns (uint256);
    function getAddress(bytes32 key) external view returns (address);
    function getBool(bytes32 key) external view returns (bool);
}
