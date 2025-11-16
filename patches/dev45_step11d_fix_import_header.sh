#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 11D: Clean repair MockVault import header =="

# Entferne alle MockVault-Imports egal wo sie stehen
sed -i '' '/MockVault/d' "$FILE"

# Füge MockVault NUR im Header ein — direkt unter MockERC20
sed -i '' '/MockERC20/a\
import {MockVault} from "../mocks/MockVault.sol";\
' "$FILE"

echo "✓ Clean MockVault import header restored"
