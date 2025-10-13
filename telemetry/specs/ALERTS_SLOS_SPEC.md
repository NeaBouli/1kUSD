# Telemetry — Alerts & SLOs
**Scope:** Alert rules, thresholds, runbooks, and service objectives.  
**Status:** Spec (no code). **Language:** EN.

## Severity Model
- SEV1: funds at risk or peg > 1.5% for > 5m
- SEV2: degraded swaps (fail rate > 10% 5m) / indexer unsafe lag > 600 blocks
- SEV3: non-critical regressions, rising error rate, stale oracle warnings

## Key Alerts (examples)
- **PegDeviationHigh**: deviation_bps > 100 for 2m → page SEV1
- **OracleStale**: oracle_snapshot_age_seconds > maxAgeSec for asset for 3m (SEV2)
- **RateLimitNearCap**: rate_limit_usage_ratio > 0.9 for 10m (SEV3)
- **PSMFailures**: ui_swap_attempts_total{outcome="broadcast_fail"} rate > 0.1/min (SEV2)
- **IndexerLagUnsafe**: indexer_safe_lag_blocks > 600 for 10m (SEV2)
- **PausedModules**: safety_paused_modules > 0 (SEV3; escalate if > 30m)

## SLOs (quarterly)
- API availability ≥ 99.9% (5xx rate < 0.1%)
- API p95 latency < 300ms, p99 < 800ms
- Indexer safe lag < 60 blocks 99% of time
- Oracle snapshot age < maxAgeSec 99.5% of time
- UI swap success rate ≥ 98% (excluding user rejections)

## Runbooks (pointers)
- Peg deviation → check Oracle & Safety; consider pausing mint; verify PSM liquidity.
- Indexer lag → increase workers; check RPC health; backoff & re-shard.
- Oracle stale → switch to backup sources; tighten caps; notify governance.
