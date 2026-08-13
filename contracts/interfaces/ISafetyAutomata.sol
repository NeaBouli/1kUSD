// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

interface ISafetyAutomata {
    /// @notice Returns whether a module is paused.
    function isPaused(bytes32 moduleId) external view returns (bool);

    /// @notice Returns whether a module is enabled.
    function isModuleEnabled(bytes32 moduleId) external view returns (bool);

    /// @notice Grants the temporary Guardian role.
    function grantGuardian(address guardian) external;

    /// @notice Pauses a module.
    /// @dev Permanent ADMIN/DAO authority takes precedence over a caller's
    ///      Guardian role. Guardian-only authority expires at guardianSunset.
    function pauseModule(bytes32 moduleId) external;

    /// @notice Resumes a module through permanent ADMIN/DAO authority.
    function resumeModule(bytes32 moduleId) external;
}
