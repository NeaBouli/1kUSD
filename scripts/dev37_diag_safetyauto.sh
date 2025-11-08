#!/usr/bin/env bash
set -euo pipefail

OUT="logs/dev37_diag_safetyauto_$(date -u +'%Y%m%dT%H%M%SZ').log"
echo "== DEV37 DIAG: SafetyAutomata constructor & functions ==" | tee "$OUT"
echo "UTC: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee -a "$OUT"

FILE="contracts/core/SafetyAutomata.sol"

if [ -f "$FILE" ]; then
  echo -e "\n[1/3] pragma + imports:" | tee -a "$OUT"
  grep -nE '^(pragma|import)' "$FILE" | tee -a "$OUT"

  echo -e "\n[2/3] constructor & parameters:" | tee -a "$OUT"
  awk '/constructor/ {print NR": "$0; inblock=1} inblock && /\)/ {print NR": "$0; inblock=0}' "$FILE" | tee -a "$OUT"

  echo -e "\n[3/3] public/external functions list:" | tee -a "$OUT"
  awk '/function / && /(public|external)/ {print NR": "$0}' "$FILE" | tee -a "$OUT"
else
  echo "MISSING: $FILE" | tee -a "$OUT"
fi

echo -e "\nDone. Log saved to: $OUT" | tee -a "$OUT"
