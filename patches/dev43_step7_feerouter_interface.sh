#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-43 Step 7: Use IFeeRouterV2 interface in PSMSwapCore =="

FILE="contracts/psm/PSMSwapCore.sol"
IFACE="contracts/router/IFeeRouterV2.sol"

echo "• Ensuring IFeeRouterV2 interface exists ..."

mkdir -p contracts/router

cat <<'EOD' > "$IFACE"
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IFeeRouterV2 — minimal interface for PSM fee routing
interface IFeeRouterV2 {
    /// @notice Route module-specific fees for a given token/amount
    /// @param moduleId keccak256 module identifier (e.g. keccak256("PSM"))
    /// @param token ERC20 token used for fee accounting
    /// @param amount nominal fee amount
    function route(bytes32 moduleId, address token, uint256 amount) external;
}
EOD

echo "✓ IFeeRouterV2.sol written"

echo "• Patching $FILE ..."

# 1) Replace FeeRouterV2 import with IFeeRouterV2
if grep -q 'FeeRouterV2' "$FILE"; then
  sed -i '' 's|import "../router/FeeRouterV2.sol";|import "../router/IFeeRouterV2.sol";|' "$FILE"
fi

# 2) Change state variable type to IFeeRouterV2
sed -i '' 's/FeeRouterV2 public feeRouter;/IFeeRouterV2 public feeRouter;/' "$FILE"

# 3) Fix constructor assignment
sed -i '' 's/feeRouter = FeeRouterV2(_feeRouter);/feeRouter = IFeeRouterV2(_feeRouter);/' "$FILE"

# 4) Replace low-level .call() with typed interface call
#    from:
#      (bool ok, ) = address(feeRouter).call(
#          abi.encodeWithSignature("route(bytes32,address,uint256)", MODULE_ID, token, amountIn)
#      );
#      ok; // silence warnings
#    to:
#      feeRouter.route(MODULE_ID, token, amountIn);
if grep -q 'address(feeRouter).call' "$FILE"; then
  # Remove the whole low-level block and insert direct call
  perl -0pi -e 's/\(bool ok, \) = address\(feeRouter\)\.call\(\s*abi\.encodeWithSignature\("route\(bytes32,address,uint256\)", MODULE_ID, token, amountIn\)\s*\);\s*ok; \/\/ silence warnings/feeRouter.route(MODULE_ID, token, amountIn);/g' "$FILE"
fi

echo "✓ PSMSwapCore now uses IFeeRouterV2.route(...) directly"
echo "== DEV-43 Step 7 Complete =="
