# API & Interface Catalog (EN)

This file enumerates — at a high level — the planned interfaces for 1kUSD:

## On-Chain (contracts)
- Events (Token, Vault, PSM, Oracle, Safety, DAO, Treasury, Bridge Anchor)
- Roles & capabilities (ownerless or Timelock-governed)
- Invariants: supply ≤ provable reserves, pause-aware operations

## Off-Chain
- Indexer (REST/GraphQL): proof-of-reserves, peg drift, PSM flows, exposure, fees
- Monitoring: Prometheus/OTel metrics & alert conditions
- Governance Ops: proposal lifecycle transparency (read-only), timelock state

## Client-Facing
- JSON-RPC/WebSocket: standard node/provider methods (read-only and subscriptions)
- SDK method families (Tx build/sign/broadcast; event decoding)

**Note:** Detailed schemas will be produced by interface tasks (no code here).
