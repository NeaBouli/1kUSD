#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_add_safety_variable.tmp"

echo "== DEV-39 FINAL PATCH: Deklariere ISafetyAutomata-Instanz im Guardian =="

# Backup
cp "$FILE" "$FILE.bak"

# Prüfe, ob bereits vorhanden
if ! grep -q "ISafetyAutomata public safetyAutomata" "$FILE"; then
  awk '
  /uint256 public immutable sunsetBlock;/ && !done {
    print;
    print "    ISafetyAutomata public safetyAutomata; // <== added for Oracle propagation";
    done=1; next
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ safetyAutomata-Variable eingefügt."
else
  echo "ℹ️ Variable existiert bereits – überspringe."
fi

# Kompilieren & Tests
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
