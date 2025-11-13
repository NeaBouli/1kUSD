#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-42 Step 1: Preflight Diagnostics =="

echo ""
echo "[1] Checking interface cohesion..."
grep -R "interface IOracleAggregator" -n contracts/interfaces || true
grep -R "interface IOracleWatcher" -n contracts/interfaces || true
grep -R "interface ISafetyAutomata" -n contracts/interfaces || true
grep -R "interface IParameterRegistry" -n contracts/interfaces || true

echo ""
echo "[2] Checking getPrice() consistency..."
grep -R "getPrice(" -n contracts || true

echo ""
echo "[3] Checking for duplicate struct Price definitions..."
grep -R "struct Price" -n contracts || true

echo ""
echo "[4] Checking OracleWatcher import wiring..."
grep -R "import { IOracleAggregator }" -n contracts/oracle/OracleWatcher.sol || true
grep -R "import { ISafetyAutomata }" -n contracts/oracle/OracleWatcher.sol || true

echo ""
echo "[5] Checking OracleAggregator MODULE_ID propagation..."
grep -R "MODULE_ID" -n contracts/core/OracleAggregator.sol || true
grep -R "MODULE_ID" -n contracts || true

echo ""
echo "[6] Detecting circular dependencies in contracts/..."
tsort <(grep -R "import" -n contracts | \
    sed 's/:.*import.*\"/ /' | sed 's/\".*//') 2>/dev/null || \
    echo "WARNING: potential cyclic imports detected (tsort failed)"

echo ""
echo "[7] Checking SafetyAutomata pause path..."
grep -R "isPaused" -n contracts/core/SafetyAutomata.sol || true

echo ""
echo "[8] Checking Guardian ↔ SafetyAutomata link..."
grep -R "Guardian" -n contracts/security || true
grep -R "pauseModule" -n contracts/security || true

echo ""
echo "[9] Checking Registry usage..."
grep -R "IParameterRegistry" -n contracts || true

echo ""
echo "[10] Static Simulation: Oracle pause path"
echo "Simulating: safety.isPaused(MODULE_ID) read-only..."
grep -R "isOperational" -n contracts/core/OracleAggregator.sol || true

echo ""
echo "== Preflight Diagnostics Complete =="
