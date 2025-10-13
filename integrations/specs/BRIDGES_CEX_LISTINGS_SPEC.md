# Integrations — Bridges & CEX Listings (Blueprint)
**Scope:** Anforderungen für Bridges (canonical/3rd-party) und CEX-Listings; Assets, Proofs, Monitoring.  
**Status:** Spec (no code). **Language:** EN.

## Bridges
- Canonical bridge (if any): lock/mint vs burn/release out of scope (future)
- Third-party bridges: require static token address per chain; no rebase
- Finality: indexer `finalityMark="safe"` gating for mint/burn UI prompts

### Bridge Checklist
- Token metadata JSON (name, symbol, decimals, chainId, address)
- Block explorer verification & ABI publish
- Test vectors: mint/redeem roundtrip preserving 18 decimals
- Rate-limit advisory: do not bypass protocol rate limits

## CEX Listings
- Assets package: whitepaper (DE+EN), logo kit, contract addresses, audit reports (when available)
- Legal stance: decentralized, ownerless contracts, DAO/Timelock control
- Technical: ERC-20 standard, no transfer fees, pause does not block transfers

### Monitoring
- Address watchlist for exchange hot/cold wallets
- Peg deviation alert near major venues
- Listing changes logged in `docs/CHANGELOG.md`
