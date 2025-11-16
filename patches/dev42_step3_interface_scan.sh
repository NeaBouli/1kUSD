#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-42 Step 3: Oracle interface & watcher scan =="

echo ""
echo "[1] IOracleAggregator — struct & signature"
sed -n '1,80p' contracts/interfaces/IOracleAggregator.sol || echo "MISSING: IOracleAggregator.sol"

echo ""
echo "[2] OracleAggregator — interface binding & getPrice() impl"
grep -n "contract OracleAggregator" -n contracts/core/OracleAggregator.sol || true
sed -n '1,140p' contracts/core/OracleAggregator.sol || echo "MISSING: OracleAggregator.sol"

echo ""
echo "[3] Price struct definition locations"
grep -R "struct Price" -n contracts/interfaces/IOracleAggregator.sol contracts/core || true

echo ""
echo "[4] All getPrice() callers (outside interface)"
grep -R "getPrice(" -n contracts foundry | grep -v "IOracleAggregator.sol" || echo "No external getPrice() callers found"

echo ""
echo "[5] IOracleWatcher interface"
sed -n '1,120p' contracts/interfaces/IOracleWatcher.sol || echo "MISSING: IOracleWatcher.sol"

echo ""
echo "[6] OracleWatcher implementation overview"
sed -n '1,200p' contracts/oracle/OracleWatcher.sol || echo "MISSING: OracleWatcher.sol"

echo ""
echo "[7] OracleWatcher ↔ interfaces cross-check"
echo "  - updateHealth / refreshState / isHealthy / getStatus usage:"
grep -n "updateHealth" -R contracts/oracle/OracleWatcher.sol foundry/test/oracle || true
grep -n "refreshState" -R contracts/oracle/OracleWatcher.sol foundry/test/oracle || true
grep -n "isHealthy" -R contracts/oracle/OracleWatcher.sol foundry/test/oracle || true
grep -n "getStatus" -R contracts/oracle/OracleWatcher.sol foundry/test/oracle || true

echo ""
echo "[8] SafetyAutomata / Guardian linkage quick check"
sed -n '1,140p' contracts/core/SafetyAutomata.sol || echo "MISSING: SafetyAutomata.sol"
echo ""
sed -n '1,140p' contracts/security/Guardian.sol || echo "MISSING: Guardian.sol"

echo ""
echo "== DEV-42 Step 3 scan complete =="
