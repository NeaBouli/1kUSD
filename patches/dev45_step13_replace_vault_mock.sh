#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

# Remove old MockVault import
sed -i '' '/MockVault/d' "$FILE"

# Add correct mock
sed -i '' '/MockERC20/a\
import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";\
' "$FILE"

# Replace vault instantiation
sed -i '' 's/vault = new MockVault()/vault = new MockCollateralVault()/' "$FILE"

