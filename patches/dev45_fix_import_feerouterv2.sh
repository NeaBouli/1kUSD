#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV-45 Hotfix: Add missing IFeeRouterV2 import =="

# Füge den Import direkt nach den anderen router/imports ein
sed -i '' '/import {IOracleAggregator}/a\
import {IFeeRouterV2} from "../router/IFeeRouterV2.sol";' "$FILE"

echo "✓ IFeeRouterV2 import added"
echo "== Complete =="
