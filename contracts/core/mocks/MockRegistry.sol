// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../interfaces/IParameterRegistry.sol";

contract MockRegistry is IParameterRegistry {
    mapping(bytes32 => uint256) private uintParams;
    mapping(bytes32 => address) private addrParams;

    // --- full interface compatibility ---
    function getUint(bytes32 key) external view override returns (uint256) {
        return uintParams[key];
    }

    function getAddress(bytes32 key) external view override returns (address) {
        return addrParams[key];
    }

    // --- helper setters for tests ---
    function setUint(bytes32 key, uint256 value) external {
        uintParams[key] = value;
    }

    function setAddress(bytes32 key, address value) external {
        addrParams[key] = value;
    }
}
