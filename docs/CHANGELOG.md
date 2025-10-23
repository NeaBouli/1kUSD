## 2025-10-12 — DEV1 (Docs Lead)
- Added bilingual whitepaper: `docs/whitepaper/WHITEPAPER_1kUSD_DE.md` and `..._EN.md`
- Updated docs index and aligned architecture/API references
## 2025-10-12 — DEV2 (Repo Governance)
- Added `CONTRIBUTING.md` (EOF workflow, CI gates, PR process)
- Added `CODEOWNERS` (placeholder)
- Added `.editorconfig`
- Added `SECURITY.md` (private reporting via GitHub Advisories)
## 2025-10-12 — DEV3 (CI/CD)
- Replaced `.github/workflows/ci.yml` with a functional minimal pipeline (bootstrap/lint/test/reports placeholders)
- Added `reports/README.md`
## 2025-10-12 — DEV4 (Interfaces/Specs)
- Added `interfaces/ONCHAIN_EVENTS.md` (event catalog for all modules)
- Added `interfaces/RPC_API.md` (public JSON-RPC/WebSocket spec)
- Added `interfaces/INDEXER_API.md` (REST/GraphQL read-only spec)
## 2025-10-12 — DEV5 (PSM Spec & Invariants)
- Added `contracts/specs/PSM_SPEC.md` (parameters, fees, caps, rate limits, guards, state machine)
- Added `contracts/specs/INVARIANTS.md` (system-wide invariants & safety properties)
## 2025-10-12 — DEV6 (Safety & Governance Hooks Specs)
- Added `contracts/specs/SAFETY_AUTOMATA_SPEC.md` (policies, state machine, guards, guardian sunset)
- Added `contracts/specs/GOVERNANCE_HOOKS_SPEC.md` (DAO/Timelock executor, parameter flows)
## 2025-10-12 — DEV7 (Vault & PoR Specs)
- Added `contracts/specs/COLLATERAL_VAULT_SPEC.md` (ingress/egress, caps, decimals, errors, events)
- Added `contracts/specs/PROOF_OF_RESERVES_SPEC.md` (views, reconciliation, finality, telemetry)
## 2025-10-12 — DEV8 (Oracle & Feeds Specs)
- Added `contracts/specs/ORACLE_AGGREGATOR_SPEC.md` (aggregation, guards, finality)
- Added `contracts/specs/PRICE_FEEDS_SPEC.md` (adapter requirements for Chainlink/Pyth/DEX-TWAP)
## 2025-10-12 — DEV9 (AutoConverter & Routing Specs)
- Added `contracts/specs/AUTOCONVERTER_SPEC.md` (routing, slippage, oracle sanity, safety)
- Added `contracts/specs/ROUTING_ADAPTERS_SPEC.md` (adapter interface & safety requirements)
## 2025-10-12 — DEV10 (DAO/Timelock & Treasury & Params Specs)
- Added `contracts/specs/DAO_TIMELOCK_SPEC.md` (roles, lifecycle, delays)
- Added `contracts/specs/TREASURY_SPEC.md` (fee accounting, spend path via Vault)
- Added `contracts/specs/PARAMETER_REGISTRY_SPEC.md` (canonical parameter map & events)
## 2025-10-12 — DEV11 (Client/SDK Specs)
- Added TS/Go/Rust/Python SDK specs under `clients/specs/`
- Added common error taxonomy, event decoding, and tx build flows
## 2025-10-12 — DEV12 (Reference dApp/Explorer Specs)
- Added reference app specs: REF_DAPP_SPEC, UX_FLOWS, API_CONTRACTS, ACCESSIBILITY_I18N
## 2025-10-12 — DEV13 (Testplan & CI Extensions)
- Added test specs: TESTPLAN, FORMAL_INVARIANTS_MAP, SECURITY_ANALYSIS
- Added CI reports schema and expanded CI skeleton with artifacts
## 2025-10-12 — DEV14 (PSM Specs)
- Added `contracts/specs/PSM_SPEC.md` (swap flows, fees, guards, events, errors)
- Added `contracts/specs/RATE_LIMITS_SPEC.md` (sliding window model shared by modules)
## 2025-10-12 — DEV15 (Token & Access Control Specs)
- Added `contracts/specs/TOKEN_SPEC.md` (mint/burn gates, permit, pause interop)
- Added `contracts/specs/ACCESS_CONTROL_SPEC.md` (roles, governance wiring, enforcement)
## 2025-10-12 — DEV16 (Deployment & Environments Specs)
- Added ops specs: DEPLOYMENT_ENVIRONMENTS, RELEASE_PROCESS, SECRETS_HANDLING, EMERGENCY_PLAYBOOKS
- Added placeholder address registries under ops/config/
## 2025-10-12 — DEV17 (Indexer & Data Model Specs)
- Added indexer specs: ENTITY_MODEL, INGESTION_PIPELINE, API_SPEC, SCHEMA
## 2025-10-12 — DEV18 (Threat Modeling & Risk Register)
- Added security specs: THREAT_MODEL, RISK_REGISTER, ATTACK_TREES, MITIGATIONS_MAP
## 2025-10-12 — DEV19 (Telemetry & Monitoring Specs)
- Added telemetry specs: METRICS_SPEC, ALERTS_SLOS_SPEC, HEALTH_ENDPOINTS_SPEC
## 2025-10-12 — DEV20 (Integration Blueprints)
- Added integration specs: WALLETS_PAYMENTS_SPEC, BRIDGES_CEX_LISTINGS_SPEC, PARTNER_APIS_ADAPTERS_SPEC
## 2025-10-12 — DEV21 (Gas & Fee Accounting Specs)
- Added GAS_POLICY_SPEC (targets, patterns, CI gates)
- Added FEE_ACCOUNTING_SPEC (formulas, events, edge cases)
- Added MATH_ROUNDING_RULES (mulDiv, floor policy, quoting)
## 2025-10-12 — DEV22 (Bridging/Migration Roadmap)
- Added bridging specs: MIGRATION_ROADMAP, BRIDGE_ARCH_OPTIONS, COMPAT_LAYER_SPEC
## 2025-10-12 — DEV23 (Legal/Compliance Notes)
- Added informational legal docs: LEGAL_STANCE, JURISDICTIONS_CHECKLIST, DISCLOSURES
## 2025-10-12 — DEV24 (Reference dApp Specs)
- Added dApp specs: REFERENCE_DAPP_UX, COMPONENTS_SPEC, STATUS_API_WIRING
## 2025-10-12 — DEV25 (Operational Playbooks v1)
- Added playbooks: RELEASE_REHEARSAL, PARAM_CHANGE_RUNBOOK, INCIDENT_DRY_RUN
## 2025-10-12 — DEV25 (Operational Playbooks v1)
- Added playbooks: RELEASE_REHEARSAL, PARAM_CHANGE_RUNBOOK, INCIDENT_DRY_RUN
## 2025-10-12 — DEV26 (Security Contest Prep)
- Added contest docs: CONTEST_SCOPE, RULES, FINDINGS_TEMPLATE, PAYOUT_MAP
## 2025-10-12 — DEV27 (Release v0 Meta-Checklist & Freeze Gates)
- Added release specs: RELEASE_CANDIDATE_CRITERIA, FREEZE_GATES_CHECKLIST, SIGNOFFS_EVIDENCE
## 2025-10-12 — DEV28 (Spec Consistency)
- Added central docs/INDEX.md with cross-links
- Appended README pointer to INDEX.md
- Added placeholder link-check workflow and config
## 2025-10-12 — DEV29 (Bootstrap Code Stubs)
- Added Solidity interfaces: I1kUSD, IPSM, IVault, IOracleAggregator, ISafetyAutomata, IParameterRegistry
- Added empty contract stubs: OneKUSD, PegStabilityModule, CollateralVault, OracleAggregator, SafetyAutomata, DAOTimelock
## 2025-10-12 — DEV30 (Build/Tooling Skeleton)
- Added Foundry skeleton (`foundry/foundry.toml`, script stub, remappings)
- Added Hardhat skeleton (package.json, tsconfig.json, hardhat.config.ts, .npmrc)
- Added BUILD_TOOLING.md and placeholder CI build workflow
## 2025-10-12 — DEV31 (Coding Kickoff: Token minimal)
- Implemented minimal OneKUSD token: ERC-20 core, gated mint/burn, pause affects only mint/burn, admin roles (to be Timelock later), custom errors
- Excludes permit (EIP-2612) for now, per TOKEN_SPEC optional
## 2025-10-13 — DEV32 (PSM minimal skeleton)
- Added minimal PegStabilityModule: admin/registry wiring, pause/deadline guards, IPSM signatures, stub quotes/swaps (NOT_IMPLEMENTED)
## 2025-10-13 — DEV33 (Vault minimal skeleton)
- Added CollateralVault minimal skeleton: admin/registry wiring, pause guard, supported-assets toggle, IVault signatures; deposit/withdraw stubs (NOT_IMPLEMENTED)
## 2025-10-13 — DEV34 (OracleAggregator minimal skeleton)
- Added OracleAggregator minimal skeleton: admin/registry wiring, pause guard, OracleUpdated event, IOracleAggregator stub (no pricing logic)
## 2025-10-13 — DEV35 (SafetyAutomata minimal skeleton)
- Added SafetyAutomata minimal skeleton: admin/registry wiring, pause/unpause events, read-only interface stubs (no caps/rate-limit logic)
## 2025-10-13 — DEV36 (DAO Timelock minimal skeleton)
- Added minimal DAOTimelock: admin wiring, minDelay placeholder, queue/cancel/execute events; execute() is a stub (NOT_IMPLEMENTED)
## 2025-10-13 — DEV37 (ParameterRegistry minimal skeleton)
- Added ParameterRegistry: admin setUint/setAddress/setBool; read-only getters per interface; no validations yet
## 2025-10-13 — DEV38 (Wire-up Pass v0)
- Added ops/config addresses templates (template, staging, testnet, mainnet)
- Added Admin/Wiring notes
- Updated README to reference addresses templates
## 2025-10-13 — DEV39 (Build sanity CI)
- Added GitHub Actions: hardhat compile with artifact upload; Foundry fmt placeholder
- Updated BUILD_TOOLING.md with CI notes
## 2025-10-13 — DEV40 (PSM minimal+: whitelist & dummy quotes)
- Extended PSM with supported-token whitelist and pass-through quotes (gross=amountIn, fee=0, net=amountIn)
- Swaps remain NOT_IMPLEMENTED; no fund movements yet
## 2025-10-13 — DEV41 (Vault minimal+)
- CollateralVault: added batch getter `areAssetsSupported(address[])`; `balanceOf` remains dummy; no transfer/accounting logic yet
## 2025-10-13 — DEV42 (Oracle minimal+: admin mock prices)
- OracleAggregator: added admin `setPriceMock` and mock storage; `getPrice` serves mock values (dev/staging only)
## 2025-10-13 — DEV43 (Token minimal+: EIP-2612)
- Added IERC2612 interface and implemented `permit` in OneKUSD
- Domain separator is chainId-aware; `nonces` tracked per owner
- No changes to transfer logic; pause still gates only mint/burn
## 2025-10-13 — DEV44 (Parameter keys & staging params)
- Added docs/PARAMETER_KEYS.md (canonical bytes32 keys reference)
- Added ops/config/params.staging.json with example values for dev/staging
- Updated README with parameters section
## 2025-10-13 — DEV45 (Deploy placeholders)
- Added Foundry placeholder deploy script (encodes ctor args; no broadcast)
- Added Hardhat placeholder deploy script (reads config; prints wiring; no deploy)
- Added ops/specs/DEPLOY_PLACEHOLDERS.md
## 2025-10-13 — DEV46 (Docs hardening)
- Added JSON Schemas for addresses and params; embedded `$schema` in config JSONs
- Added docs/JSON_VALIDATION.md and updated README with validation notes
## 2025-10-13 — DEV47 (Safety docs pass)
- Added Guardian Sunset checklist (docs/SAFETY_GUARDIAN_CHECKLIST.md)
- Added ops runbooks: EMERGENCY_DRILLS.md and INCIDENT_TEMPLATE.md
## 2025-10-13 — DEV48 (dApp scaffolding docs)
- Added docs/dapp/README.md and ROUTES.md (information architecture + routes)
- Added apps/dapp placeholders (public/brand.svg, src/README, folder marker)
## 2025-10-13 — DEV49 (SDK wiring guide)
- Added SDK wiring guide and TS examples (addresses loader, params+RPC)
- Updated README; added clients/specs overview
## 2025-10-13 — DEV50 (PSM quote semantics)
- Added docs/PSM_QUOTE_SEMANTICS.md (decimals normalization, fees, rounding, invariants, examples)
- Updated README with cross-reference
## 2025-10-13 — DEV51 (Vault accounting plan)
- Added docs/VAULT_ACCOUNTING_PLAN.md (math, caps, fees, decimals policy, invariants)
- Added docs/NOTES_VAULT_ACCOUNTING.md (reviewer notes)
## 2025-10-13 — DEV52 (PSM swap execution plan)
- Added docs/PSM_SWAP_EXECUTION_PLAN.md (CEI, guards, vault interactions, fees, events)
- Added docs/NOTES_PSM_EXECUTION.md (reviewer notes)
## 2025-10-13 — DEV53 (Safety docs set)
- Added Safety Pause Matrix, Module IDs, Error Catalog, Guardian Sunset Hooks
- Updated README with cross-links
## 2025-10-13 — Patch: PSM swap execution plan language
- Rewrote docs/PSM_SWAP_EXECUTION_PLAN.md in English (removed German fragments).
## 2025-10-13 — DEV54 (interfaces polish)
- Added minimal Solidity interfaces: IPSM, IVault, IOracleAggregator, IParameterRegistry, ISafetyAutomata, I1kUSD (+ IERC2612 if missing)
- Added interfaces README overview
## 2025-10-13 — DEV55 (parameter keys canon)
- Added canonical parameter keys doc with composite derivation rules
- Added params JSON schema & template
- Added TS SDK helpers (key/compositeKey)
- Updated README with cross-links

