#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_brace_fix.tmp"

echo "== DEV-39 STRUCTURAL FIX: Letzte geschweifte Klammern prüfen & reparieren =="

cp "$FILE" "$FILE.bak"

# Zähle öffnende/schließende Klammern
opens=$(grep -o '{' "$FILE" | wc -l | tr -d ' ')
closes=$(grep -o '}' "$FILE" | wc -l | tr -d ' ')

echo "→ Aktuelle Bilanz: { = \$opens, } = \$closes"

if [ "$opens" -gt "$closes" ]; then
  echo "⚙️  Eine schließende Klammer fehlt – füge am Ende eine hinzu."
  echo "}" >> "$FILE"
elif [ "$opens" -lt "$closes" ]; then
  echo "⚙️  Zu viele schließende Klammern – entferne letzte überzählige }."
  tac "$FILE" | awk 'NR==1 && $0~/^\s*}\s*$/ {next} {print}' | tac > "$TMP" && mv "$TMP" "$FILE"
else
  echo "✅ Klammern sind bereits ausgeglichen."
fi

echo
echo "== Forge Build (Syntaxcheck) =="
forge build || true
