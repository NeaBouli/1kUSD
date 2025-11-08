#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/SafetyAutomata.sol"
TMP="/tmp/SafetyAutomata_cleanup_guardian.tmp"

echo "== DEV-39 CLEANUP: Entferne alte guardian != address(0) Block =="

cp "$FILE" "$FILE.bak"

# Entfernt die alten Zeilen mit dem alten Guardian-Block
awk '!/Auto-grant Guardian role for constructor-defined guardian/ && !/if \(guardian != address\(0\)\)/ && !/_grantRole\(GUARDIAN_ROLE, guardian\)/ && !/^\s*}\s*$/ {print}' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Alter guardian-Block entfernt."

echo
echo "== Forge Test: Guardian_OraclePropagation =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
