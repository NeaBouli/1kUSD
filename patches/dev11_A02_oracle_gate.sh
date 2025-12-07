#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "== DEV-11 A02: add oracle/health gate stub to BuybackVault =="

# Stub-Funktion vor den Views einfügen
perl -0pi -e 's/\}\s*\}\s*\/\/ --- Views ---/} } function _checkOracleHealthGate() internal view { } \/\/ --- Views ---/g' contracts/core/BuybackVault.sol

# Stub in den PSM-Buyback hängen
perl -0pi -e 's/_checkPerOpTreasuryCap\(amount1k\);/_checkPerOpTreasuryCap(amount1k); _checkOracleHealthGate();/g' contracts/core/BuybackVault.sol

# Stub in den generischen Buyback hängen
perl -0pi -e 's/_checkPerOpTreasuryCap\(amountStable\);/_checkPerOpTreasuryCap(amountStable); _checkOracleHealthGate();/g' contracts/core/BuybackVault.sol

echo "== DEV-11 A02 oracle gate stub done =="

forge test
mkdocs build
