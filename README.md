[![Docs Status](https://github.com/NeaBouli/1kUSD/actions/workflows/docs-check.yml/badge.svg)](https://github.com/NeaBouli/1kUSD/actions/workflows/docs-check.yml)

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

---
### Deployment skeletons
- Env templates: `.env.example`, `ops/env/.env.staging.example`, `ops/env/.env.testnet.example`
- Foundry: `foundry.toml`, compile-only test `tests/Compile.t.sol`
- Hardhat: `hardhat.config.ts`, TypeScript scripts under `scripts/`
- Emit addresses template: `ops/scripts/emit-addresses-template.sh`

**Quickstart**
```bash
cp .env.example .env
# optionally edit RPC_URL/CHAIN_ID/DEPLOYER_PRIVATE_KEY
node scripts/00_addresses_template.ts

Governance

Param writes via Timelock: docs/GOVERNANCE_PARAM_WRITES.md

Proposal schema: ops/schemas/param_change.schema.json

Sample proposal: ops/proposals/param_change.sample.json

Compose calldata: node scripts/compose-param-change.ts <proposal.json>

Guardian sunset rehearsal: docs/GUARDIAN_SUNSET_RUNBOOK.md

Configs & Address Book

Deploy configs (per chain): ops/configs/*.json (schema: ops/schemas/deploy_config.schema.json)

Address book (multi-chain): ops/addresses/address-book.sample.json (schema: ops/schemas/address_book.schema.json)

Validate JSON:
npx ts-node scripts/validate-json.ts ops/schemas/deploy_config.schema.json ops/configs/base.local.json

Emit .env from address book:
node scripts/emit-env-from-addresses.ts ops/addresses/address-book.sample.json 31337 > .env.addresses

Bootstrap

Localnet: ops/localnet/*.sh (start/stop/seed/deploy-skeleton)

Quickstart: docs/BOOTSTRAP_QUICKSTART.md

Staging runbook: ops/staging/STAGING_BOOTSTRAP_RUNBOOK.md

SDK (TypeScript)

Package: clients/ts

Build: (from repo root) npm --prefix clients/ts install && npm --prefix clients/ts run build

Run vectors:

Permit: npm --prefix clients/ts run vector:permit

Oracle: npm --prefix clients/ts run vector:oracle

PSM Math

Canonical formulas: docs/PSM_QUOTE_MATH.md

Rounding rules: docs/ROUNDING_RULES.md

JSON vectors: tests/vectors/psm_quote_vectors.json

Eval helper: npx ts-node scripts/quote-eval.ts tests/vectors/psm_quote_vectors.json

Vault Math & FoT Handling

Accounting rules: docs/VAULT_ACCOUNTING.md

Fee accrual policy: docs/FEE_ACCRUAL.md

Vectors: tests/vectors/vault_fot_vectors.json

Eval helper: npx ts-node scripts/vault-eval.ts tests/vectors/vault_fot_vectors.json

Safety Guards

Test plan: docs/SAFETY_GUARDS_TESTPLAN.md

Rate-limit vectors: tests/vectors/safety_rate_limit_vectors.json

Pause/sunset vectors: tests/vectors/safety_pause_vectors.json

Eval helpers:

npx ts-node scripts/safety-rate-eval.ts tests/vectors/safety_rate_limit_vectors.json

npx ts-node scripts/safety-pause-eval.ts tests/vectors/safety_pause_vectors.json

PSM Interface

Final interface: contracts/interfaces/IPSM.sol (v1)

Revert reasons: docs/PSM_REVERTS.md (normative)

ABI lock (events): abi/locks/PSM.events.json

Check lock vs compiled: node scripts/check-abi-lock.js abi/locks/PSM.events.json <compiled-abi.json>

OneKUSD Token

Interface: contracts/interfaces/IOneKUSD.sol

Pause semantics: docs/TOKEN_PAUSE_SEMANTICS.md

ABI lock (events): abi/locks/OneKUSD.events.json

Permit vectors: tests/vectors/permit_vectors.json

SDK helpers: clients/ts (permit builder/sign)

Collateral Registry & Asset Metadata

Interface: contracts/interfaces/ICollateralRegistry.sol

JSON Schema: schemas/asset_metadata.schema.json

Samples: tests/vectors/collateral_assets.sample.json

Spec: docs/COLLATERAL_REGISTRY.md

Parameter Registry

Spec: docs/PARAMETER_REGISTRY.md

Keys catalog: docs/PARAM_KEYS_CATALOG.md

JSON Schema: schemas/params.schema.json

Sample snapshot: tests/vectors/params.sample.json

Validate: node scripts/validate-json.mjs schemas/params.schema.json tests/vectors/params.sample.json

Governance Ops

Schema: governance/schemas/proposal.schema.json

Examples: governance/examples/*.json

Queue: node scripts/gov-queue.mjs <proposal.json>

Execute: node scripts/gov-exec.mjs <proposal.json>

Validate JSON: node scripts/validate-json.mjs governance/schemas/proposal.schema.json <proposal.json>

Oracle Adapters

Schema: oracles/schemas/adapter.schema.json

Catalog (per chain): oracles/catalog/<chainId>.json

Examples: oracles/examples/*.json

Validate catalog: node scripts/validate-oracle-catalog.mjs oracles/catalog/1.json

AutoConverter Router

Policy doc: converter/docs/AUTOCONVERTER_ROUTER.md

Router schema: converter/schemas/router.schema.json

Sample routes: tests/vectors/routes.sample.json

Evaluate routes: node scripts/route-eval.mjs converter/schemas/router.schema.json tests/vectors/routes.sample.json quotes.json

Quote/Exec Alignment

Invariants: docs/PSM_QUOTE_EXEC_ALIGNMENT.md

Run cross-check: node scripts/psm-crosscheck.mjs tests/vectors/psm_quote_vectors.json

Reports: reports/psm_quote_exec_report.json, reports/psm_quote_exec_summary.txt

Indexing & Telemetry

Spec: indexer/docs/INDEXING_TELEMETRY.md

Event DTO schema: indexer/schemas/event_dto.schema.json

PoR schema: indexer/schemas/por_rollup.schema.json

Health schema: indexer/schemas/health.schema.json

Validate PoR: node scripts/por-rollup-validate.mjs tests/vectors/por_rollup.sample.json

Check health: node scripts/check-health.mjs tests/vectors/health.sample.json

DEX/AMM Integration

Spec: integrations/dex/docs/DEX_INTEGRATION.md

ABI locks: integrations/dex/abi/UniswapV2Pair.events.json, integrations/dex/abi/UniswapV3Pool.events.json

Routing hints schema: integrations/dex/schemas/routing_hints.schema.json

Samples: tests/vectors/dex_routing_hints.sample.json

Price sanity vectors: tests/vectors/dex_price_sanity_vectors.json

Check price sanity: node scripts/dex-price-sanity.mjs tests/vectors/dex_price_sanity_vectors.json

Security Checklists & CI Gate

Pre-deploy: security/checklists/PRE_DEPLOY.md

Post-deploy: security/checklists/POST_DEPLOY.md

Incident response: security/checklists/INCIDENT_RESPONSE.md

CI Security Gate doc: docs/CI_SECURITY_GATE.md

Workflow: .github/workflows/security-gate.yml

Release & Versioning

Bump: ./scripts/bump-version.sh <major|minor|patch>

Notes: node scripts/release-notes.mjs vX.Y.Z [prevTag]

Workflow: .github/workflows/release.yml (on tags v*..)

Template: .github/release/RELEASE_NOTES_TEMPLATE.md

## Project Status

[![CI](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/ci.yml?branch=main&label=CI)](https://github.com/NeaBouli/1kUSD/actions/workflows/ci.yml)
[![Foundry Tests](https://img.shields.io/github/actions/workflow/status/NeaBouli/1kUSD/foundry-test.yml?branch=main&label=Foundry%20Tests)](https://github.com/NeaBouli/1kUSD/actions/workflows/foundry-test.yml)
[![Docs Deploy](https://img.shields.io/github/deployments/NeaBouli/1kUSD/github-pages?label=Docs)](https://github.com/NeaBouli/1kUSD/deployments)
![License](https://img.shields.io/github/license/NeaBouli/1kUSD)
![Last commit](https://img.shields.io/github/last-commit/NeaBouli/1kUSD)

**Docs:** https://neabouli.github.io/1kUSD/

---

## 🔄 Docs Deployment

The documentation is automatically deployed via GitHub Actions  
on each push to the **main** branch.  
Manual deploy (local test):

```bash
mkdocs build
mkdocs serve

---

## 🧪 Continuous Integration Status

| Workflow | Status | Beschreibung |
|-----------|:-------:|--------------|
| **Foundry Tests CI** | [![Foundry Tests](https://github.com/NeaBouli/1kUSD/actions/workflows/foundry.yml/badge.svg)](https://github.com/NeaBouli/1kUSD/actions/workflows/foundry.yml) | Smart-Contract Tests (Forge) |
| **Solidity CI** | [![Solidity CI](https://github.com/NeaBouli/1kUSD/actions/workflows/solidity.yml/badge.svg)](https://github.com/NeaBouli/1kUSD/actions/workflows/solidity.yml) | Lint + Compile + Static Analysis |
| **Docs Deploy** | [![Docs Deploy](https://github.com/NeaBouli/1kUSD/actions/workflows/docs.yml/badge.svg)](https://github.com/NeaBouli/1kUSD/actions/workflows/docs.yml) | MkDocs Build & GitHub Pages Deploy |

> 🔄 Die Badges aktualisieren sich automatisch bei jedem Commit oder Pull-Request.  
> 💡 Grün = Build erfolgreich  ·  Rot = Fehler  ·  Grau = nicht ausgeführt

---


---

## 🧭 Documentation: GitHub Pages Routing & Reactivation Report

This repository experienced a Pages deployment failure in late October 2025  
after a `--force --no-history` deploy, which caused GitHub Pages to disable itself  
and switch to `workflow` build mode.

The issue was diagnosed and fixed by reconfiguring the Pages API to **legacy (branch-based)** mode  
and redeploying a clean MkDocs build.

**Full technical report:**  
➡️ [docs/logs/pages_reactivation_report.md](docs/logs/pages_reactivation_report.md)

**Summary of Resolution:**
- Restored GitHub Pages (`status: built`, `build_type: legacy`)
- Verified branch deployment from `gh-pages`
- Fixed internal Markdown links (removed `.md` suffix routing)
- Rebuilt and redeployed successfully

This documentation is intended for future maintainers to preserve continuity  
and prevent reoccurrence of routing or Pages activation issues.

---
