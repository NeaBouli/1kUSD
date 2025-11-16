#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Cleanup: Remove leftover oracle.setPriceMock artifact =="

# Lösche exakt die Zeilen, die setPriceMock enthalten (alte Fragmente)
sed -i '' '/setPriceMock/d' "$FILE"

# Lösche Zeilen, die mit 'n' enden (Artefakt aus früheren fehlerhaften Patches)
sed -i '' '/n$/d' "$FILE"

echo "✓ Leftover oracle.setPriceMock lines removed"
echo "== COMPLETE =="
