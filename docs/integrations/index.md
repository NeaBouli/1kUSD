# Integrations & Developer Guides (DEV-10)

This section collects integration guides and developer-facing documentation
for the 1kUSD Economic Core.

It is aimed at:

- dApp developers
- wallet / exchange integrators
- off-chain indexer and monitoring teams

## Available / planned guides

- **PSM Integration Guide**  
  How to integrate with the Peg Stability Module (PSM) for swaps, limits and
  fee-aware flows.
  See: `psm_integration_guide.md`

- **Oracle Aggregator Guide**  
  How to read prices, handle stale/diff health checks, and consume oracle data
  safely off-chain.
  See: `oracle_aggregator_guide.md`

- **Guardian & Safety Events**  
  How to observe guardian- and safety-related events and wire alerting /
  monitoring.
  See: `guardian_and_safety_events.md`

- **BuybackVault Observer Guide**  
  How to consume BuybackVault-related events from an observer perspective
  (no governance control).
  See: `buybackvault_observer_guide.md`

For deep architectural details, see the core architecture documents and
governance / status reports in the `docs/architecture/` and `docs/reports/`
sections.
