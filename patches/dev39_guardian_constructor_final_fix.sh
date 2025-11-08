#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_constructor_final_fix.tmp"

echo "== DEV-39 FINAL PATCH: Repariere öffnende Klammer im Konstruktor =="

# Backup
cp "$FILE" "$FILE.bak"

# Entferne kaputten Block (alles von "constructor(" bis zur nächsten geschweiften Klammer)
awk '
/constructor\(address _dao/ {in_ctor=1; next}
in_ctor && /^\s*}/ {in_ctor=0; next}
!in_ctor {print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# Saubere Version des Konstruktors korrekt einfügen
awk '
/contract / && !done {
  print;
  print "";
  print "    constructor(address _dao, uint256 _sunsetBlocks, ISafetyAutomata _safety) {";
  print "        if (_dao == address(0)) revert ZERO_ADDRESS();";
  print "        if (address(_safety) == address(0)) revert ZERO_ADDRESS();";
  print "        dao = _dao;";
  print "        sunsetBlock = block.number + _sunsetBlocks;";
  print "        safetyAutomata = _safety;";
  print "    }";
  print "";
  done=1; next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Konstruktorblock sauber eingefügt."

# Sichtprüfung (zeigt alle relevanten Zeilen)
grep -n "constructor" "$FILE" | head -n 5

# Kompilation & Tests
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
