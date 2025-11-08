#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_remove_duplicate.tmp"

echo "== DEV-39 CLEANUP: Entferne doppelte unpauseModule()-Definition =="

# Backup
cp "$FILE" "$FILE.bak"

# Entferne alle unpauseModule() außer der ersten Definition
awk '
/function unpauseModule\(bytes32 moduleId\)/ {
  count++;
  if (count > 1) {
    skip=1; next
  }
}
skip && /^\s*}/ { skip=0; next }
!skip { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Doppelte unpauseModule()-Definition entfernt."

# Sichtprüfung
grep -n "unpauseModule" "$FILE" | head -n 5

# Kompilation & Testlauf
echo
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
