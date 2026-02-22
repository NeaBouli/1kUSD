# Oracle Aggregator v2 (Spec v0.2)

## Overview
Aggregates multiple oracle adapters and computes a median price.
Feeds can be added by DAO only. Uses on-chain median sort.

## Interfaces
- `addFeed(address)` — adds new adapter
- `update()` — pulls all feed prices and updates median
- `getPrice()` — returns last computed median price
- `feeds(uint256)` — returns adapter address by index

## Security
- DAO-guarded feed registration
- Median calculation prevents single-feed manipulation
- Requires non-stale adapter data (enforced via Adapter heartbeat)
