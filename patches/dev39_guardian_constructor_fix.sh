#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_constructor_fix.tmp"

echo "== DEV-39 PATCH: Konstruktor-Zuweisung korrekt einrücken =="

# Backup
cp "$FILE" "$FILE.bak"

# Entferne fehlerhafte Zuweisung außerhalb des Blocks
sed -i '' '/safetyAutomata = _safety;/d' "$FILE"

# Füge sie korrekt in den Konstruktor ein
awk '
/constructor\(.*_safety/ && !done {
  print;
  print "        safetyAutomata = _safety;";
  done=1;
  next
}
{print}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Zuweisung in Konstruktor verschoben."

# Kompilieren & Testlauf
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
