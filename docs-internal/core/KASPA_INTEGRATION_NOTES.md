# Kaspa Integration Notes

- **No consensus changes** (no GHOSTDAG/PHANTOM tweaks).
- **Finality watermark** in the indexer for replay/reorg handling.
- **Throughput**: modules are designed for high-frequency swaps; guards fail-closed if oracles stale or caps/rate-limits exhausted.
- **Roadmap**: expose native interfaces when Kaspa smart contracts are production-ready, then consider L1 parity keeper.
