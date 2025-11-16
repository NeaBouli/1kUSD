#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV45 STEP 11B: Wire MockVault into PSMRegression_Flows =="

# Ersetze neutrales Vault-Placeholder durch neue Instanz
sed -i '' 's/vault = CollateralVault(address(0));/vault = new MockVault();/' "$FILE"

echo "✓ MockVault wired into test setup"
