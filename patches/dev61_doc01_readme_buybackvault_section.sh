#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV61 DOC01: add Treasury Buybacks section to README =="

cat <<'EOL' >> "$FILE"

## Treasury Buybacks

- Core contract: `contracts/core/BuybackVault.sol`
- Debug & Architecture Plan: `docs/architecture/buybackvault_plan.md`

For the current v0.50.x Economic Layer, BuybackVault implements:
- Custody of the protocol stablecoin (1kUSD) and a target asset.
- DAO-only funding via `fundStable`, optionally gated by `SafetyAutomata` (global pause).
- DAO-only withdrawals via `withdrawStable` / `withdrawAsset`.

On-chain execution of actual DEX buybacks will be added in a later phase;
the current version focuses on secure custody, access control and pause wiring.
EOL

echo "✓ Treasury Buybacks section appended to $FILE"
