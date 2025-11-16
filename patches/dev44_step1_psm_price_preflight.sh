#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-44 Step 1: PSM Price & Limits Preflight Scan =="

echo ""
echo "[1] PegStabilityModule.sol — swap/quote core (excerpt)..."
sed -n '80,260p' contracts/core/PegStabilityModule.sol || echo "MISSING: PegStabilityModule.sol slice"

echo ""
echo "[2] IOracleAggregator — Price struct & getPrice signature..."
sed -n '1,200p' contracts/interfaces/IOracleAggregator.sol || echo "MISSING: IOracleAggregator.sol"

echo ""
echo "[3] PSMLimits.sol — current limits model..."
sed -n '1,200p' contracts/psm/PSMLimits.sol || echo "MISSING: PSMLimits.sol"

echo ""
echo "[4] PSMSwapCore.sol — current core usage of feeRouter/oracle..."
sed -n '1,200p' contracts/psm/PSMSwapCore.sol || echo "MISSING: PSMSwapCore.sol"

echo ""
echo "[5] FeeRouter / IFeeRouterV2 references..."
grep -R "IFeeRouterV2" -n contracts || echo "No IFeeRouterV2 references found"
grep -R "FeeRouterV2" -n contracts || echo "No FeeRouterV2 direct references (good)"

echo ""
echo "[6] Decimals & metadata usage across contracts..."
grep -R "decimals(" -n contracts || echo "No direct decimals() usage found"
grep -R "IERC20Metadata" -n contracts || echo "No IERC20Metadata usage found"

echo ""
echo "[7] Oracle price usage inside PSM stack..."
grep -R "getPrice" -n contracts/core contracts/psm || echo "No getPrice usage in PSM stack"

echo ""
echo "[8] PSM regression tests currently present..."
ls -1 foundry/test/psm || echo "No foundry/test/psm directory or files"

echo ""
echo "[9] Quick sanity: IPSM + PegStabilityModule wiring..."
sed -n '1,120p' contracts/interfaces/IPSM.sol || echo "MISSING: IPSM.sol"
sed -n '1,120p' contracts/core/PegStabilityModule.sol || echo "MISSING: PegStabilityModule.sol header"

echo ""
echo "== DEV-44 Step 1 Preflight Scan Complete =="
