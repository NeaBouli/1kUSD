#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV52 DOC03: append PSM spreads summary to README =="

cat <<'EOL' >> "$FILE"

### PSM spreads (DEV-52)

On top of registry-driven mint/redeem fees, the PegStabilityModule supports
an additional spread layer, also resolved via the ParameterRegistry:

- Global keys:
  - \`psm:mintSpreadBps\`
  - \`psm:redeemSpreadBps\`
- Per-token overrides:
  - \`keccak256(abi.encode(KEY_MINT_SPREAD_BPS, token))\`
  - \`keccak256(abi.encode(KEY_REDEEM_SPREAD_BPS, token))\`

Internally, the PSM resolves:

- Mint: \`totalBps = mintFeeBps + mintSpreadBps\`
- Redeem: \`totalBps = redeemFeeBps + redeemSpreadBps\`

with the invariant \`require(totalBps <= 10_000, "PSM: fee+spread too high");\`.
This allows risk/governance to shape effective swap costs without touching
limits or oracle health gates.
EOL

echo "✓ PSM spreads summary appended to $FILE"