2025-10-13 — DEV56 (deployment skeletons)

Added env templates (.env.example, staging/testnet samples)

Added Foundry skeleton (foundry.toml, compile-only test)

Added Hardhat skeleton (config + TS scripts), address template emitter

Added deploy CI skeleton and README quickstart

2025-10-13 — DEV57 (events & abi)

Added canonical event ABIs: PSM, Vault, Token (JSON)

Added indexer notes for topics, reconciliation, finality, and edge cases

2025-10-13 — DEV58 (sdk event decoders)

Added TS decoders for PSM/Vault/Token events (clients/sdk/events.ts)

Added example (clients/examples/decode-events.ts) and docs

2025-10-13 — DEV59 (indexer schemas)

Added JSON schemas for swaps, fees, and vault snapshots

Added sample records and documentation
## 2025-10-13 — DEV60 (psm quote math)
- Added normative math for PSM quotes (rounding/decimals/fee order)
- Added machine-readable test vectors for USDC/WETH cases
- Added usage notes for unit/invariant tests
## 2025-10-13 — DEV61 (vault accounting edges)
- Added vault accounting edge cases doc (FoT, decimals, caps)
- Added machine-readable vectors for FoT/cap boundary cases
- Added vault test guide with mock FoT hints
## 2025-10-13 — DEV62 (oracle aggregation guards)
- Added normative doc for multi-source aggregation (median/trimmed-mean), staleness and deviation guards
- Added machine-readable vectors for healthy/stale/outlier/trimmed cases
- Added oracle test guide

