# Threat Model — Specification
**Scope:** Systematic analysis of protocol threats across contracts, governance, and infra.  
**Status:** Spec (no code). **Language:** EN.

## Method
- STRIDE + asset-centric review (Vault funds, Token supply, Governance power, Oracles, Rate-Limits).
- Trust boundaries: User ↔ PSM ↔ Vault; Oracles; DAO/Timelock; Indexer/UI; RPC/Nodes.

## Assets
- Stable reserves in Vault; 1kUSD supply; parameter integrity; timelock queue; oracle correctness; rate-limit state; pause authority.

## Adversaries
- On-chain attacker (arbitrary EOA/contract), privileged key compromise (multisig signer), oracle feeder manipulation, MEV searcher, malicious ERC-20 (fee-on-transfer/decimals change), infra/RPC outage.

## Entry Points
- PSM swaps; Vault withdraw (Timelock only); Registry/Safety setters (Timelock only); Token mint/burn (gated); Oracle updates; Governance queue/execute.

## Abuse Cases (examples)
- Reentrancy on PSM/Vault; cap or rate-limit bypass; mint without deposit; burn bypass; oracle stale/deviation; timelock param griefing; pause evasion; accounting drift (6 vs 18 decimals); governance capture; indexer reorg desync.

## Controls (references)
- Safety-Automata (pause, caps, rate limits, guardian sunset), Parameter Registry, DAO/Timelock delays, OracleAggregator guards, Treasury accounting (fees stay in Vault), Event catalog for reconciliation, Indexer finality.

## Residual Risks
- Oracle cartel risk (multi-source but correlated); governance capture with long-term token dynamics; RPC centralization; front-end censorship (mitigate via multiple mirrors).
