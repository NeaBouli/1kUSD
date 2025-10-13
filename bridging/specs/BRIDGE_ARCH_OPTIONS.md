# Bridge Architecture Options — Specification
**Scope:** Evaluation of lock/mint vs burn/release and partner integration requirements.  
**Status:** Spec (no code). **Language:** EN.

## Models
### A) Lock/Mint
- Source chain: lock 1kUSD; Target chain: mint wrapped 1kUSD (canonical if DAO designates).
- Pros: fast UX; Cons: increased bridge trust and PoR complexity.

### B) Burn/Release
- Source: burn 1kUSD; Target: mint 1kUSD from canonical pool.
- Pros: single supply; Cons: requires reliable cross-chain finality proofs.

## Finality & Safety
- Require **source finality** (N confirmations) before target mint.
- Pausable bridge adapters by Safety (does not unlock funds).
- Rate-limit per direction (shared limiter spec: RATE_LIMITS_SPEC).

## Event Contracts (abstract)
- `BridgeIntentCreated(id, user, srcChain, dstChain, amount, ts)`
- `BridgeMinted(id, dstChain, to, amount, ts)`
- `BridgeRedeemed(id, srcChain, from, amount, ts)`

## Double-Mint Prevention
- Canonical **Supply Registry** reconciles per-chain supply against PoR.
- Indexer validates intents and emits **reconciliation report**.

## Partner Requirements
- Public security posture; historical incident review.
- APIs for proof/status; SLA for finality reporting.
- No custody of user keys; user-signed intents only.

## Monitoring
- Metrics: intents/day, success ratio, avg time to finality, reorg retries.
- Alerts: stuck intents > T, deviation between chain supplies > ε.
