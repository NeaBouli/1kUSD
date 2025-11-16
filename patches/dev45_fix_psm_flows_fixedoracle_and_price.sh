#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Fix: Repair FixedOracle and initialize price in setUp() =="

python3 - << 'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Flows.t.sol")
src = path.read_text()

# 1) FixedOracle-Block vollständig ersetzen
old_block = '''/// @dev Simple fixed oracle used for PSM flow regression.
///      Returns the same price for all assets; enough for DEV-45 tests.
contract FixedOracle is IOracleAggregator {
    Price private _p;

        _p = Price({price: price, decimals: decimals, healthy: healthy, updatedAt: block.timestamp});
    }

    function getPrice(address /*asset*/) external view returns (Price memory p) {
        p = _p;
    }

    function isOperational() external view returns (bool) {
        return _p.healthy;
    }
}
'''

new_block = '''/// @dev Simple fixed oracle used for PSM flow regression.
///      Returns the same price for all assets; enough for DEV-45 tests.
contract FixedOracle is IOracleAggregator {
    Price private _p;

    /// @notice Set a constant price for all assets used in the test.
    function setPrice(int256 price, uint8 decimals, bool healthy) external {
        _p = Price({
            price: price,
            decimals: decimals,
            healthy: healthy,
            updatedAt: block.timestamp
        });
    }

    function getPrice(address /*asset*/) external view returns (Price memory p) {
        p = _p;
    }

    function isOperational() external view returns (bool) {
        return _p.healthy;
    }
}
'''

if old_block not in src:
    raise SystemExit("Expected FixedOracle old_block not found; aborting to avoid corrupting file.")

src = src.replace(old_block, new_block)

# 2) setUp(): nach oracle-Instanziierung einen Preis setzen
# Wir suchen das Stück mit new OneKUSD / new MockERC20 / new FixedOracle
needle = '''        // --- 1) Core-Components ---
        oneKUSD = new OneKUSD(admin);
        collateral = new MockERC20("COLL", "COLL", 18);
        oracle = new FixedOracle();
'''

replacement = '''        // --- 1) Core-Components ---
        oneKUSD = new OneKUSD(admin);
        collateral = new MockERC20("COLL", "COLL", 18);
        oracle = new FixedOracle();
        // DEV-45: ensure oracle is operational with 1:1 price
        oracle.setPrice(int256(1e18), 18, true);
'''

if needle not in src:
    raise SystemExit("Expected setUp() core-component block not found; aborting to keep file consistent.")

src = src.replace(needle, replacement)

path.write_text(src)
PY

echo "✓ FixedOracle repaired and oracle price initialized in setUp()"
echo "== DEV-45 Fix Complete =="
