#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-43 Step 1: PSM Preflight Scan =="

echo ""
echo "[1] Core PSM contracts present:"
ls -1 contracts/psm || echo "MISSING: contracts/psm"

echo ""
echo "[2] PSMSwapCore MODULE_ID and key wiring:"
grep -n "MODULE_ID" contracts/psm/PSMSwapCore.sol || echo "No MODULE_ID in PSMSwapCore"
grep -n "OracleAggregator" contracts/psm/PSMSwapCore.sol || echo "No OracleAggregator import/usage"
grep -n "FeeRouterV2" contracts/psm/PSMSwapCore.sol || echo "No FeeRouterV2 import/usage"

echo ""
echo "[3] PSM.sol high-level API surface:"
sed -n '1,200p' contracts/psm/PSM.sol || echo "MISSING: contracts/psm/PSM.sol"

echo ""
echo "[4] PSMSwapCore.sol core swap logic (header + main function signatures):"
sed -n '1,200p' contracts/psm/PSMSwapCore.sol || echo "MISSING: contracts/psm/PSMSwapCore.sol"

echo ""
echo "[5] PSMLimits.sol limit types & DAO control:"
sed -n '1,200p' contracts/psm/PSMLimits.sol || echo "MISSING: contracts/psm/PSMLimits.sol"

echo ""
echo "[6] PSM-related tests currently in tree:"
ls -1 foundry/test | grep -E "PSM|SwapCore|Limits" || echo "No top-level PSM tests found"
ls -1 foundry/test/psm 2>/dev/null || echo "No foundry/test/psm/ directory"

echo ""
echo "[7] Existing PSM test files (limits & swap core):"
[ -f foundry/test/PSMLimits.t.sol ] && echo " - foundry/test/PSMLimits.t.sol" || echo " - PSMLimits.t.sol MISSING"
[ -f foundry/test/PSMSwapCore.t.sol ] && echo " - foundry/test/PSMSwapCore.t.sol" || echo " - PSMSwapCore.t.sol MISSING"

echo ""
echo "[8] Quick grep: PSM usage across contracts:"
grep -R "PSM.sol" -n contracts || true
grep -R "PSMSwapCore" -n contracts || true
grep -R "PSMLimits" -n contracts || true

echo ""
echo "[9] Safety / Oracle / Guardian touchpoints into PSM:"
grep -R "PSM" -n contracts/security || true
grep -R "PSM" -n contracts/core || true

echo ""
echo "== DEV-43 Step 1: Scan complete =="
