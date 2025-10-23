// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {IParameterRegistry} from "../interfaces/IParameterRegistry.sol";

/// @title ParameterRegistry — minimal skeleton
/// @notice DEV37: Admin kann Werte setzen; Module lesen über Getters.
///         Keine Validierungen, keine Timelock/DAO-Integration in dieser Stufe.
contract ParameterRegistry is IParameterRegistry {
    // --- Admin ---
    address public admin;

    // --- Storage ---
    mapping(bytes32 => uint256) private _uints;
    mapping(bytes32 => address) private _addresses;
    mapping(bytes32 => bool)    private _bools;

    // --- Events ---
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event UintSet(bytes32 indexed key, uint256 value);
    event AddressSet(bytes32 indexed key, address value);
    event BoolSet(bytes32 indexed key, bool value);

    // --- Errors ---
    error ACCESS_DENIED();
    error ZERO_ADDRESS();

    constructor(address _admin) {
        if (_admin == address(0)) revert ZERO_ADDRESS();
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    // --- Modifiers ---
    modifier onlyAdmin() {
        if (msg.sender != admin) revert ACCESS_DENIED();
        _;
    }

    // --- Admin ---
    function setAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert ZERO_ADDRESS();
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    // --- Setters (keine Validierungen in DEV37) ---
    function setUint(bytes32 key, uint256 value) external onlyAdmin {
        _uints[key] = value;
        emit UintSet(key, value);
    }

    function setAddress(bytes32 key, address value) external onlyAdmin {
        _addresses[key] = value;
        emit AddressSet(key, value);
    }

    function setBool(bytes32 key, bool value) external onlyAdmin {
        _bools[key] = value;
        emit BoolSet(key, value);
    }

    // --- IParameterRegistry (Read-only) ---
    function getUint(bytes32 key) external view returns (uint256) {
        return _uints[key];
    }

    function getAddress(bytes32 key) external view returns (address) {
        return _addresses[key];
    }

    function getBool(bytes32 key) external view returns (bool) {
        return _bools[key];
    }
}
