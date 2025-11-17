#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

echo "== DEV45 FIX B3: Replace MockOneKUSD with correct OneKUSD =="

# 1) Entferne nicht-existente MockOneKUSD-Importzeilen
sed -i '' '/MockOneKUSD/d' "$FILE"

# 2) Sicherstellen, dass OneKUSD importiert ist
grep -q 'import {OneKUSD}' "$FILE" || sed -i '' '/forge-std\/Test.sol/a\
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";\
' "$FILE"

# 3) Typ ersetzen
sed -i '' 's/MockOneKUSD/OneKUSD/g' "$FILE"

echo "✓ MockOneKUSD → OneKUSD fixed"
