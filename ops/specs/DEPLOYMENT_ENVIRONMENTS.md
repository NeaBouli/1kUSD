# Deployment Environments — Specification
**Scope:** Networks, stages, config surfaces, addresses registry, change controls.  
**Status:** Spec (no code). **Language:** EN.

## Stages
- dev (local): anvil/hardhat, throwaway addresses
- testnet: Base/Arbitrum Sepolia (TBD)
- mainnet: production (TBD)
- staging (optional): mainnet-fork rehearsals

## Required Contracts
1kUSD Token, PSM, CollateralVault, OracleAggregator, SafetyAutomata, ParameterRegistry, DAO/Timelock, Treasury

## Address Registry (per stage)
Stored at `ops/config/addresses.<stage>.json`
```json
{ "chainId":0,"deployer":"0x...","token":"0x...","psm":"0x...","vault":"0x...","oracle":"0x...","safety":"0x...","registry":"0x...","timelock":"0x...","treasury":"0x...","updatedAt":"ISO-8601" }
Config Surfaces
ParameterRegistry (caps, rate limits, oracle guards)

Safety toggles (pause, guardian sunset)

PSM fees / window+max for rate limits

Change Control
All runtime changes: DAO/Timelock → Safety/Registry setters

No EOAs as owners; multisig executor for Timelock

Delays: testnet 12–24h, mainnet 48–96h

Observability
Indexer endpoints, explorers, dashboards

PoR snapshots & peg telemetry as artifacts
