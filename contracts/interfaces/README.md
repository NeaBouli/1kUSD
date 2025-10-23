# Interfaces Overview
Minimal Solidity interfaces aligned with protocol specs:

- `IPSM.sol` — PSM swaps & quotes
- `IVault.sol` — Collateral vault I/O & views
- `IOracleAggregator.sol` — Price struct + getPrice()
- `IParameterRegistry.sol` — Canonical parameter map (view)
- `ISafetyAutomata.sol` — Pause state queries
- `I1kUSD.sol` (+ `IERC2612.sol`) — Token & permit interface

> These interfaces are intended to be compile-stable for SDK/dApp work and audits, while implementations mature.
