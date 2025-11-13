#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/security/Guardian.sol"
TMP="/tmp/Guardian_safety_fix.tmp"

echo "== DEV-39 PATCH: Guardian ⇄ SafetyAutomata Integration =="

# 1️⃣ Backup
cp "$FILE" "$FILE.bak"

# 2️⃣ Prüfen, ob Variable bereits existiert
if ! grep -q "ISafetyAutomata" "$FILE"; then
  awk '
  /address public admin/ && !done {
    print;
    print "    ISafetyAutomata public safetyAutomata; // <== added for SafetyAutomata link";
    done=1; next
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ Variable safetyAutomata hinzugefügt."
else
  echo "ℹ️ safetyAutomata bereits vorhanden – Überspringe."
fi

# 3️⃣ Konstruktor um Parameter & Zuweisung erweitern
if ! grep -q "safetyAutomata =" "$FILE"; then
  awk '
  /constructor/ && !patched {
    sub(/\) {/, ", ISafetyAutomata _safety) {");
    print;
    print "        safetyAutomata = _safety;";
    patched=1; next
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ Konstruktor angepasst und SafetyAutomata zugewiesen."
else
  echo "ℹ️ Konstruktor bereits gepatcht – Überspringe."
fi

# 4️⃣ Prüfung der betroffenen Codezeilen
grep -nE "constructor|safetyAutomata" "$FILE" | head -n 10

# 5️⃣ Kompilieren & Tests ausführen
echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true

