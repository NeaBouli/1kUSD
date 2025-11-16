#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-43 Step 3: Detailed PSM Scan + TODO Map =="

echo ""
echo "[1] Checking PegStabilityModule.sol (public PSM façade)..."
if [ -f contracts/core/PegStabilityModule.sol ]; then
    grep -n "swap" -n contracts/core/PegStabilityModule.sol || true
else
    echo "MISSING: contracts/core/PegStabilityModule.sol"
fi

echo ""
echo "[2] Checking PSMSwapCore.sol (internal core)..."
grep -n "swapCollateralForStable" contracts/psm/PSMSwapCore.sol
grep -n "feeRouter" contracts/psm/PSMSwapCore.sol
grep -n "oracle" contracts/psm/PSMSwapCore.sol

echo ""
echo "[3] Checking PSMLimits.sol..."
grep -n "checkAndUpdate" contracts/psm/PSMLimits.sol || true

echo ""
echo "[4] Checking FeeRouterV2 interface usage..."
grep -R "FeeRouterV2" -n contracts/psm || true
grep -R "FeeRouterV2" -n contracts/core || true

echo ""
echo "[5] Looking for SafetyAutomata enforcement (MODULE_ID = PSM)..."
grep -R "PSM" -n contracts/core || true
grep -R "PSM" -n contracts/psm || true

echo ""
echo "[6] Oracle usage (getPrice) inside PSM stack..."
grep -R "getPrice" -n contracts/psm || true
grep -R "getPrice" -n contracts/core/PegStabilityModule.sol 2>/dev/null || true

echo ""
echo "[7] Auto-TODO Generation:"
echo "----------------------------------------------"
echo "TODO#1  Add SafetyAutomata gate (whenNotPaused) in PegStabilityModule"
echo "TODO#2  Add PSMLimits.checkAndUpdate(...) to all external PSM swaps"
echo "TODO#3  Replace feeRouter .call(...) with IFeeRouterV2.route(...)"
echo "TODO#4  Add Oracle-health checks before swap"
echo "TODO#5  Create unified PSM events (PSMSwap, PSMFeesRouted)"
echo "TODO#6  Consolidate public entry into PegStabilityModule (canonical PSM)"
echo "TODO#7  Prepare price conversion stub (collateral → stable)"
echo "TODO#8  Add new regression tests under foundry/test/psm/"
echo "----------------------------------------------"

echo ""
echo "== DEV-43 Step 3 Scan Complete =="
