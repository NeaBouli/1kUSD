// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

interface ISafetyAutomata {
    function isPaused(bytes32 moduleId) external view returns (bool);
    function isModuleEnabled(bytes32 moduleId) external view returns (bool);
    function grantGuardian(address guardian) external;
    function pauseModule(bytes32 moduleId) external;
    function resumeModule(bytes32 moduleId) external;
}
