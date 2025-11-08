#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-42 Consolidation Runner =="

forge clean
forge build
forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv
echo "✅ All DEV-42 components verified."
