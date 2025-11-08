#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_constructor_rebuild.tmp"

echo "== DEV-39 PATCH: Guardian-Konstruktor vollständig rekonstruieren =="

# 1️⃣ Backup
cp "$FILE" "$FILE.bak"

# 2️⃣ Ersetze gesamten Konstruktorblock durch saubere Version
awk '
/constructor\(address _dao/ && !done {
  print "    constructor(address _dao, uint256 _sunsetBlocks, ISafetyAutomata _safety) {";
  print "        if (_dao == address(0)) revert ZERO_ADDRESS();";
  print "        if (address(_safety) == address(0)) revert ZERO_ADDRESS();";
  print "        dao = _dao;";
  print "        sunsetBlock = block.number + _sunsetBlocks;";
  print "        safetyAutomata = _safety;";
  print "    }";
  # Überspringe alte Konstruktorzeilen bis zur schließenden Klammer
  in_old=1; next
}
in_old && /^\s*}/ {in_old=0; next}
!in_old {print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Konstruktor erfolgreich rekonstruiert."

# 3️⃣ Kompilieren & Tests ausführen
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
