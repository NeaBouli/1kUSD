#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/OracleAggregator.t.sol"
TMP="/tmp/MockSafety_cleanup_dupes.tmp"

echo "== DEV-39 CLEANUP: Doppelte MockSafety-Funktionen entfernen =="

cp "$FILE" "$FILE.bak"

# Entfernt alle doppelten Funktionsdefinitionen und lässt nur die erste Instanz bestehen
awk '
/function pauseModule\(bytes32\)/ {count_pause++; if (count_pause>1) next}
 /function unpauseModule\(bytes32\)/ {count_unpause++; if (count_unpause>1) next}
 /function grantGuardian\(address\)/ {count_grant++; if (count_grant>1) next}
 {print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Doppelte Dummyfunktionen aus MockSafety entfernt."

echo
echo "-- Sichtprüfung MockSafety (Ausschnitt) --"
grep -A3 -B2 "contract MockSafety" "$FILE" | head -n 15

echo
echo "== Forge Build & Tests (Guardian_OraclePropagation) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
