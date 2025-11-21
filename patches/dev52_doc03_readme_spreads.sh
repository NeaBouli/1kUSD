#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV52 DOC03: append PSM spread summary to README =="

cat <<'EOL' >> "$FILE"

---

### PSM Spreads (DEV-52)

On top of the classic fee layer, the PegStabilityModule now supports a
separate **spread layer** which is fully driven by the `ParameterRegistry`:

- **Global spreads**
  - `psm:mintSpreadBps` – additional basis points charged on mint
    (collateral → 1kUSD).
  - `psm:redeemSpreadBps` – additional basis points charged on redeem
    (1kUSD → collateral).

- **Per-token spreads**
  - `keccak256(abi.encode(KEY_MINT_SPREAD_BPS, token))`
  - `keccak256(abi.encode(KEY_REDEEM_SPREAD_BPS, token))`

Resolution order for both mint and redeem:

1. Per-token spread (`> 0`)  
2. Global spread (`> 0`)  
3. Fallback: `0` if no registry entry is configured

Fees and spreads are additive and must satisfy:

> `feeBps + spreadBps <= 10_000` (max 100 % total charge)

This behaviour is covered by the dedicated `PSMRegression_Spreads` suite,
alongside `PSMRegression_Fees` and `PSMRegression_Flows`, giving a complete
economic regression harness for the PSM.

EOL

echo "✓ PSM spread summary appended to $FILE"
