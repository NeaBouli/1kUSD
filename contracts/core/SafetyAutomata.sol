// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";

contract SafetyAutomata is AccessControl, ISafetyAutomata {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    bool private _paused;
    uint256 public immutable guardianSunset;

    event Paused(address indexed by);
    event Resumed(address indexed by);
    error GuardianExpired();

    constructor(address admin, uint256 guardianSunsetTimestamp) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        guardianSunset = guardianSunsetTimestamp;
    }

    function isPaused(
        bytes32 /*moduleId*/
    )
        external
        view
        override
        returns (bool)
    {
        return _paused;
    }

    function pause() external onlyRole(GUARDIAN_ROLE) {
        if (block.timestamp >= guardianSunset) revert GuardianExpired();
        _paused = true;
        emit Paused(msg.sender);
    }

    function resume() external onlyRole(ADMIN_ROLE) {
        _paused = false;
        emit Resumed(msg.sender);
    }

    function isModuleEnabled(bytes32) external pure override returns (bool) {
        return true;
    }
}
