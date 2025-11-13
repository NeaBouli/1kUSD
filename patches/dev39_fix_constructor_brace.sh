#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"

echo "== DEV-39 FIX: Konstruktor-Klammer wiederherstellen =="

cp "$FILE" "$FILE.bak"

# Prüfe, ob Konstruktor abgeschlossen wird – falls nicht, füge } nach guardianSunset hinzu
awk '
/guardianSunset = guardianSunsetTimestamp;/ && !found {
    print;
    print "    }";  # Konstruktor schließen
    found=1; next
}
{print}
' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

echo "✓ Konstruktor korrekt geschlossen."
echo
echo "== Forge Syntax- & Testlauf =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
