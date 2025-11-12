#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"

echo "== DEV-41-T28: Remove accidental extra '{' inserted in setUp() =="

# Entferne doppelte '{' Zeilen direkt nach 'function setUp()'
sed -i.bak.t28 '/function setUp()/{
n
/^[[:space:]]*{/d
}' "$FILE"

echo "✅ Removed redundant opening brace after setUp()."
