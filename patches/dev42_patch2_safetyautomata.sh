#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-42 Patch 2: SafetyAutomata.sol =="

cat > contracts/core/SafetyAutomata.sol <<"EOL"
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";

contract SafetyAutomata is AccessControl, ISafetyAutomata {
    bytes32 public constant ADMIN_ROLE    = keccak256("ADMIN_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    bytes32 public constant DAO_ROLE      = keccak256("DAO_ROLE");

    uint256 public immutable guardianSunset;
    mapping(bytes32 => bool) private _paused;

    event Paused(bytes32 indexed moduleId, address indexed by);
    event Resumed(bytes32 indexed moduleId, address indexed by);
    error GuardianExpired();

    constructor(address admin, uint256 guardianSunsetTimestamp) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(GUARDIAN_ROLE, admin);
        guardianSunset = guardianSunsetTimestamp;
    }

    function isPaused(bytes32 moduleId) external view override returns (bool) {
        return _paused[moduleId];
    }

    function isModuleEnabled(bytes32 moduleId) external view returns (bool) {
        return !_paused[moduleId];
    }

    function pauseModule(bytes32 moduleId) external override {
        if (hasRole(GUARDIAN_ROLE, msg.sender)) {
            if (block.timestamp >= guardianSunset) revert GuardianExpired();
        } else {
            require(
                hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender),
                "ACCESS_DENIED"
            );
        }
        _paused[moduleId] = true;
        emit Paused(moduleId, msg.sender);
    }

    function resumeModule(bytes32 moduleId) external override {
        require(
            hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender),
            "ACCESS_DENIED"
        );
        _paused[moduleId] = false;
        emit Resumed(moduleId, msg.sender);
    }

    function grantGuardian(address guardian) external override onlyRole(ADMIN_ROLE) {
        _grantRole(GUARDIAN_ROLE, guardian);
    }
}
EOL
echo "✅ SafetyAutomata.sol updated."
