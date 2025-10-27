// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {IOracleAggregator} from "../interfaces/IOracleAggregator.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../interfaces/IParameterRegistry.sol";

/// @title OracleAggregator — minimal+ (DEV42: admin mock prices for dev/staging)
/// @notice Admin-gated mock storage for devnets; NOT for mainnet usage.
///         Real aggregation to be implemented later (see ORACLE_AGGREGATOR_SPEC).
contract OracleAggregator is IOracleAggregator {
    bytes32 public constant MODULE_ID = keccak256("ORACLE");

    // Dependencies
    ISafetyAutomata public immutable safety;
    IParameterRegistry public registry;

    // Admin
    address public admin;

    // Mock Storage (DEV/STAGING ONLY)
    mapping(address => Price) private _mockPrice;

    // Events
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
    event OracleUpdated(address indexed asset, int256 price, uint8 decimals, bool healthy, uint256 updatedAt);

    // Errors
    error ACCESS_DENIED();
    error PAUSED();
    error ZERO_ADDRESS();

    constructor(address _admin, ISafetyAutomata _safety, IParameterRegistry _registry) {
        if (_admin == address(0)) revert ZERO_ADDRESS();
        if (address(_safety) == address(0)) revert ZERO_ADDRESS();
        if (address(_registry) == address(0)) revert ZERO_ADDRESS();

        admin = _admin;
        safety = _safety;
        registry = _registry;

        emit AdminChanged(address(0), _admin);
        emit RegistryUpdated(address(0), address(_registry));
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ACCESS_DENIED();
        _;
    }

    modifier notPaused() {
        if (safety.isPaused(MODULE_ID)) revert PAUSED();
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

    /// @notice DEV/STAGING ONLY: sets a mock price for an asset.
    /// @param asset Asset address (ERC-20 or similar)
    /// @param price Price value scaled by `decimals`
    /// @param decimals Number of decimals of price value
    /// @param healthy Health flag for guards (true = ok)
    function setPriceMock(address asset, int256 price, uint8 decimals, bool healthy) external onlyAdmin notPaused {
        _mockPrice[asset] = Price({
            price: price,
            decimals: decimals,
            healthy: healthy,
            updatedAt: block.timestamp
        });
        emit OracleUpdated(asset, price, decimals, healthy, block.timestamp);
    }

    /// @notice Returns the stored mock price (DEV/STAGING).
    function getPrice(address asset) external view override returns (Price memory p) {
        // DEV42: no real aggregation. Returns mock (default = zero struct).
        return _mockPrice[asset];
    }
}
