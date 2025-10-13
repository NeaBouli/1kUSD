# dApp Status/Health — API Wiring (Specification)
**Scope:** Consuming indexer/telemetry to drive banners and disable flows.  
**Status:** Spec (no code). **Language:** EN.

## Sources
- Indexer REST: `/v1/peg`, `/v1/safety/state`, `/health`
- Telemetry scrape (optional): metrics aggregator endpoints

## Mapping
- Peg deviation bps → banner severity (SEV1 if >100 bps)
- Oracle age vs maxAge → SEV1
- Paused modules length > 0 → SEV2 (swap disabled for affected module)
- Indexer safe lag > 600 → SEV2
- Rate-limit usage > 0.9 → SEV3 (warn + allow)

## Caching & Polling
- Poll every 15s; WS where available
- Expose last-updated; stale (>1m) displays grey "data may be delayed"

## Error Pages
- `/error/network` (wrong chain)
- `/error/rpc` (provider down)
- `/error/unsupported` (token not approved)
