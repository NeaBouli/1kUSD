
Parameter Keys Catalog (v1)

Global (bytes32)

PARAM_TREASURY_ADDRESS

PARAM_PSM_FEE_BPS

PARAM_ORACLE_MAX_AGE_SEC

PARAM_ORACLE_MAX_DEVIATION_BPS

PARAM_RATE_WINDOW_SEC

PARAM_RATE_MAX_AMOUNT

PARAM_SAFETY_GUARDIAN_SUNSET_TS

Per-asset (composite key via keccak256(KEY, asset))

PARAM_CAP_PER_ASSET

PARAM_MIN_LIQUIDITY_USD

PARAM_MAX_SLIPPAGE_BPS

PARAM_ASSET_DECIMALS_CACHE

Notes

Fee basis points range: [0,10000]

Deviation basis points range: [0,10000]

Windows in seconds; amounts in raw token units unless stated USD
