#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/OracleAggregator.t.sol"
TMP="/tmp/MockSafety_stub_fix.tmp"

echo "== DEV-39 PATCH: Dummy-Funktionen in MockSafety ergänzen =="

# Backup
cp "$FILE" "$FILE.bak"

# Prüfen, ob bereits implementiert
if ! grep -q "pauseModule" "$FILE"; then
  awk '
  /contract MockSafety is ISafetyAutomata/ && !done {
    print;
    print "    function pauseModule(bytes32) external override {}";
    print "    function unpauseModule(bytes32) external override {}";
    done=1; next
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ pause/unpause in MockSafety ergänzt."
else
  echo "ℹ️ MockSafety bereits vollständig."
fi

echo "== Forge Kompilation & Tests =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
