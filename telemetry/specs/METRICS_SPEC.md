# Telemetry — Metrics Specification
**Scope:** Protocol/indexer/app metrics, cardinality rules, labels, and dashboards.  
**Status:** Spec (no code). **Language:** EN.

## Conventions
- Prometheus-style names; SI units; `_total` for counters, `_seconds` for durations.
- Low label cardinality: network, stage, module, outcome, reason.

## Protocol (Node/SDK derived)
- `psm_swaps_total{stage,network,side}`              — count of swaps by side
- `psm_fees_usd_total{stage,network,token}`          — accumulated fees (USD-approx)
- `vault_exposure_usd{stage,network,asset}`          — latest exposure by asset
- `rate_limit_usage_ratio{stage,module}`             — used/max sliding window
- `safety_paused_modules{stage}`                     — gauge (count)
- `oracle_snapshot_age_seconds{stage,asset}`         — time since last healthy price

## Indexer
- `indexer_tip_lag_blocks{network}`                  — bestHead - tip
- `indexer_safe_lag_blocks{network}`                 — bestHead - safe
- `indexer_reorg_events_total{network}`              — detected reorgs
- `indexer_batch_duration_seconds{phase}`            — ingest/normalize/store durations
- `api_requests_total{route,code}`                   — REST hits
- `api_latency_seconds{route}`                       — p95/p99 histogram

## App (Reference dApp)
- `ui_page_views_total{route}`                       — anonymized
- `ui_swap_attempts_total{outcome}`                  — success|simulate_fail|broadcast_fail
- `ui_wallet_connect_total{provider}`

## Dashboards (high-level)
- **Peg & Reserves:** peg price, deviation, reserves by asset, exposure caps vs actuals.
- **PSM Health:** swaps/min, fees, rate-limit usage, paused state.
- **Oracle Health:** age, deviation guard triggers, source quorum.
- **Indexer/API:** tip/safe lags, error rates, latency, reorgs.
- **App UX:** swap funnel, error taxonomy breakdown (COMMON_ERRORS.md).
