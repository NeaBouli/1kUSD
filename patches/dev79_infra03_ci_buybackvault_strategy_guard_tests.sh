#!/usr/bin/env bash
set -euo pipefail

echo "== DEV79 INFRA03: add CI workflow for BuybackVault strategy guard tests =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

WORKFLOW_DIR=".github/workflows"
WORKFLOW_FILE="${WORKFLOW_DIR}/buybackvault-strategy-guard.yml"
LOG_FILE="logs/project.log"

mkdir -p "$WORKFLOW_DIR"

cat > "$WORKFLOW_FILE" <<'YML'
name: BuybackVault Strategy Guard Tests

on:
  push:
    paths:
      - 'contracts/core/BuybackVault.sol'
      - 'contracts/strategy/**'
      - 'foundry/test/BuybackVault.t.sol'
      - '.github/workflows/buybackvault-strategy-guard.yml'
  pull_request:
    paths:
      - 'contracts/core/BuybackVault.sol'
      - 'contracts/strategy/**'
      - 'foundry/test/BuybackVault.t.sol'
      - '.github/workflows/buybackvault-strategy-guard.yml'

jobs:
  buybackvault-strategy-guard:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
        with:
          version: nightly

      - name: Show Foundry versions
        run: forge --version

      - name: Run BuybackVault baseline tests
        run: forge test --match-contract BuybackVaultTest

      - name: Run BuybackVault strategy guard tests
        run: forge test --match-contract BuybackVaultStrategyGuardTest
YML

echo "✓ Workflow written to ${WORKFLOW_FILE}"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-79] ${timestamp} INFRA: added buybackvault-strategy-guard GitHub Actions workflow." >> "$LOG_FILE"
echo "✓ Log updated at ${LOG_FILE}"

echo "== DEV79 INFRA03: done =="
