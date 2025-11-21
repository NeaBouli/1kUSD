#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/oracle/OracleRegression_Base.t.sol"

echo "== DEV55 CORE01: clean up OracleRegression_Base harness =="

cat <<'SOL' > "$FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "contracts/core/OracleAggregator.sol";
import "contracts/core/ParameterRegistry.sol";
import "contracts/core/SafetyAutomata.sol";
import "contracts/oracle/OracleWatcher.sol";
import "contracts/interfaces/IParameterRegistry.sol";
import "contracts/interfaces/ISafetyAutomata.sol";

/// @notice Shared base harness for Oracle regression tests.
/// Sets up a fresh SafetyAutomata, ParameterRegistry and OracleAggregator
/// for each test suite that inherits from this contract.
contract OracleRegression_Base is Test {
    // Core components
    OracleAggregator internal aggregator;
    SafetyAutomata internal safetyImpl;
    ParameterRegistry internal registryImpl;

    // Exposed interfaces for child tests
    OracleWatcher internal watcher;
    ISafetyAutomata internal safety;
    IParameterRegistry internal registry;

    address internal admin = address(this);

    function setUp() public virtual {
        // Fresh Safety + Registry per test run
        safetyImpl = new SafetyAutomata(admin, 0);
        registryImpl = new ParameterRegistry(admin);

        safety = ISafetyAutomata(address(safetyImpl));
        registry = IParameterRegistry(address(registryImpl));

        // OracleAggregator wired against the mocks above
        aggregator = new OracleAggregator(admin, safetyImpl, registryImpl);
    }
}
SOL

echo "✓ OracleRegression_Base cleaned up and simplified"
