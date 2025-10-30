#!/usr/bin/env bash
set -euxo pipefail
echo "🧩 CI Environment Setup (deterministic)"

forge --version

# Pin dependencies (no commit)
forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit || true
forge install foundry-rs/forge-std@v1.9.6 --no-commit || true

# Remappings
{
  echo '@openzeppelin/=lib/openzeppelin-contracts/'
  echo 'forge-std/=lib/forge-std/src/'
} > remappings.txt

# Update & build (executed by CI, not here)
forge update
forge build
