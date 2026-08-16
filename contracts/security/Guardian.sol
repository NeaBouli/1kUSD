// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";

contract Guardian {
    bytes32 public constant ORACLE_MODULE = keccak256("ORACLE");
    address public immutable dao;
    uint256 public immutable guardianSunset;
    ISafetyAutomata public safety;
    address public operator;

    event SafetyAutomataSet(address indexed safety);
    event OperatorUpdated(address indexed oldOperator, address indexed newOperator);

    error NotDAO();
    error NotOperator();
    error ZeroAddress();
    error SafetyNotSet();
    error GuardianExpired();
    error GuardianNotRegistered();
    error DirectResumeRequired();
    error SunsetMismatch();

    constructor(address dao_, uint256 guardianSunset_) {
        if (dao_ == address(0)) revert ZeroAddress();
        dao = dao_;
        guardianSunset = guardianSunset_;
        operator = dao_;
    }

    modifier onlyDAO() {
        if (msg.sender != dao) revert NotDAO();
        _;
    }
    modifier onlyOperator() {
        if (msg.sender != operator) revert NotOperator();
        _;
    }

    function setSafetyAutomata(ISafetyAutomata newSafety) external onlyDAO {
        if (address(newSafety) == address(0)) revert ZeroAddress();
        if (newSafety.guardianSunset() != guardianSunset) revert SunsetMismatch();
        safety = newSafety;
        emit SafetyAutomataSet(address(newSafety));
    }

    function setOperator(address newOperator) external onlyDAO {
        if (newOperator == address(0)) revert ZeroAddress();
        emit OperatorUpdated(operator, newOperator);
        operator = newOperator;
    }

    /// @notice Compatibility check for the legacy self-registration entrypoint.
    /// @dev Registration must be performed directly by the SafetyAutomata
    ///      administrator through grantGuardian(address). This function never
    ///      grants a role and therefore cannot self-escalate.
    function selfRegister() external view onlyDAO {
        if (address(safety) == address(0)) revert SafetyNotSet();
        if (!safety.hasGuardianRole(address(this))) revert GuardianNotRegistered();
    }

    function pauseOracle() external onlyOperator {
        if (address(safety) == address(0)) revert SafetyNotSet();
        if (block.timestamp >= guardianSunset) revert GuardianExpired();
        safety.pauseModule(ORACLE_MODULE);
    }

    /// @notice Disabled compatibility entrypoint for the legacy resume relay.
    /// @dev DAO/Timelock must call SafetyAutomata.resumeModule directly. The
    ///      Guardian contract must never receive permanent ADMIN/DAO authority.
    function resumeOracle() external view onlyDAO {
        if (address(safety) == address(0)) revert SafetyNotSet();
        revert DirectResumeRequired();
    }
}
