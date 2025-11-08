#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/interfaces/ISafetyAutomata.sol"
TMP="/tmp/ISafetyAutomata_add_grantguardian.tmp"

echo "== DEV-39 PATCH: grantGuardian() in ISafetyAutomata Interface ergänzen =="

cp "$FILE" "$FILE.bak"

# Prüfen, ob bereits existiert
if ! grep -q "grantGuardian" "$FILE"; then
  awk '
  /function unpauseModule/ && !added {
    print;
    print "";
    print "    /// @notice Grants GUARDIAN_ROLE to a given address (for Guardian linkage)";
    print "    function grantGuardian(address guardian) external;";
    print "";
    added=1; next
  }
  {print}
  ' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
  echo "✓ grantGuardian() in ISafetyAutomata Interface hinzugefügt."
else
  echo "ℹ️ grantGuardian() bereits vorhanden."
fi

echo
echo "-- Sichtprüfung Interface --"
grep -n "grantGuardian" "$FILE" | head -n 5

echo
echo "== Forge Build & Tests (Guardian_OraclePropagation) =="
forge clean && forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv || true
