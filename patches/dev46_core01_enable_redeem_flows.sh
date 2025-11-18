#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV46 CORE01: Enable REAL redeem flows in swapFrom1kUSD =="

# 1) Alte DEV-44 Kommentarzeile entfernen (stimmt jetzt nicht mehr)
sed -i '' '/DEV-44: no actual burns\/withdrawals, only return net token amount\./d' "$FILE"

# 2) Redeem-Flow vor netOut-Zuweisung einfügen
sed -i '' '/netOut = netTokenOut;/i\
        // === DEV-46: real redeem flow (burn 1kUSD, withdraw collateral, transfer to `to`) ===\
        oneKUSD.burn(msg.sender, amountIn1k);\
        vault.withdraw(tokenOut, address(this), netTokenOut, bytes32("PSM_REDEEM"));\
        IERC20(tokenOut).safeTransfer(to, netTokenOut);\
' "$FILE"

echo "✓ swapFrom1kUSD now performs real burn + vault withdraw + transfer"
