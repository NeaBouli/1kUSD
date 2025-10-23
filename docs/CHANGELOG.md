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
