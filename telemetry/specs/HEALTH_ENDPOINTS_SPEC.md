# Health Endpoints — Specification
**Scope:** Liveness/readiness endpoints for indexer, API, and app edge.  
**Status:** Spec (no code). **Language:** EN.

## Indexer
- `GET /health`
  - `tip`, `safe`, `lagBlocksTip`, `lagBlocksSafe`, `lastError?`, `startedAt`, `version`, `commit`
  - HTTP 200 if ingest alive; 500 if pipeline halted.

## Public API
- `GET /readyz` → checks DB connectivity, cache, and last successful query time
- `GET /livez`  → process alive
- Include `requestId` header on responses; cache-control no-store.

## App Edge (optional)
- `/edge/health` returns `buildId`, `uptime`, `env`, `version`.

## Error Shape (common)
```json
{ "status": 500, "error": "string", "requestId": "uuid", "ts": 0 }
