#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/OracleAggregator.t.sol"
TMP="/tmp/MockSafety_grantguardian_fix.tmp"

echo "== DEV-39 PATCH: grantGuardian() Dummy in MockSafety ergänzen =="

cp "$FILE" "$FILE.bak"

# Nur hinzufügen, wenn noch nicht vorhanden
if ! grep -q "grantGuardian" "$FILE"; then
  awk '
  /contract MockSafety is ISafetyAutomata/ && !done {
    print;
    print "    function pauseModule(bytes32) external override {}";
    print "    function unpauseModule(bytes32) external override {}";
    print "    function grantGuardian(address) external override {}";
    done=1; next
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ grantGuardian() Dummy-Funktion in MockSafety ergänzt."
else
  echo "ℹ️ grantGuardian() bereits vorhanden."
fi

echo
echo "== Forge Build & Tests (Guardian_OraclePropagation) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
