#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/oracle/OracleRegression_Health.t.sol"

echo "== DEV49 CORE02: add OracleAggregator health regression tests (stale + diff) =="

cat <<'SOL' > "$FILE"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";

import "contracts/core/OracleAggregator.sol";
import "contracts/core/ParameterRegistry.sol";
import "contracts/core/SafetyAutomata.sol";
import "contracts/interfaces/IOracleAggregator.sol";

/// @notice Regression-Tests für OracleAggregator DEV-49:
///         - maxStale (oracle:maxStale)
///         - maxDiffBps (oracle:maxDiffBps)
contract OracleRegression_Health is Test {
    using stdStorage for StdStorage;

    OracleAggregator internal aggregator;
    ParameterRegistry internal registry;
    SafetyAutomata internal safety;
    address internal admin = address(this);

    // Repliziert die in OracleAggregator verwendeten Keys
    bytes32 internal constant KEY_MAX_STALE     = keccak256("oracle:maxStale");
    bytes32 internal constant KEY_MAX_DIFF_BPS  = keccak256("oracle:maxDiffBps");

    address internal constant ASSET = address(0xBEEF);

    function setUp() public {
        // Safety & Registry wie im Produktivpfad, aber minimal konfiguriert
        safety = new SafetyAutomata(admin, 0);
        registry = new ParameterRegistry(admin);
        aggregator = new OracleAggregator(admin, safety, registry);

        // SafetyAutomata ist default nicht pausiert → notPaused-Modifier passiert.
        assertTrue(aggregator.isOperational(), "oracle should start operational");
    }

    /// @notice Wenn maxStale == 0, darf getPrice() Health nicht durch Staleness ändern.
    function testMaxStaleZeroDoesNotAlterHealth() public {
        // explizit 0 setzen, auch wenn das der Default ist
        registry.setUint(KEY_MAX_STALE, 0);

        // Admin setzt einen gesunden Preis
        aggregator.setPriceMock(ASSET, int256(1_000e8), 8, true);

        IOracleAggregator.Price memory pNow = aggregator.getPrice(ASSET);
        assertTrue(pNow.healthy, "price should remain healthy when maxStale=0");

        // Warp weit in die Zukunft
        vm.warp(block.timestamp + 365 days);

        IOracleAggregator.Price memory pLater = aggregator.getPrice(ASSET);
        // Trotz Staleness bleibt healthy, weil maxStale=0 → Stale-Gate disabled
        assertTrue(pLater.healthy, "stale gate must be disabled when maxStale=0");
    }

    /// @notice Wenn maxStale > 0 und Eintrag älter als Threshold ist, wird healthy=false.
    function testMaxStaleMarksOldPriceUnhealthy() public {
        // Staleness-Threshold auf 1 Stunde setzen
        registry.setUint(KEY_MAX_STALE, 1 hours);

        aggregator.setPriceMock(ASSET, int256(1_000e8), 8, true);

        IOracleAggregator.Price memory pNow = aggregator.getPrice(ASSET);
        assertTrue(pNow.healthy, "fresh price should be healthy");

        // Zeit > maxStale vorwärtsspulen
        vm.warp(block.timestamp + 2 hours);

        IOracleAggregator.Price memory pLater = aggregator.getPrice(ASSET);
        assertFalse(pLater.healthy, "stale price must be marked unhealthy");
    }

    /// @notice Kleine Preisänderung unterhalb maxDiffBps bleibt gesund.
    function testMaxDiffBpsAllowsSmallJump() public {
        // 5 % maximale Abweichung
        registry.setUint(KEY_MAX_DIFF_BPS, 500); // 500 bps = 5 %

        // Baseline-Preis
        aggregator.setPriceMock(ASSET, int256(1_000e8), 8, true);

        IOracleAggregator.Price memory pBase = aggregator.getPrice(ASSET);
        assertTrue(pBase.healthy, "baseline price should be healthy");

        // +4 % Jump (unterhalb 5 %)
        aggregator.setPriceMock(ASSET, int256(1_040e8), 8, true);

        IOracleAggregator.Price memory pNew = aggregator.getPrice(ASSET);
        assertTrue(pNew.healthy, "small jump under threshold should stay healthy");
    }

    /// @notice Große Preisänderung oberhalb maxDiffBps wird als unhealthy markiert.
    function testMaxDiffBpsMarksLargeJumpUnhealthy() public {
        // 5 % maximale Abweichung
        registry.setUint(KEY_MAX_DIFF_BPS, 500); // 500 bps = 5 %

        // Baseline-Preis
        aggregator.setPriceMock(ASSET, int256(1_000e8), 8, true);

        IOracleAggregator.Price memory pBase = aggregator.getPrice(ASSET);
        assertTrue(pBase.healthy, "baseline price should be healthy");

        // +100 % Jump (1_000e8 -> 2_000e8) → 10_000 bps
        aggregator.setPriceMock(ASSET, int256(2_000e8), 8, true);

        IOracleAggregator.Price memory pNew = aggregator.getPrice(ASSET);
        assertFalse(pNew.healthy, "large jump above threshold must be unhealthy");
    }
}
SOL

echo "✓ DEV49 CORE02: OracleRegression_Health tests written to $FILE"
