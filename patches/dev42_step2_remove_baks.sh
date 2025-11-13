#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-42 Step 2: Removing old .bak sources =="

find contracts -name "*.bak" -type f -print -delete

echo "✓ Removed all legacy .bak Solidity sources"
