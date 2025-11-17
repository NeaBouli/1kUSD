#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 18: Insert missing PSMConfig from PSMSwapCore =="

# Insert MockFeeRouter import if missing
grep -q "MockFeeRouter" "$FILE" || sed -i '' '/MockCollateralVault/a\
import {MockFeeRouter} from "../mocks/MockFeeRouter.sol";\
' "$FILE"


# Insert new state variable after vault declaration
grep -q "MockFeeRouter internal feeRouter;" "$FILE" || sed -i '' '/MockCollateralVault internal vault;/a\
    MockFeeRouter internal feeRouter;\
' "$FILE"


# Insert feeRouter instantiation after vault = new MockCollateralVault();
sed -i '' '/vault = new MockCollateralVault();/a\
        feeRouter = new MockFeeRouter();\
' "$FILE"


# Replace PSM constructor call with correct wiring
# OLD:
#   psm = new PegStabilityModule(dao, address(oneKUSD), address(vault), address(0), address(0));
#
# NEW:
#   psm = new PegStabilityModule(dao, address(oneKUSD), address(vault), address(feeRouter), address(stable));
sed -i '' 's/address(0),/address(feeRouter),/' "$FILE"
sed -i '' 's/address(0))/address(collateralToken))/' "$FILE"


# Give PSM stable liquidity (same as SwapCore: stable.mint(address(psm), supply))
sed -i '' '/collateralToken.mint(user, 1000e18);/a\
        oneKUSD.mint(address(psm), 2000e18);\
' "$FILE"

echo "✓ PSM config fully aligned with PSMSwapCore"
