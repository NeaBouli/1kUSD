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

---

### Documentation Index
For a complete, continuously updated specification map, see: `docs/INDEX.md`

---

### Addresses / Environments
Canonical contract addresses are tracked in `ops/config/addresses.*.json`.  
For staging/testnet/mainnet, always update these files in PRs and reference them in SDK/dApp configs.

---

### Parameters (Registry)
Canonical keys are documented in `docs/PARAMETER_KEYS.md`.  
Environment examples live under `ops/config/params.*.json` (staging/testnet/mainnet).

---

### JSON Validation
Schemas live under `ops/config/schema/`.  
Addresses/params JSON files embed the `$schema` field for editor validation.

---
### SDK Wiring Guide
See `docs/SDK_WIRING_GUIDE.md` and examples under `clients/examples/`.

---
### PSM Quotes — Fees & Rounding
See `docs/PSM_QUOTE_SEMANTICS.md` for normative rules (decimals, fees, rounding, invariants).

---
### Safety & Guardian
- Pause matrix: `docs/SAFETY_PAUSE_MATRIX.md`
- Module IDs: `docs/MODULE_IDS.md`
- Error catalog: `docs/ERROR_CATALOG.md`
- Guardian sunset hooks: `docs/GUARDIAN_SUNSET_HOOKS.md`

---
### Parameter keys & config
- Canonical keys: `docs/PARAM_KEYS_CANON.md`
- Params schema: `ops/schemas/params.schema.json`
- Template params: `ops/config/params.template.json`
- SDK helpers: `clients/examples/param-keys.ts`
