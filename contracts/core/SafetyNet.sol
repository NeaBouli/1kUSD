pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract SafetyNet is AccessControl {
    bytes32 public constant WATCHER_ROLE = keccak256("WATCHER_ROLE");

    event AlertRaised(address indexed watcher, bytes32 indexed reason, string detail, bool escalate);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /// @notice Watcher kann einen Alarm raisen (nur Event, keine Aktion)
    function raiseAlert(bytes32 reason, string calldata detail, bool escalate) external onlyRole(WATCHER_ROLE) {
        emit AlertRaised(msg.sender, reason, detail, escalate);
    }

    /// @notice Admin kann mehrere Watcher freischalten
    function grantWatchers(address[] calldata watchers) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < watchers.length; i++) {
            _grantRole(WATCHER_ROLE, watchers[i]);
        }
    }
}
