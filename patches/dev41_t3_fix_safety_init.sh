#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T3: Replace ZERO_ADDRESS init with valid dummy addresses =="

cp -n "$FILE" "${FILE}.bak" || true

awk '
  {
    line=$0
    # SafetyAutomata(admin, moduleId)  ->  use dummy nonzero admin (address(0xBEEF))
    gsub(/new SafetyAutomata\(address\(this\), 0\)/,
         "new SafetyAutomata(address(0xBEEF), 0)", line)
    print line
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ SafetyAutomata dummy admin injected (address(0xBEEF))."
