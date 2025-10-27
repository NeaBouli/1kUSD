// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";

/// @title SafetyAutomata
/// @notice Guardian/DAO-controlled pause switch per module (e.g., PSM, Vault, Registry).
contract SafetyAutomata is AccessControl, ISafetyAutomata {
    // Roles
    bytes32 public constant ADMIN_ROLE    = keccak256("ADMIN_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    bytes32 public constant DAO_ROLE      = keccak256("DAO_ROLE");

    /// @notice Timestamp after which the guardian can no longer pause new modules.
    uint256 public immutable guardianSunset;

    /// @dev Pause state per moduleId (true => paused).
    mapping(bytes32 => bool) private _paused;

    /// @notice Emitted when a module is paused.
    event Paused(bytes32 indexed moduleId, address indexed by);

    /// @notice Emitted when a module is resumed.
    event Resumed(bytes32 indexed moduleId, address indexed by);

    /// @notice Reverts when a guardian action is attempted after sunset.
    error GuardianExpired();

    /// @param admin Address receiving DEFAULT_ADMIN_ROLE and ADMIN_ROLE.
    /// @param guardianSunsetTimestamp UNIX timestamp when guardian powers sunset.
    constructor(address admin, uint256 guardianSunsetTimestamp) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        guardianSunset = guardianSunsetTimestamp;
    }

    // ------------------------------------------------------------------------
    // View API (Interface)
    // ------------------------------------------------------------------------

    /// @inheritdoc ISafetyAutomata
    function isPaused(bytes32 moduleId) external view override returns (bool) {
        return _paused[moduleId];
    }

    /// @notice Convenience inverse of isPaused (not part of the interface).
    function isModuleEnabled(bytes32 moduleId) external view returns (bool) {
        return !_paused[moduleId];
    }

    // ------------------------------------------------------------------------
    // Control API
    // ------------------------------------------------------------------------

    /// @notice Pause a specific module. Guardian may do so only before sunset.
    /// @dev DAO/ADMIN can also pause if desired; restrict to GUARDIAN_ROLE until sunset else ADMIN/DAO.
    function pauseModule(bytes32 moduleId) external {
        // Guardian allowed only before sunset
        if (hasRole(GUARDIAN_ROLE, msg.sender)) {
            if (block.timestamp >= guardianSunset) revert GuardianExpired();
        } else {
            // Non-guardian must be ADMIN or DAO
            require(
                hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender),
                "ACCESS_DENIED"
            );
        }

        _paused[moduleId] = true;
        emit Paused(moduleId, msg.sender);
    }

    /// @notice Resume a specific module. Requires ADMIN or DAO.
    function resumeModule(bytes32 moduleId) external {
        require(
            hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender),
            "ACCESS_DENIED"
        );
        _paused[moduleId] = false;
        emit Resumed(moduleId, msg.sender);
    }
}
