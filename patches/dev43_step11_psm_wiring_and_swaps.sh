#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV-43 Step 11: Wire oracle/limits + add stub PSM swaps =="

# 1) Imports für PSMLimits und IOracleAggregator ergänzen
if ! grep -q "PSMLimits" "$FILE"; then
  sed -i '' '/import {ParameterRegistry} from ".\/ParameterRegistry.sol";/a\
import {PSMLimits} from "../psm/PSMLimits.sol";\
import {IOracleAggregator} from "../interfaces/IOracleAggregator.sol";\
' "$FILE"
fi

# 2) State-Variablen für limits & oracle hinzufügen
if ! grep -q "PSMLimits public limits;" "$FILE"; then
  sed -i '' '/ParameterRegistry public registry;/a\
    PSMLimits public limits;\
    IOracleAggregator public oracle;\
' "$FILE"
fi

# 3) _requireOracleHealthy-Stub korrigieren (struct statt Tuple)
if grep -q "_requireOracleHealthy(address token) internal view" "$FILE"; then
  perl -0pi -e 's/function _requireOracleHealthy\(address token\) internal view \{\n        \/\* DEV-43 stub: only health check, no price math yet \*\/\n        \(, bool healthy, bool stale, \) = oracle.getPrice\(token\);\n        require\(healthy, "PSM: oracle unhealthy"\);\n        require\(!stale, "PSM: oracle price stale"\);\n    \}/function _requireOracleHealthy\(address token\) internal view \{\n        \/\/ DEV-43 stub: only health check, no price math yet\n        IOracleAggregator.Price memory p = oracle.getPrice(token);\n        require(p.healthy, "PSM: oracle unhealthy");\n    \}/' "$FILE"
fi

# 4) Stub-Implementierungen für swapTo1kUSD / swapFrom1kUSD anhängen, falls noch nicht vorhanden
if ! grep -q "swapTo1kUSD(" "$FILE"; then
  cat <<'EOT' >> "$FILE"

    /// @inheritdoc IPSM
    function swapTo1kUSD(
        address tokenIn,
        uint256 amountIn,
        address to,
        uint256 minOut,
        uint256 /*deadline*/
    )
        external
        override
        whenNotSafetyPaused
        nonReentrant
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "PSM: amountIn=0");

        _requireOracleHealthy(tokenIn);
        _enforceLimits(tokenIn, amountIn);

        // DEV-43 stub: noch keine echte Mint/Transfer-Logik
        // amountOut ist aktuell 1:1 Stub – DEV-44 fügt Preis- & Transferlogik hinzu.
        amountOut = amountIn;
        if (amountOut < minOut) revert InsufficientOut();

        emit PSMSwapExecuted(msg.sender, tokenIn, amountIn, block.timestamp);
    }

    /// @inheritdoc IPSM
    function swapFrom1kUSD(
        address tokenOut,
        uint256 amountIn,
        address to,
        uint256 minOut,
        uint256 /*deadline*/
    )
        external
        override
        whenNotSafetyPaused
        nonReentrant
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "PSM: amountIn=0");

        _requireOracleHealthy(tokenOut);
        _enforceLimits(tokenOut, amountIn);

        // DEV-43 stub: symmetrisches 1:1-Verhalten
        amountOut = amountIn;
        if (amountOut < minOut) revert InsufficientOut();

        emit PSMSwapExecuted(msg.sender, tokenOut, amountIn, block.timestamp);
    }
EOT
fi

echo "✓ PegStabilityModule now has oracle/limits wiring and stubbed swap functions"
echo "== DEV-43 Step 11 Complete =="
