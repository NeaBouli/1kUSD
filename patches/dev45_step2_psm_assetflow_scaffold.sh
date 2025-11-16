#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV-45 Step 2: Add asset-flow scaffold helpers to PegStabilityModule =="

# Nur einmal einfügen, falls noch nicht vorhanden
if grep -q "_pullCollateral(" "$FILE"; then
  echo "• Asset-flow helpers already present, skipping insert."
else
  awk '
  BEGIN { done = 0; }
  {
    # Vor der letzten schließenden Klammer des Contracts den Block einfügen
    if (!done && $0 ~ /^}/) {
      print "    // -------------------------------------------------------------";
      print "    // 💧 DEV-45: Asset flow & fee routing scaffold (stubs only)";
      print "    // -------------------------------------------------------------";
      print "";
      print "    /// @dev DEV-45: pull collateral from user into vault (stub, no-op for now)";
      print "    function _pullCollateral(address tokenIn, address from, uint256 amountIn) internal {";
      print "        // DEV-45.B: implement ERC-20 transfer + vault deposit";
      print "        tokenIn;";
      print "        from;";
      print "        amountIn;";
      print "    }";
      print "";
      print "    /// @dev DEV-45: push collateral from vault to user (stub, no-op for now)";
      print "    function _pushCollateral(address tokenOut, address to, uint256 amountOut) internal {";
      print "        // DEV-45.B: implement vault withdraw + ERC-20 transfer";
      print "        tokenOut;";
      print "        to;";
      print "        amountOut;";
      print "    }";
      print "";
      print "    /// @dev DEV-45: mint 1kUSD to recipient (stub, no-op for now)";
      print "    function _mint1kUSD(address to, uint256 amount1k) internal {";
      print "        // DEV-45.B: implement OneKUSD.mint(to, amount1k)";
      print "        to;";
      print "        amount1k;";
      print "    }";
      print "";
      print "    /// @dev DEV-45: burn 1kUSD from sender (stub, no-op for now)";
      print "    function _burn1kUSD(address from, uint256 amount1k) internal {";
      print "        // DEV-45.B: implement OneKUSD.burnFrom(from, amount1k) or equivalent";
      print "        from;";
      print "        amount1k;";
      print "    }";
      print "";
      print "    /// @dev DEV-45: route fee in 1kUSD-notional to fee router (stub, no-op for now)";
      print "    function _routeFee(address asset, uint256 feeAmount1k) internal {";
      print "        // DEV-45.B: integrate IFeeRouterV2.route(MODULE_PSM, asset, feeAmount1k)";
      print "        asset;";
      print "        feeAmount1k;";
      print "    }";
      print "";
      done = 1;
    }
    print;
  }' "$FILE" > "${FILE}.tmp"

  mv "${FILE}.tmp" "$FILE"
  echo "• Asset-flow helper stubs inserted into PegStabilityModule.sol"
fi

echo "✓ DEV-45 Step 2 complete (scaffold only, no behaviour change)"