2025-10-13 — DEV63 (safety rate-limiter)

Added sliding-window rate-limiter spec (window/maxAmount, scopes, buckets)

Added machine-readable vectors and a focused test guide

2025-10-13 — DEV64 (governance wiring)

Added governance param writes flow (Timelock -> ParameterRegistry)

Added proposal JSON schema and sample

Added calldata composer script (TS)

Added Guardian sunset rehearsal runbook

Updated README with governance links

2025-10-13 — DEV65 (token permit eip-2612)

Finalized OneKUSD EIP-2612 Permit spec (domain, struct, digest, rules)

Added machine-readable vectors and TS helper to build/sign permits

Added test guide for domain, replay, expiry, and ECDSA checks

2025-10-13 — DEV66 (invariants bundle)

Added executable mapping from formal invariants to concrete checks

Added consolidated invariants suite plan and default config JSON

Added harness notes for PSM/Vault/Governance invariant runs

2025-10-13 — DEV67 (configs & address book)

Added per-chain deploy config schema + local/testnet/mainnet samples

Added canonical address book schema + sample

Added JSON validator and .env emitter scripts

Updated README with usage instructions

2025-10-13 — DEV68 (localnet/staging bootstraps)

Added localnet scripts (start/stop/seed/deploy-skeleton)

Added staging bootstrap runbook (Base Sepolia example)

Added bootstrap quickstart and README links

2025-10-13 — DEV69 (ci gates)

Added CI gates doc with red/green criteria

Added collate script (node) to enforce gates from JSON artifacts

Added placeholders generator and updated CI workflow to wire jobs

2025-10-13 — DEV70 (security pre-audit pack)

Added pre-audit README and formal threat model

Added static-analysis baseline config/args and generator script

Added submission manifest and bundle script (ZIP)

2025-10-13 — DEV71 (sdk wire-up)

Added minimal TS SDK with address book helpers, permit helpers, oracle aggregation helper

Added examples wiring vectors (permit/oracle)

Updated README with SDK usage

2025-10-13 — DEV72 (indexer read models)

Added canonical read models schema (blocks, tokenSupply, vaultBalances, psmSwaps, events)

Added event decode table mapping (PSM/Vault/Token)

Added sample queries (REST/GraphQL) and a sample dataset

Updated README with Indexer section

2025-10-13 — DEV73 (psm math)

Added canonical PSM quote formulas and rounding rules (docs)

Added quote JSON vectors and TS evaluator script

README updated with PSM Math references
