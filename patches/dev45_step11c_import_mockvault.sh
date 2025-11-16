#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 11C: Add MockVault import =="

# Füge Import direkt unter MockERC20 hinzu
sed -i '' '/MockERC20/a\
import {MockVault} from "../mocks/MockVault.sol";\
' "$FILE"

echo "✓ MockVault import added"
