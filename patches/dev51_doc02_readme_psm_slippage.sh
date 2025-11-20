#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV51 DOC02: append PSM slippage & spread design summary to README =="

cat <<'EOL' >> "$FILE"

### PSM Slippage & Spread (Design – DEV-51)

The PegStabilityModule (PSM) now has a dedicated **slippage & spread design spec**
under `docs/economics/psm_slippage_design.md`.

Key points:

- Builds on the existing **notional layer** (DEV-44) and **fee layer** (DEV-48).
- Introduces a clear separation between:
  - **Mid-Price** from the Oracle (post health checks),
  - **Directional spread** (mint vs redeem),
  - Optional **size-based slippage buckets** for large swaps.
- All parameters are intended to be **registry-driven** (global + per-token),
  mirroring the existing fee/decimals design.
- Limits (`PSMLimits`) continue to apply to **1kUSD notional** before
  spread/fee adjustments, keeping caps simple and auditable.

DEV-51 is **design-only** and does not modify core contracts yet.
Implementation hooks (DEV-52+) will integrate spread/slippage as an
additional layer on top of the current PSM notional/fee logic.
EOL

echo "✓ PSM slippage & spread design summary appended to $FILE"
