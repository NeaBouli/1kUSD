#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== HARD FIX: Replace broken FixedOracle block =="

# Entferne Zeilen 10–26 komplett
sed -i '' '10,26d' "$FILE"

# Füge neuen Oracle-Block nach Zeile 9 ein
sed -i '' '9a\
\
/// @dev Simple fixed oracle for DEV-45 regression tests\
contract FixedOracle is IOracleAggregator {\
    Price private _p;\
\
    function setPrice(int256 price, uint8 decimals, bool healthy) external {\
        _p = Price({\
            price: price,\
            decimals: decimals,\
            healthy: healthy,\
            updatedAt: block.timestamp\
        });\
    }\
\
    function getPrice(address /*asset*/) external view returns (Price memory p) {\
        p = _p;\
    }\
\
    function isOperational() external view returns (bool) {\
        return _p.healthy;\
    }\
}\
' "$FILE"

echo "✓ HARD FIX applied — FixedOracle fully replaced"
