#!/usr/bin/env bash
set -euo pipefail

Start local Anvil with deterministic keys and chainId 31337

ANVIL_BIN="${ANVIL_BIN:-anvil}"
PORT="${PORT:-8545}"
CHAIN_ID="${CHAIN_ID:-31337}"
BLOCK_TIME="${BLOCK_TIME:-1}"
ACCOUNTS="${ACCOUNTS:-10}"
BALANCE="${BALANCE:-10000}" # in ETH

exec "$ANVIL_BIN"
--port "$PORT"
--chain-id "$CHAIN_ID"
--block-time "$BLOCK_TIME"
--accounts "$ACCOUNTS"
--balance "$BALANCE"
