#!/usr/bin/env bash
set -euo pipefail
echo "Emitting addresses.template.json ..."
node scripts/00_addresses_template.ts
