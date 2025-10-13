# Integrations — Partner APIs & Adapters (Blueprint)
**Scope:** Einheitliche Adapter-Spezifikationen für Price, Swap, Custody, Indexing.  
**Status:** Spec (no code). **Language:** EN.

## Adapters
- Price: read-only price feeds for 1kUSD/USD, 1kUSD/USDC
- Swap: abstracted swap interface calling SDK PSM helpers
- Custody: balance & withdrawal status (read-only integrations)
- Indexing: mirror of `/v1/*` endpoints with rate limits

## REST Contracts (examples)
- `GET /partner/v1/price?pair=1kUSD-USD` → { price, ts, source }
- `POST /partner/v1/quote` → { side, tokenIn, amountIn } → { feeBps, minOut }
- `POST /partner/v1/swap` → client-initiated via wallet; server returns intent id (no private key handling)

## Constraints
- No server-side signing or custody
- Respect `finalityMark`; surface confirmations in responses
- Error taxonomy aligned to `clients/specs/COMMON_ERRORS.md`

## Test Plan
- Backpressure & rate limit behavior
- Price staleness handling
- Swap minOut adherence across tokens with 6/18 decimals
