#!/usr/bin/env bash
set -euo pipefail

FILE="foundry/test/Guardian_PSMUnpause.t.sol"

echo "== DEV47 CORE02: make Guardian_PSMUnpause use no registry (address(0)) =="

# 1) Feld 'MockRegistry internal reg;' entfernen (Registry wird nicht mehr gehalten)
sed -i '' '/MockRegistry internal reg;/d' "$FILE"

# 2) Zeile 'reg = new MockRegistry();' aus setUp() entfernen
sed -i '' '/reg = new MockRegistry();/d' "$FILE"

# 3) PSM-Konstruktor so patchen, dass als letztes Argument address(0) übergeben wird
sed -i '' 's/address(vault), address(safety), address(reg))/address(vault), address(safety), address(0))/g' "$FILE"

echo "✓ Guardian_PSMUnpause now constructs PSM without registry (falls back to 18 decimals)."
