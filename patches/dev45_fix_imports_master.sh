#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 MASTER IMPORT REPAIR =="

###########
# 1) Remove ALL OracleAggregator and IOracleAggregator imports everywhere
###########
sed -i '' '/IOracleAggregator/d' "$FILE"
sed -i '' '/OracleAggregator/d' "$FILE"

echo "✓ Removed all scattered oracle imports"

###########
# 2) Insert correct imports at correct location
# After the OneKUSD import line
###########
sed -i '' '/OneKUSD/a\
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";\
import {OracleAggregator} from "../../../contracts/core/OracleAggregator.sol";\
' "$FILE"

echo "✓ Inserted correct imports below OneKUSD"

###########
# 3) Ensure FixedOracle header is correct (lines 10–20 block)
###########
sed -i '' '10,20c\
/// @dev Simple fixed oracle for DEV-45 regression tests\
contract FixedOracle is IOracleAggregator {\
    Price private _p;\
\
    function setPrice(int256 price, uint8 decimals, bool healthy) external {\
        _p = Price({price: price, decimals: decimals, healthy: healthy, updatedAt: block.timestamp});\
    }\
\
    function getPrice(address) external view returns (Price memory p) {\
        p = _p;\
    }\
\
    function isOperational() external view returns (bool) {\
        return _p.healthy;\
    }\
}' "$FILE"

echo "✓ Rebuilt FixedOracle block cleanly"

echo "== COMPLETE =="
