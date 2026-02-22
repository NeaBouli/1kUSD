# 1kUSD dApp — Minimal Scaffolding (Docs only)

**Status:** No code/builds. Information architecture + routes plan.  
**Audience:** dApp devs (frontend), SDK authors.

## Goals (Phase 0)
- Define pages, navigation, and data dependencies.
- Align public APIs (RPC/Indexer) with UI requirements.
- Keep zero build footprint until contracts stabilize.

## High-level IA
- Global Layout: Header (Nav), Footer (Links), Toast/Modal layer.
- Sections: Home, Swap (PSM), Vault, Oracles, Governance, Status.

## Data sources
- JSON-RPC: `interfaces/RPC_API.md`
- Indexer (read-only): `interfaces/INDEXER_API.md`
- On-chain events catalog: `interfaces/ONCHAIN_EVENTS.md`
- Addresses: `ops/config/addresses.*.json`
- Params: `ops/config/params.*.json`

