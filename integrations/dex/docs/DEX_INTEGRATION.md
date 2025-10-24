
DEX/AMM Integration — Spec (v1)

Language: EN. Status: Spec.

Goals

Lock minimal pool ABIs (events/signatures) for decoding.

Provide routing hints to help AutoConverter pick pools/fees.

Define price sanity checks against OracleAggregator (deviation, TWAP).

ABIs (locked)

UniswapV2Pair: Sync, Swap, Mint, Burn (minimal subset)

UniswapV3Pool: Swap, Mint, Burn, Initialize, Observe (minimal subset)

Routing Hints

JSON entries suggesting preferred pools/fees per pair on a chain.

Fields: pair, pool, fee (v3), priority, minLiquidityUSD, enabled.

Price Sanity

Compare DEX-derived price vs oracle median: deviation ≤ maxDeviationBps.

If using TWAP, windowSec must match adapter policy.

Outputs a JSON report and a short text summary.
