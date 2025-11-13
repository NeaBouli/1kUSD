#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T24: Remove extra ')' in SafetyAutomata mock constructor =="

cp -n "$FILE" "${FILE}.bak.t24" || true

# Korrigiere die doppelte Klammer am Ende
sed -E 's/SafetyAutomata\(address\(this\), 0\)\)/SafetyAutomata(address(this), 0)/' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Extra closing parenthesis removed from SafetyAutomata constructor."
