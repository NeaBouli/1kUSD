# Indexer API — Specification
**Scope:** REST endpoints + GraphQL sketch for explorer/SDK.  
**Status:** Spec (no code). **Language:** EN.

## REST (Read-only)
- `GET /v1/peg` → { priceUSD, deviationBps, healthy, updatedAt, finalityMark }
- `GET /v1/reserves` → { assets:[{asset,symbol,decimals,amountRaw,amountUSD}], totalUSD, updatedAt, finalityMark }
- `GET /v1/psm/trades?side=&address=&from=&to=&cursor=&limit=`
  - Response: { items:[PSMTrade], nextCursor }
- `GET /v1/safety/state` → { pausedModules[], caps, rateLimits, updatedAt }
- `GET /v1/gov/proposals?status=`
- `GET /v1/gov/proposals/:id`
- `GET /v1/tx/:hash` → tx + decoded events
- `GET /health` → { tip, safe, lagBlocks, lastError?, startedAt }

## GraphQL (Sketch)
- Types: PegSnapshot, ReserveAsset, PSMTrade, SafetyState, GovProposal
- Queries: peg(last:1), reserves(last:1), psmTrades(filter, first, after), govProposals(status)

## Pagination
- Use opaque `cursor` (base64 of (blockNumber, txIndex, logIndex)).
- Default `limit` 50, max 500.

## Errors
- 429 on rate limit; 5xx on server; 400 on bad params.
- Include `requestId` and `finalityMark` where applicable.
