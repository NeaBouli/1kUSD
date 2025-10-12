# Reference App — API Contracts

**Scope:** Interface contracts between UI and data layers (SDK + Indexer).  
**Status:** Spec (no code). **Language:** EN.

## 1. SDK Interfaces (selected)
- `psm.getParams() -> { feeBps, caps[], rateLimit }`
- `psm.swapTo1kUSD(tokenIn, amountIn, opts) -> TxResult`
- `vault.getBalances() -> BalanceMap`
- `oracle.getPrice(asset) -> { price, decimals, healthy, lastUpdate }`
- `safety.getState() -> { pausedModules[], caps, rateLimits }`
- `gov.listProposals(status?) -> Proposal[]`
- `gov.getTimelock() -> { minDelaySec, queue[] }`

## 2. Indexer Contracts (REST)
- `GET /v1/peg -> { priceUSD, deviationBps, healthy, updatedAt }`
- `GET /v1/reserves -> { assets[], totalUSD, updatedAt, finalityMark }`
- `GET /v1/psm/summary -> { feeBps, caps[], rateLimit, volume24h }`
- `GET /v1/safety/state -> { pausedModules[], rateLimits, caps }`
- `GET /v1/gov/proposals` / `GET /v1/gov/proposals/:id`

## 3. Error Mapping
- Map HTTP/network errors → `NETWORK/RETRYABLE`, `TIMEOUT`.
- Map protocol reverts → `PROTOCOL/*` (from receipt decoding).
- Display user-facing messages with developer details in console.

## 4. Caching/TTL
- Peg/reserves: 5–15s SWR.
- Safety state: subscribe WS where available, fallback 15–30s poll.

## 5. Simulation & Gas
- Pre-tx `simulate()` via SDK; show gas estimate and max fee policy.
