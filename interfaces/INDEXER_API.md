# Indexer API (REST/GraphQL Spec)

Read-only endpoints for explorers, analytics and monitoring. Include finality info.

## Proof of Reserves
REST GET /v1/reserves -> { assets[{asset,symbol,decimals,amount}], totalUSD, updatedAt, finalityMark }
GQL: reserves { assets { asset symbol decimals amount } totalUSD updatedAt finalityMark }

## Peg & PSM
REST GET /v1/peg -> { priceUSD, deviationBps, healthy, updatedAt }
REST GET /v1/psm/summary -> totals, caps, feeBps, last24hVolume
REST GET /v1/psm/swaps?from&to&asset -> list
GQL: peg { ... } ; psm { feeBps caps {asset cap} rateLimit {windowSec maxAmount} swaps(...) { items{...} page{...} }

## Vault Exposure
REST GET /v1/vault/exposure -> breakdown (percentage, caps, breaches)
GQL: vaultExposure { asset symbol amount percentage cap breached updatedAt finalityMark }

## Safety State
REST GET /v1/safety/state -> paused modules, rate limits, caps
GQL: safety { pausedModules rateLimits { target windowSec maxAmount } caps { target key value } }

## Governance
REST GET /v1/gov/proposals?status=...
REST GET /v1/gov/proposals/:id
GQL: proposals(status:...) { id proposer eta status }

## Telemetry & Health
REST GET /v1/health -> service health, last block, lag, finalityMark
REST GET /v1/metrics -> Prom exposition (optional)

## Pagination & Filters
Use page/size or cursor; support fromBlock/toBlock, asset, module filters.
