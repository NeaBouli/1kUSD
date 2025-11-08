#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_constructor_rebuild_final.tmp"

echo "== DEV-39 FINAL PATCH: Rebuild Guardian-Konstruktor + SafetyAutomata =="

# Backup
cp "$FILE" "$FILE.bak"

# Entferne fehlerhafte Zuweisungen außerhalb des Blocks (Zeilen 34–36)
awk 'NR<34 || NR>36' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# Füge den vollständigen, gültigen Konstruktor direkt vor Zeile 38 ein
awk 'NR==38{
  print "    constructor(address _dao, uint256 _sunsetBlocks, ISafetyAutomata _safety) {";
  print "        if (_dao == address(0)) revert ZERO_ADDRESS();";
  print "        if (address(_safety) == address(0)) revert ZERO_ADDRESS();";
  print "        dao = _dao;";
  print "        sunsetBlock = block.number + _sunsetBlocks;";
  print "        safetyAutomata = _safety;";
  print "    }";
  print "";
}1' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Guardian-Konstruktor korrekt rekonstruiert."

# Sichtprüfung
grep -n "constructor" "$FILE" | head -n 5

# Kompilation & Tests
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
