#!/usr/bin/env bash
set -euo pipefail
echo "🔧 DEV9 smoke: forge build & tests…"
forge clean
forge build
forge test -vvv --match-path 'foundry/test/DAO_Timelock.t.sol'
echo "✅ DEV9 smoke passed"
