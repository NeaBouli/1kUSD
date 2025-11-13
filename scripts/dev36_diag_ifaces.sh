#!/usr/bin/env bash
set -euo pipefail

OUT="logs/dev36_diag_$(date -u +'%Y%m%dT%H%M%SZ').log"

echo "== DEV36 DIAG: ISafetyAutomata signature & imports ==" | tee "$OUT"
echo "UTC: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee -a "$OUT"

echo -e "\n[1/5] Interface file:" | tee -a "$OUT"
if [ -f contracts/interfaces/ISafetyAutomata.sol ]; then
  echo "contracts/interfaces/ISafetyAutomata.sol" | tee -a "$OUT"
  awk '/interface ISafetyAutomata/,/}/ {print}' contracts/interfaces/ISafetyAutomata.sol | sed -n '1,200p' | tee -a "$OUT"
else
  echo "MISSING: contracts/interfaces/ISafetyAutomata.sol" | tee -a "$OUT"
fi

echo -e "\n[2/5] SafetyAutomata implementation (if present):" | tee -a "$OUT"
if [ -f contracts/core/SafetyAutomata.sol ]; then
  echo "contracts/core/SafetyAutomata.sol" | tee -a "$OUT"
  grep -nE '^(import|pragma)' contracts/core/SafetyAutomata.sol || true | tee -a "$OUT"
  awk '/function isPaused|function isModuleEnabled|function globalPause/ {print NR": "$0}' contracts/core/SafetyAutomata.sol | tee -a "$OUT"
else
  echo "MISSING: contracts/core/SafetyAutomata.sol" | tee -a "$OUT"
fi

echo -e "\n[3/5] MockSafety (if present):" | tee -a "$OUT"
MOCK_FILE=$(git ls-files | grep -E 'MockSafety\.sol$' || true)
if [ -n "${MOCK_FILE:-}" ] && [ -f "$MOCK_FILE" ]; then
  echo "$MOCK_FILE" | tee -a "$OUT"
  grep -nE '^(import|pragma)' "$MOCK_FILE" || true | tee -a "$OUT"
  awk '/function isPaused|function isModuleEnabled|function globalPause/ {print NR": "$0}' "$MOCK_FILE" | tee -a "$OUT"
else
  echo "MockSafety not found by pattern 'MockSafety.sol' (ok if tests inline a mock)" | tee -a "$OUT"
fi

echo -e "\n[4/5] Forge clean & build (to capture the exact error):" | tee -a "$OUT"
rm -rf cache out || true
forge clean 2>&1 | tee -a "$OUT" || true
forge build 2>&1 | tee -a "$OUT" || true

echo -e "\n[5/5] Done. Log saved to: $OUT" | tee -a "$OUT"
