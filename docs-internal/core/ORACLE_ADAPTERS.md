
Oracle Adapters — Spec (v1)

Purpose

Normalize external price sources for OracleAggregator.

Adapter Types

chainlink: on-chain aggregator feed

pyth: off-chain delivered feed (price + conf + publishTime)

dex_twap: on-chain DEX TWAP window

Required Fields (see schema)

Common: type, pair, decimalsOut, heartbeatSec, maxDeviationBps

chainlink: address

pyth: priceId

dex_twap: pool, windowSec, quoteToken

Validation

JSON schema: oracles/schemas/adapter.schema.json

Catalog per chain: oracles/catalog/<chainId>.json

Examples: oracles/examples/*.json
