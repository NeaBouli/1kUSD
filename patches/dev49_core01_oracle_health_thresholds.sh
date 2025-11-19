#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/OracleAggregator.sol"

echo "== DEV49 CORE01: rewrite OracleAggregator with stale/diff health gates =="

cat <<'SOL' > "$FILE"
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

import {IOracleAggregator} from "../interfaces/IOracleAggregator.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../interfaces/IParameterRegistry.sol";

/// @title OracleAggregator
/// @notice DEV-49: central oracle façade with SafetyAutomata pause-gate and
///         registry-driven health thresholds for staleness and price jumps.
///         This contract intentionally keeps all feeds mocked/settable for now;
///         production integrations would wire external feeds behind the same API.
contract OracleAggregator is IOracleAggregator {
    // --- Module identity for SafetyAutomata ---
    bytes32 public constant MODULE_ID = keccak256("ORACLE");

    // --- Registry keys (health parameters) ---
    // Maximal erlaubte Staleness in Sekunden; 0 => keine Stale-Prüfung.
    bytes32 private constant KEY_MAX_STALE = keccak256("oracle:maxStale");
    // Maximale zulässige Preisabweichung in Basispunkten gegenüber dem letzten Wert; 0 => keine Diff-Prüfung.
    bytes32 private constant KEY_MAX_DIFF_BPS = keccak256("oracle:maxDiffBps");

    // --- Dependencies ---
    ISafetyAutomata public immutable safety;
    IParameterRegistry public registry;
    address public admin;

    // --- Storage ---
    mapping(address => Price) private _mockPrice;

    // --- Events ---
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
    event OracleUpdated(address indexed asset, int256 price, uint8 decimals, bool healthy);

    // --- Errors ---
    error ZERO_ADDRESS();
    error ACCESS_DENIED();
    error PAUSED();

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

    // --- Modifiers ---
    modifier onlyAdmin() {
        if (msg.sender != admin) revert ACCESS_DENIED();
        _;
    }

    modifier notPaused() {
        if (safety.isPaused(MODULE_ID)) revert PAUSED();
        _;
    }

    // --- View helpers ---

    /// @notice Helper: read uint-Parameter aus Registry; 0 falls Registry nicht gesetzt.
    function _getUint(bytes32 key) internal view returns (uint256) {
        if (address(registry) == address(0)) {
            return 0;
        }
        return registry.getUint(key);
    }

    /// @inheritdoc IOracleAggregator
    function isOperational() external view override returns (bool) {
        return !safety.isPaused(MODULE_ID);
    }

    // --- Admin management ---

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

    // --- Price feed management (mocked in DEV-49) ---

    /// @notice Setzt einen Mock-Preis für ein Asset.
    /// @dev DEV-49: wendet zusätzlich Registry-basierte Health-Regeln an:
    ///      - negative/Nullpreise => unhealthy
    ///      - zu große Preisabweichung gegenüber letztem Wert => unhealthy
    function setPriceMock(address asset, int256 price, uint8 decimals, bool healthy)
        external
        onlyAdmin
        notPaused
    {
        // Negative oder Nullpreise sind grundsätzlich ungesund.
        if (price <= 0) {
            healthy = false;
        }

        Price memory prev = _mockPrice[asset];

        // Diff-Gate: nur wenn ein alter Preis existiert und ein Limit konfiguriert ist.
        uint256 maxDiffBps = _getUint(KEY_MAX_DIFF_BPS);
        if (maxDiffBps > 0 && prev.price > 0 && price > 0) {
            uint256 oldPrice = uint256(prev.price);
            uint256 newPrice = uint256(price);
            uint256 diff = newPrice > oldPrice ? (newPrice - oldPrice) : (oldPrice - newPrice);
            uint256 diffBps = (diff * 10_000) / oldPrice;
            if (diffBps > maxDiffBps) {
                healthy = false;
            }
        }

        _mockPrice[asset] = Price({
            price: price,
            decimals: decimals,
            healthy: healthy,
            updatedAt: block.timestamp
        });

        emit OracleUpdated(asset, price, decimals, healthy);
    }

    /// @inheritdoc IOracleAggregator
    function getPrice(address asset) external view override returns (Price memory p) {
        p = _mockPrice[asset];

        // Stale-Gate: optional über Registry steuerbar.
        uint256 maxStale = _getUint(KEY_MAX_STALE);
        if (maxStale == 0) {
            // Keine Staleness-Überwachung konfiguriert → rohen Wert zurückgeben.
            return p;
        }

        // Wenn es noch nie einen Preis gab (updatedAt == 0), bleibt Struct wie gespeichert.
        if (p.updatedAt == 0) {
            return p;
        }

        // Ist der Eintrag älter als maxStale, wird er als ungesund markiert.
        if (block.timestamp > p.updatedAt + maxStale) {
            p.healthy = false;
        }

        return p;
    }
}
SOL

echo "✓ DEV49 CORE01: OracleAggregator now applies registry-based stale/diff health checks"
