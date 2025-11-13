#!/usr/bin/env bash
set -euo pipefail

OUT="logs/dev37_diag_psm_guards_$(date -u +'%Y%m%dT%H%M%SZ').log"
FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV37 DIAG: PegStabilityModule pause guards ==" | tee "$OUT"
echo "UTC: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee -a "$OUT"

if [ -f "$FILE" ]; then
  echo -e "\n[1/4] pragma + imports:" | tee -a "$OUT"
  grep -nE '^(pragma|import)' "$FILE" | tee -a "$OUT"

  echo -e "\n[2/4] Functions using whenNotPaused / whenPaused / isPaused:" | tee -a "$OUT"
  grep -nE 'when(Not)?Paused|isPaused' "$FILE" | tee -a "$OUT" || echo "No pause guards found" | tee -a "$OUT"

  echo -e "\n[3/4] Functions that might revert on pause (require statements):" | tee -a "$OUT"
  grep -n "require" "$FILE" | grep -i paused || echo "No require(...paused...)" | tee -a "$OUT"

  echo -e "\n[4/4] Function headers for overview:" | tee -a "$OUT"
  awk '/function / {print NR": "$0}' "$FILE" | tee -a "$OUT"
else
  echo "MISSING: $FILE" | tee -a "$OUT"
fi

echo -e "\nDone. Log saved to: $OUT" | tee -a "$OUT"
