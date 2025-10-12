# 1kUSD — Technical Architecture (Overview, EN)

**Core Modules**
- Token: ERC-20 compatible, mint/burn restricted to protocol modules.
- CollateralVault: Holds stablecoins (USDT/USDC/DAI); withdrawals only via protocol paths.
- AutoConverter: Best-execution routing from volatile assets to stablecoins; outputs to Vault.
- PSM (Peg-Stability Module): 1:1 swap 1kUSD <-> stablecoins with minimal fee and caps.
- OracleAggregator: Multi-feed median with deviation/staleness checks.
- Safety-Automata: Central policy enforcement (pause/resume, caps, rate limits); no asset custody.
- DAO/Timelock: Parameter & upgrade governance via time-delayed execution.
- Treasury: Fee sink and governed spending.
- Bridge Anchor (prep): Message/proof spec towards Kasplex/Kaspa.

**Off-Chain**
- Indexer (REST/GraphQL): Proof-of-reserves, peg drift, PSM volumes, exposure caps, pause states.
- Monitoring/Telemetry: Metrics & alerts for peg integrity, oracle health, circuit breakers.
- CI/CD & Security: Tests (unit/integration/fuzz), audits, signed releases.

**Clients**
- SDKs (TS/Go/Rust/Python), reference dApp/Explorer.

> Detailed specifications will be added through dedicated developer tasks (interfaces first, then implementation).
