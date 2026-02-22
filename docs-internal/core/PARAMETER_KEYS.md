# Canonical Parameter Keys (Reference)
**Status:** Info (no code). **Language:** EN.

> These keys are used with `ParameterRegistry` (`bytes32` keys). Values are set via governance (later Timelock).

## Global
- `PARAM_PSM_FEE_BPS` — uint: PSM fee in basis points (e.g., 10 = 0.10%)
- `PARAM_ORACLE_MAX_AGE_SEC` — uint: max age for oracle data (seconds)
- `PARAM_ORACLE_MAX_DEVIATION_BPS` — uint: allowed deviation between sources
- `PARAM_RATE_WINDOW_SEC` — uint: sliding-window length for rate-limits
- `PARAM_RATE_MAX_AMOUNT` — uint: gross flow cap in window (chain-native decimals for 1kUSD)
- `PARAM_TREASURY_ADDRESS` — address: destination for fees (via Vault spend path)
- `PARAM_EMERGENCY_GUARDIAN` — address: temporary guardian (sunset later)

## Per-Asset (hashed with asset address)
- `PARAM_CAP_PER_ASSET` — uint: storage cap per collateral asset (token decimals)
- `PARAM_TOKEN_SUPPORTED` — bool: allow-list toggle per token (PSM/Vault)
- `PARAM_DECIMALS_HINT` — uint: optional decimals hint for off-standard ERC-20

## Derived Keys (examples)
- `keccak256("PARAM_CAP_PER_ASSET", asset)` for a per-asset cap
- `keccak256("PARAM_TOKEN_SUPPORTED", asset)` for support toggle

> Keep key names stable. Changes require a migration note and SDK update.
