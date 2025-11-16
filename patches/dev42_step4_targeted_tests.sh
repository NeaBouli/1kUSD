#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-42 Step 4: Targeted Oracle / Guardian tests =="

echo ""
echo "[1] Oracle regression watcher suite..."
forge test --match-path foundry/test/oracle/OracleRegression_Watcher.t.sol -vv || exit 1

echo ""
echo "[2] Oracle base regression suite..."
forge test --match-path foundry/test/oracle/OracleRegression_Base.t.sol -vv || exit 1

echo ""
echo "[3] Guardian ↔ Oracle propagation suite..."
forge test --match-path foundry/test/Guardian_OraclePropagation.t.sol -vv || exit 1

echo ""
echo "[4] Guardian integration smoke tests..."
forge test --match-path foundry/test/Guardian_Integration.t.sol -vv || exit 1

echo ""
echo "== DEV-42 Step 4: All targeted tests completed =="
