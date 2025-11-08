#!/usr/bin/env bash
set -euo pipefail

OUT="logs/dev36_diag_mocks_$(date -u +'%Y%m%dT%H%M%SZ').log"
echo "== DEV36 DIAG: MOCK SAFETY ==" | tee "$OUT"
echo "UTC: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee -a "$OUT"

for f in foundry/test/OracleAggregator.t.sol foundry/test/MockSafetyAutomata.sol; do
  if [ -f "$f" ]; then
    echo -e "\n--- Inspecting: $f ---" | tee -a "$OUT"
    grep -nE '^(pragma|import|contract|function)' "$f" | tee -a "$OUT"
  fi
done

echo -e "\nDone. Log saved to: $OUT" | tee -a "$OUT"
