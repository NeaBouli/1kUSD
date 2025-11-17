#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 17: Align PSMRegression_Flows.setUp with PSMSwapCore PSM config =="

# HINWEIS:
# In diesem Schritt MUSST du manuell die Konfig-Calls aus foundry/test/PSMSwapCore.t.sol
# in den markierten Block unten einfügen. Dieses Script legt nur einen klaren Anker.

# Füge einen Kommentar-Anker nach psm.setOracle(...) ein (falls noch nicht vorhanden)
grep -q "/// DEV45-CONFIG-ANCHOR" "$FILE" || sed -i '' '/psm.setOracle(address(oracle));/a\
        /// DEV45-CONFIG-ANCHOR: copy PSM asset/config setup from PSMSwapCore.t.sol here\
' "$FILE"

echo "✓ Anchor for PSM config inserted. Now copy config from PSMSwapCore.t.sol into this block."
