// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../interfaces/IParameterRegistry.sol";

/// @title SafetyAutomata — minimal skeleton
/// @notice DEV35: Admin/Wiring + Events; keine Caps-/RateLimit-Implementierung.
///         Alle Views liefern konservative Defaults; Setter existieren NICHT (später via Governance).
contract SafetyAutomata is ISafetyAutomata {
    // Module IDs werden extern definiert (z.B. keccak256("PSM"))
    // Admin & Registry
    address public admin; // Platzhalter (Timelock später)
    IParameterRegistry public registry;

    // Pausenzustände (rudimentär, kein Sunset/Governance in DEV35)
    mapping(bytes32 => bool) private _paused;

    // Events
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
    event Paused(bytes32 indexed moduleId, address indexed by);
    event Unpaused(bytes32 indexed moduleId, address indexed by);

    // Errors
    error ACCESS_DENIED();
    error ZERO_ADDRESS();

    constructor(address _admin, IParameterRegistry _registry) {
        if (_admin == address(0)) revert ZERO_ADDRESS();
        if (address(_registry) == address(0)) revert ZERO_ADDRESS();
        admin = _admin;
        registry = _registry;
        emit AdminChanged(address(0), _admin);
        emit RegistryUpdated(address(0), address(_registry));
    }

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

    function setRegistry(IParameterRegistry newRegistry) external onlyAdmin {
        if (address(newRegistry) == address(0)) revert ZERO_ADDRESS();
        emit RegistryUpdated(address(registry), address(newRegistry));
        registry = newRegistry;
    }

    // --- Pause Controls (Minimal; keine Sunset/Guardian-Policies in DEV35) ---
    function pause(bytes32 moduleId) external onlyAdmin {
        _paused[moduleId] = true;
        emit Paused(moduleId, msg.sender);
    }

    function unpause(bytes32 moduleId) external onlyAdmin {
        _paused[moduleId] = false;
        emit Unpaused(moduleId, msg.sender);
    }

    // --- ISafetyAutomata (Read-Only Surface) ---
    function isPaused(bytes32 moduleId) external view returns (bool) {
        return _paused[moduleId];
    }

    // Caps/RateLimits: in DEV35 noch nicht implementiert → konservative Defaults:
    function capOf(address /*asset*/) external pure returns (uint256) {
        // 0 bedeutet: kein definiertes Cap im Skeleton (später via Registry/Safety-Policy)
        return 0;
    }

    function moduleEnabled(bytes32 moduleId) external view returns (bool) {
        // Wenn nicht pausiert, betrachten wir das Modul als "enabled" im Skeleton.
        return !_paused[moduleId];
    }
}
