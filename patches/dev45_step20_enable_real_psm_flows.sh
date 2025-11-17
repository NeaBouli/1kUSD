#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV45 STEP 20: Enable REAL PSM flows (vault deposit + mint + fee route) =="

# Insert real transfer + vault deposit before mint
sed -i '' '/netOut = net1k;/i\
        // === DEV45: real token transfer + vault deposit + mint ===\
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(vault), amountIn);\
        vault.deposit(tokenIn, msg.sender, amountIn);\
        oneKUSD.mint(to, net1k);\
        if (fee1k > 0 && address(feeRouter) != address(0)) {\
            feeRouter.route("PSM_MINT_FEE", address(oneKUSD), fee1k);\
        }\
' "$FILE"

echo "✓ REAL PSM MINT FLOW ENABLED"
