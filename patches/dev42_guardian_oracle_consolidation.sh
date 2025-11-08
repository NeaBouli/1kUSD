#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-42 Consolidation Patch: Oracle ⇄ SafetyAutomata ⇄ Guardian =="

# Validate key files exist
for file in \
  contracts/core/OracleAggregator.sol \
  contracts/core/SafetyAutomata.sol \
  contracts/interfaces/IOracleAggregator.sol \
  contracts/interfaces/ISafetyAutomata.sol \
  contracts/security/Guardian.sol \
  foundry/test/Guardian_OraclePropagation.t.sol; do
  if [ ! -f "$file" ]; then
    echo "❌ Missing expected file: $file"
    exit 1
  fi
done

echo "✅ All expected source files detected."

# Cleanup and build
forge clean
echo "🧩 Rebuilding project..."
forge build

echo "🧪 Running targeted Guardian ⇄ Oracle ⇄ SafetyAutomata tests..."
forge test --match-path "foundry/test/Guardian_OraclePropagation.t.sol" -vv

echo "✅ DEV-42 Consolidation complete. All components verified."
