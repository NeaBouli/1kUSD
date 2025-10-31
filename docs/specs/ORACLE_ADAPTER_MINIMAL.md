# Oracle Adapter Minimal (Spec v0.1)

**Goal:** Provide a lightweight, DAO-configurable oracle adapter for PSM pricing.

## Core Features
- Stores `price` and `lastUpdated`
- DAO can update via `setPrice()`
- Consumer modules (e.g. PSM) call `getPrice()`
- Emits `PriceUpdated(price, timestamp)`

## Security
- DAO-only updates
- Reverts on stale (>24h) data
- Uses block.timestamp for freshness
