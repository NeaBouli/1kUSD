#!/usr/bin/env bash
set -euo pipefail

echo "🧩 CI Environment Setup — 1kUSD Project"
mkdir -p lib

echo "📦 Installing OpenZeppelin Contracts v5.0.2 (deterministic)"
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 || true

echo "🔧 Writing remappings.txt"
echo '@openzeppelin/=lib/openzeppelin-contracts/' > remappings.txt

echo "🧹 Updating dependencies (forge update)"
forge update || true

if [ ! -d "lib/openzeppelin-contracts/contracts" ]; then
  echo "⚠️ OpenZeppelin not found — re-installing..."
  rm -rf lib/openzeppelin-contracts || true
  forge install OpenZeppelin/openzeppelin-contracts@v5.0.2
fi

echo "📄 remappings.txt contents:"
cat remappings.txt
echo "✅ CI setup complete"
