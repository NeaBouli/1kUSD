#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"

echo "== DEV48 DOC03: append PSM decimals+fees summary to README =="

cat <<'EOL' >> "$FILE"

---

## PSM Update DEV-47–DEV-48: Decimals & Fee Registry

The PegStabilityModule (PSM) has been extended with two audit-focused layers:

- **Token decimals via ParameterRegistry (DEV-47)**  
  - PSM derives collateral token decimals from `ParameterRegistry` using  
    `psm:tokenDecimals` + per-token keys `keccak256(abi.encode(KEY_TOKEN_DECIMALS, token))`.  
  - If no registry or no entry is configured, the PSM safely falls back to **18 decimals**,  
    preserving previous behaviour and simplifying Kaspa-L1 migration later on.

- **Mint/Redeem fees via ParameterRegistry (DEV-48)**  
  - Effective fees are now resolved via the registry first:
    - Global keys: `psm:mintFeeBps`, `psm:redeemFeeBps`
    - Per-token overrides: `keccak256(abi.encode(KEY_MINT_FEE_BPS, token))`,
      `keccak256(abi.encode(KEY_REDEEM_FEE_BPS, token))`
  - Resolution order:
    1. Per-token entry (if > 0),
    2. Global entry (if > 0),
    3. Local PSM storage (`mintFeeBps` / `redeemFeeBps`).
  - All paths enforce `<= 10_000` (max. 100 % fee) to avoid misconfiguration.

- **Regression suites extended**  
  - `PSMRegression_Flows`: covers real mint+redeem flows and vault accounting.  
  - `PSMRegression_Limits`: enforces daily/single caps on 1kUSD notional.  
  - `PSMRegression_Fees`: validates registry-driven mint and redeem fees,
    including per-token overrides and global defaults.

At this stage the PSM is:
- price-aware,
- registry-driven for decimals **and** fees,
- fully wired to real `OneKUSD` mint/burn and a vault abstraction,
- and guarded by Safety/Guardian gates via the canonical IPSM interface.
EOL

echo "✓ PSM decimals+fees summary appended to $FILE"
