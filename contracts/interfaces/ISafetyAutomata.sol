// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

interface ISafetyAutomata {
    /// @notice Returns the exact timestamp at which Guardian authority expires.
    function guardianSunset() external view returns (uint256);

    /// @notice Returns whether a module is paused.
    function isPaused(bytes32 moduleId) external view returns (bool);

    /// @notice Returns whether a module is enabled.
    function isModuleEnabled(bytes32 moduleId) external view returns (bool);

    /// @notice Grants the temporary Guardian role.
    function grantGuardian(address guardian) external;

    /// @notice Revokes the temporary Guardian role.
    function revokeGuardian(address guardian) external;

    /// @notice Returns whether an account holds the Guardian role.
    /// @dev This reports role assignment only. Guardian pause authority still
    ///      expires at guardianSunset.
    function hasGuardianRole(address account) external view returns (bool);

    /// @notice Pauses a module.
    /// @dev Permanent ADMIN/DAO authority takes precedence over a caller's
    ///      Guardian role. Guardian-only authority expires at guardianSunset.
    function pauseModule(bytes32 moduleId) external;

    /// @notice Resumes a module through permanent ADMIN/DAO authority.
    function resumeModule(bytes32 moduleId) external;
}
