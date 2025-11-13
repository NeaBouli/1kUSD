#!/usr/bin/env bash
set -euo pipefail

OUT="logs/dev36_preflight_$(date -u +'%Y%m%dT%H%M%SZ').log"
echo "== DEV36 PRE-FLIGHT CHECK ==" | tee "$OUT"
echo "UTC: $(date -u +'%Y-%m-%dT%H:%M:%SZ')" | tee -a "$OUT"

echo -e "\n[1/4] Check duplicate ISafetyAutomata files:" | tee -a "$OUT"
git ls-files | grep -E 'ISafetyAutomata\.sol$' | tee -a "$OUT" || true

echo -e "\n[2/4] Locate MockSafety references (could be inline):" | tee -a "$OUT"
grep -R --line-number "contract MockSafety" foundry/test | tee -a "$OUT" || echo "No MockSafety found" | tee -a "$OUT"

echo -e "\n[3/4] Current build & cache folders:" | tee -a "$OUT"
ls -al | grep -E 'out|cache' || echo "No cache/out folders present" | tee -a "$OUT"

echo -e "\n[4/4] solc version check:" | tee -a "$OUT"
forge --version | tee -a "$OUT"

echo -e "\nDone. Log saved to: $OUT" | tee -a "$OUT"
