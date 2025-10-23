// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title DAOTimelock — minimal skeleton
/// @notice DEV36: Admin wiring, queue/cancel/execute Events, parameter setters as stubs.
///         Keine tatsächliche Call-Execution/Timings/ETA-Checks in DEV36 (NOT_IMPLEMENTED).
contract DAOTimelock {
    // --- Admin ---
    address public admin; // Platzhalter (DAO/Governor später Besitzer)

    // --- Config (nur Platzhalter; ohne Logik) ---
    uint256 public minDelay; // Sekunden; in DEV36 nicht erzwungen

    // --- Events ---
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event MinDelayUpdated(uint256 oldDelay, uint256 newDelay);

    // Operations Lifecycle (IDs werden extern definiert; hier nur Events)
    event Queued(bytes32 indexed opId, address target, uint256 value, bytes data, uint256 eta);
    event Executed(bytes32 indexed opId, address target, uint256 value, bytes data);
    event Canceled(bytes32 indexed opId);

    // --- Errors ---
    error ACCESS_DENIED();
    error ZERO_ADDRESS();
    error NOT_IMPLEMENTED();

    constructor(address _admin, uint256 _minDelay) {
        if (_admin == address(0)) revert ZERO_ADDRESS();
        admin = _admin;
        minDelay = _minDelay;
        emit AdminChanged(address(0), _admin);
        emit MinDelayUpdated(0, _minDelay);
    }

    // --- Modifiers ---
    modifier onlyAdmin() {
        if (msg.sender != admin) revert ACCESS_DENIED();
        _;
    }

    // --- Admin fns (DAO übernimmt später) ---
    function setAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert ZERO_ADDRESS();
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    function setMinDelay(uint256 newDelay) external onlyAdmin {
        emit MinDelayUpdated(minDelay, newDelay);
        minDelay = newDelay;
    }

    // --- Operation Stubs (keine Exec-Logik in DEV36) ---
    function queue(bytes32 opId, address target, uint256 value, bytes calldata data, uint256 eta)
        external
        onlyAdmin
    {
        // DEV36: kein Storage der Operationen; nur Event
        emit Queued(opId, target, value, data, eta);
    }

    function cancel(bytes32 opId) external onlyAdmin {
        // DEV36: kein Status-Tracking; nur Event
        emit Canceled(opId);
    }

    function execute(bytes32 opId, address target, uint256 value, bytes calldata data)
        external
        payable
        onlyAdmin
    {
        // DEV36: keine Low-level-Call-Exec; nur Event & revert als Hinweis
        emit Executed(opId, target, value, data);
        revert NOT_IMPLEMENTED();
    }
}
