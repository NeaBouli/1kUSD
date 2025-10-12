# 1kUSD — Decentralized Stablecoin Protocol

**Repository language: English.**  
**Whitepaper:** German & English (two files under `docs/whitepaper/`).

## Overview
1kUSD is a decentralized, collateralized, and automation-driven stablecoin designed for a 1:1 USD peg via on-chain reserves (stablecoins), a Peg-Stability Module (PSM), oracle aggregation, and safety automata.  
Phase 1 targets EVM deployment, with forward compatibility for Kasplex and (eventually) Kaspa L1.

## Architecture Modules
- **On-Chain:** 1kUSD Token, CollateralVault, AutoConverter, PSM, OracleAggregator, Safety-Automata, DAO/Timelock, Treasury, Bridge Anchor (prep).
- **Off-Chain:** Indexer/APIs, Monitoring/Telemetry, CI/CD, Security/Audit.
- **Clients:** SDKs, Reference dApp/Explorer.

## Repository Layout
- `contracts/` — On-chain modules (to be added by tasks)
- `interfaces/` — ABI/IDL and API specifications (no code)
- `arch/` — Architecture decisions & diagrams
- `docs/` — Documentation (EN), whitepaper DE & EN under `docs/whitepaper/`
- `tasks/` — Task prompts for developers (EOF-based deliverables)
- `patches/` — Patch series (diffs or here-doc payloads)
- `reports/` — Audit & performance reports
- `logs/` — Project logbook
- `.github/workflows/` — CI pipelines

## Contribution Model
- Main architect assigns tasks; each new area = new developer with a precise prompt.
- The **middleman** executes copy-paste shell/snippet commands only.
- All deliverables come as **EOF-closed files** (here-doc style).

## License
AGPL-3.0 (see `LICENSE`)
