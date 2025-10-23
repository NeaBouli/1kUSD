#!/usr/bin/env bash
set -euo pipefail

Try to kill an anvil listening on PORT

PORT="${PORT:-8545}"
PID="$(lsof -ti tcp:$PORT || true)"
if [ -n "$PID" ]; then
kill "$PID" || true
sleep 0.3
fi
lsof -ti tcp:$PORT >/dev/null 2>&1 && { echo "Failed to stop anvil on $PORT"; exit 1; }
echo "Anvil on :$PORT stopped (if it was running)."
