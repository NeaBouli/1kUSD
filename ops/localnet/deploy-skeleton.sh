#!/usr/bin/env bash
set -euo pipefail

Placeholder deploy — compile check & sample address book emit
Requires: node, jq (optional), foundry or hardhat already installed in repo

RPC_URL="${RPC_URL:-http://127.0.0.1:8545}
"
CHAIN_ID="${CHAIN_ID:-31337}"

echo "Compile check (choose tool available)..."
if command -v forge >/dev/null 2>&1; then
forge build >/dev/null
echo "Forge build ok."
elif command -v npx >/dev/null 2>&1; then
npx hardhat compile >/dev/null
echo "Hardhat build ok."
else
echo "No toolchain found (forge or hardhat)."
exit 2
fi

mkdir -p ops/addresses
cat > ops/addresses/address-book.local.json <<JSON
{
"$schema": "../schemas/address_book.schema.json",
"version": "0.0.1-local",
"generatedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
"chains": [
{
"chainId": $CHAIN_ID,
"network": "local",
"contracts": [
{ "name": "OneKUSD", "address": "0x1111111111111111111111111111111111111111" },
{ "name": "PSM", "address": "0x2222222222222222222222222222222222222222" },
{ "name": "CollateralVault", "address": "0x3333333333333333333333333333333333333333" },
{ "name": "OracleAggregator", "address": "0x4444444444444444444444444444444444444444" },
{ "name": "SafetyAutomata", "address": "0x5555555555555555555555555555555555555555" },
{ "name": "ParameterRegistry", "address": "0x6666666666666666666666666666666666666666" },
{ "name": "DAO_Timelock", "address": "0x7777777777777777777777777777777777777777" }
]
}
]
}
JSON

echo "Local address-book emitted: ops/addresses/address-book.local.json"
echo "You can now generate .env.addresses via:"
echo " node scripts/emit-env-from-addresses.ts ops/addresses/address-book.local.json $CHAIN_ID > .env.addresses"
