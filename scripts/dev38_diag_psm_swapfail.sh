#!/usr/bin/env bash
set -euo pipefail

OUT="logs/dev38_diag_psm_swapfail_$(date -u +'%Y%m%dT%H%M%SZ').log"
FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV-38 DIAG: swapTo1kUSD revert-Analyse ==" | tee "$OUT"
echo "UTC: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee -a "$OUT"

if [ -f "$FILE" ]; then
  echo -e "\n[1/3] Funktionsdefinitionen rund um swapTo1kUSD:" | tee -a "$OUT"
  awk '/function swapTo1kUSD/,/}/' "$FILE" | tee -a "$OUT"

  echo -e "\n[2/3] Alle require/assert/revert-Zeilen:" | tee -a "$OUT"
  grep -nE 'require|revert|assert' "$FILE" | tee -a "$OUT" || echo "Keine gefunden" | tee -a "$OUT"

  echo -e "\n[3/3] SafeERC20-Aufrufe (potenzielle Revertquellen):" | tee -a "$OUT"
  grep -nE 'SafeERC20|transfer|transferFrom' "$FILE" | tee -a "$OUT"
else
  echo "❌ Datei nicht gefunden: $FILE" | tee -a "$OUT"
fi

echo -e "\nLog gespeichert unter: $OUT" | tee -a "$OUT"
