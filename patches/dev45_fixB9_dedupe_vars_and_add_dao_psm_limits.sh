#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV45 FIX B9: dedupe collateralToken + add dao =="

# 1) Nicht-öffentliche Doppel-Deklaration entfernen
#    Wir löschen NUR die Zeile "MockERC20 collateralToken;"
#    (die Variante mit 'public' bleibt erhalten).
sed -i '' '/MockERC20 collateralToken;/d' "$FILE"

# 2) dao-State-Variable ergänzen, falls noch nicht vorhanden
grep -q "address public dao" "$FILE" || sed -i '' '/ParameterRegistry public reg;/a\
    address public dao = address(this);\
' "$FILE"

echo "✓ collateralToken deduped and dao added in PSMRegression_Limits"
