# Oracle Failover & Heartbeat Watcher (Spec v0.1)

**Goal:** Monitor oracle feeds and trigger alerts/failover if updates stall.

## Features
- Tracks lastUpdate timestamp per feed
- DAO sets `maxStale` (default: 1 day)
- Emits `FeedStale(address feed, uint256 lastUpdate)`
- Optional `backupFeed` for failover
- Can be queried by off-chain watchdog

## Security
- DAO-only for configuration
- No on-chain auto-execution, just signalling
- Compatible with OracleAggregator
