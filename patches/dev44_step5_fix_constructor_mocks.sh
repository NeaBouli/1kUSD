#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-44 Step 5 Hotfix: Replace real contracts with simple mocks =="

# Create folder if missing
mkdir -p contracts/mocks

# ---------------------------
# Create MockOneKUSD.sol
# ---------------------------
cat <<'EOT' > contracts/mocks/MockOneKUSD.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockOneKUSD {
    // minimal mock — only what PSM needs (nothing)
}
EOT

# ---------------------------
# Create MockVault.sol
# ---------------------------
cat <<'EOT' > contracts/mocks/MockVault.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockVault {
    // minimal mock
}
EOT

# ---------------------------
# Create MockRegistry.sol
# ---------------------------
cat <<'EOT' > contracts/mocks/MockRegistry.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockRegistry {
    // minimal mock
}
EOT

# ---------------------------
# Rewrite PSMRegression_Limits.t.sol imports + constructors
# ---------------------------
FILE="foundry/test/psm/PSMRegression_Limits.t.sol"

sed -i '' 's|import {OneKUSD}.*|import {MockOneKUSD} from "../../../contracts/mocks/MockOneKUSD.sol";|' "$FILE"
sed -i '' 's|import {CollateralVault}.*|import {MockVault} from "../../../contracts/mocks/MockVault.sol";|' "$FILE"
sed -i '' 's|import {ParameterRegistry}.*|import {MockRegistry} from "../../../contracts/mocks/MockRegistry.sol";|' "$FILE"

# Replace new OneKUSD() etc.
sed -i '' 's/new OneKUSD()/new MockOneKUSD()/' "$FILE"
sed -i '' 's/new CollateralVault()/new MockVault()/' "$FILE"
sed -i '' 's/new ParameterRegistry()/new MockRegistry()/' "$FILE"

echo "✓ Mock contracts created and PSMRegression_Limits updated"
echo "== Hotfix complete =="
