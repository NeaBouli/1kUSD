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
        safety = newSafety;
        emit SafetyAutomataSet(address(newSafety));
    }

    function setOperator(address newOperator) external onlyDAO {
        if (newOperator == address(0)) revert ZeroAddress();
        emit OperatorUpdated(operator, newOperator);
        operator = newOperator;
    }

    function selfRegister() external onlyDAO {
        if (address(safety) == address(0)) revert SafetyNotSet();
        safety.grantGuardian(address(this));
    }

    function pauseOracle() external onlyOperator {
        if (address(safety) == address(0)) revert SafetyNotSet();
        if (block.timestamp >= guardianSunset) revert GuardianExpired();
        safety.pauseModule(ORACLE_MODULE);
    }

    function resumeOracle() external onlyDAO {
        if (address(safety) == address(0)) revert SafetyNotSet();
        safety.resumeModule(ORACLE_MODULE);
    }
}
