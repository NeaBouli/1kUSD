# Economic Layer Overview (PSM + Oracle + BuybackVault)
**StrategyConfig (v0.51.0):**

### BuybackVault StrategyEnforcement – Phase 1 (v0.52.x Plan)

Für v0.52.x ist eine optionale „Phase 1“-Durchsetzung von Strategien vorgesehen:

- Flag: `strategiesEnforced` (bool, Default: `false`).
- Setter: `setStrategiesEnforced(bool enforced)` (nur DAO).
- Event: `StrategyEnforcementUpdated(bool enforced)`.

**Bedeutung für den Economic Layer:**

- `strategiesEnforced == false`  
  - BuybackVault verhält sich wie in v0.51.0: `StrategyConfig` dient primär der Dokumentation und Telemetrie.
- `strategiesEnforced == true`  
  - Buybacks laufen nur durch, wenn:
    - mindestens eine Strategie konfiguriert ist (`strategies.length > 0`), sonst Revert `NO_STRATEGY_CONFIGURED`;
    - eine aktivierte Strategie für das Ziel-Asset existiert, sonst Revert `NO_ENABLED_STRATEGY_FOR_ASSET`.
  - Guardian-/PSM-Checks bleiben unverändert aktiv.

Die Aktivierung von `strategiesEnforced` wird als Governance-Entscheidung behandelt und kann bei Bedarf wieder zurückgenommen werden, um in den v0.51.0-kompatiblen Modus ohne Strategy-Guard zurückzukehren.

  - A forward-looking strategy interface `IBuybackStrategy`
  (`contracts/strategy/IBuybackStrategy.sol`) is defined for v0.52+ to host
  external, upgradable buyback strategy modules. In v0.51.0 it is **not yet**
  wired into `BuybackVault` and only serves as a design anchor.

- BuybackVault hält eine minimale `StrategyConfig`-Schicht
  (asset / weightBps / enabled), um zukünftige Multi-Asset- und
  Policy-basierte Buybacks vorzubereiten.
- In v0.51.0 beeinflussen Strategien den `executeBuyback()`-Pfad noch nicht;
  sie dienen lediglich als Konfigurations- und Telemetrie-Basis.



Status: **v0.51.0 – Economic Layer + BuybackVault Stage A–C**

This document gives a high-level view of the 1kUSD economic layer and how the
following components interact:

- **PegStabilityModule (PSM)**
- **PSMSwapCore**
- **PSMLimits**
- **ParameterRegistry**
- **OracleAggregator + Watcher**
- **SafetyAutomata / Guardian**
- **BuybackVault**
- **TreasuryVault (context)**

It is a *map* to the more detailed specs:

- PSM architecture & invariants:  
  - \`docs/architecture/psm_dev43-45.md\`  
  - \`docs/architecture/psm_flows_invariants.md\`
- PSM parameters & governance:  
  - \`docs/architecture/psm_parameters.md\`  
  - \`docs/governance/parameter_playbook.md\`  
  - \`docs/governance/parameter_howto.md\`
- BuybackVault architecture & execution:  
  - \`docs/architecture/buybackvault_plan.md\`  
  - \`docs/architecture/buybackvault_execution.md\`
- Release notes:  
  - \`docs/releases/v0.50.0_economic-layer.md\`  
  - \`docs/releases/v0.51.0_buybackvault.md\`

---

## 1. Goals of the Economic Layer

The economic layer is responsible for:

1. **Maintaining the 1kUSD peg** via the PSM:
   - 1kUSD mint/redeem against a basket of collateral assets.
   - Explicit control over fees, spreads and limits.
2. **Guarding solvency and risk**:
   - Daily and per-tx limits on flows.
   - Oracle-driven health checks and pause conditions.
3. **Coordinated monetary operations**:
   - DAO-controlled buybacks of governance/LP tokens via BuybackVault.
   - Telemetry and on-chain events to support monitoring and audits.

The economic layer does **not** decide policy on its own; it provides the
mechanics that the **DAO** and **Risk Council** configure via governance.

---

## 2. Core Components

### 2.1 PegStabilityModule (PSM) + PSMSwapCore

**PegStabilityModule** is the main façade for end users and integrators:

- Exposes mint/redeem style flows:
  - \`swapTo1kUSD\`: collateral → 1kUSD (mint)
  - \`swapFrom1kUSD\`: 1kUSD → collateral (redeem)
- Delegates the actual pricing and fee logic to **PSMSwapCore**.

**PSMSwapCore**:

- Computes net in/out amounts given:
  - **Fees**: \`psm:mintFeeBps\`, \`psm:redeemFeeBps\`
  - **Spreads**: \`psm:mintSpreadBps\`, \`psm:redeemSpreadBps\`
  - Per-token overrides where configured in the ParameterRegistry.
- Enforces the invariant:  
  \`feeBps + spreadBps <= 10_000\`
- Is covered by:
  - \`foundry/test/PSMSwapCore.t.sol\`
  - PSM regression tests under \`foundry/test/psm/PSMRegression_*.t.sol\`

Detailed flows and invariants:  
See \`docs/architecture/psm_flows_invariants.md\`.

---

### 2.2 PSMLimits

**PSMLimits** enforces rate limits for PSM operations:

- **DailyCap**: total notional volume per day.
- **SingleTxCap**: maximum size per transaction.

Both are expressed in normalized units (aligned with the PSM decimallayer).

PSMLimits is wired into the PSM façade and guarded by DAO-only update
functions. The behaviour is covered by:

- \`foundry/test/PSMLimits.t.sol\`
- \`foundry/test/psm/PSMRegression_Limits.t.sol\`

Specification: \`docs/specs/PSM_LIMITS_AND_INVARIANTS.md\`.

---

### 2.3 ParameterRegistry

The **ParameterRegistry** is the single source of truth for:

- **PSM fees & spreads**:
  - Global keys:  
    - \`psm:mintFeeBps\`, \`psm:redeemFeeBps\`  
    - \`psm:mintSpreadBps\`, \`psm:redeemSpreadBps\`
  - Per-token overrides: keys are derived from the asset address.
- **Token decimals** for normalization.
- **Oracle health thresholds**:
  - \`oracle:maxStale\`
  - \`oracle:maxDiffBps\`

Resolution rules, examples and governance flows are described in:

- \`docs/architecture/psm_parameters.md\`
- \`docs/governance/parameter_playbook.md\`
- \`docs/governance/parameter_howto.md\`

---

### 2.4 OracleAggregator + Watcher

The **OracleAggregator** consumes adapter prices and applies health guards:

- Enforces **max staleness** and **max price jump** via registry parameters.
- Emits health status used by the **Watcher** (and indirectly by the Guardian).

Key ideas:

- Health can be marked **unhealthy** if:
  - Price is too old (\`maxStale\`).
  - Price jump exceeds \`maxDiffBps\`.
- Health can be effectively **disabled** by setting thresholds to \`0\`
  (safe, explicit opt-out).

The oracle regression stack lives in:

- \`foundry/test/oracle/OracleRegression_Health.t.sol\`
- \`foundry/test/oracle/OracleRegression_Watcher.t.sol\`
- \`docs/reports/DEV41_ORACLE_REGRESSION.md\`
- \`docs/specs/ORACLE_AGGREGATOR_SPEC.md\` and  
  \`docs/specs/ORACLE_AGGREGATION_GUARDS.md\`

---

### 2.5 SafetyAutomata / Guardian

The **SafetyAutomata** acts as a central pause controller for modules:

- Modules are identified by a **\`bytes32 moduleId\`**.
- Exposes checks like:
  - \`isPaused(moduleId)\`
- Can be wired into:
  - PSM flows.
  - Oracle aggregation paths.
  - BuybackVault.

Guardian-related tests and docs:

- \`foundry/test/Guardian_*.t.sol\`
- \`docs/specs/GUARDIAN_SAFETY_RULES.md\`
- \`docs/reports/DEV37_GuardianPSMIntegration.md\`
- \`docs/reports/DEV38_GuardianPSMUnpause.md\`

The design ensures that **one central pause decision** can immediately
propagate to all sensitive economic modules.

---

### 2.6 BuybackVault

The **BuybackVault** is a DAO-controlled contract that executes buybacks via
the PSM:

- Holds:
  - Surplus **1kUSD** (stable).
  - Target **asset** to be bought back (e.g. governance token or LP token).
- Exposes DAO-only functions:
  - \`fundStable(amount)\` – move surplus 1kUSD into the vault.
  - \`withdrawStable(to, amount)\` – emergency drain of 1kUSD.
  - \`withdrawAsset(to, amount)\` – emergency drain of the bought-back asset.
  - \`executeBuyback(recipient, amountStable, minAssetOut, deadline)\` –
    route 1kUSD through the PSM into the target asset.

Execution path:

1. DAO calls \`executeBuyback\` with parameters.
2. BuybackVault checks:
   - caller is DAO,
   - \`recipient != 0\`,
   - \`amountStable > 0\`,
   - module not paused via \`isPaused(moduleId)\`,
   - sufficient stable balance.
3. Vault approves the PSM for \`amountStable\`.
4. Calls \`PSM.swapFrom1kUSD(asset, amountStable, recipient, minAssetOut, deadline)\`.
5. Emits **\`BuybackExecuted(recipient, stableIn, assetOut)\`**.

Events:

- \`StableFunded(dao, amount)\`
- \`StableWithdrawn(to, amount)\`
- \`AssetWithdrawn(to, amount)\`
- \`BuybackExecuted(recipient, stableIn, assetOut)\`

Errors cover zero-address cases, invalid amounts, and insufficient balance.

Implementation & tests:

- \`contracts/core/BuybackVault.sol\`
- \`foundry/test/BuybackVault.t.sol\`
- Architecture & execution docs:
  - \`docs/architecture/buybackvault_plan.md\`
  - \`docs/architecture/buybackvault_execution.md\`
- Release notes:
  - \`docs/releases/v0.51.0_buybackvault.md\`

---

### 2.7 TreasuryVault (Context)

The **TreasuryVault** remains the primary treasury holder:

- Holds protocol-owned assets (e.g. governance tokens, LP positions).
- Is expected to interact with BuybackVault via DAO-governed flows:
  - Treasury can send surplus assets to BuybackVault.
  - BuybackVault can accumulate and/or redistribute bought-back assets.

Detailed rules for vaults and settlement:

- \`docs/specs/VAULT_PSM_SETTLEMENT.md\`
- \`docs/specs/VAULT_WITHDRAW_RULES.md\`
- Related tests under \`foundry/test/TreasuryVault.t.sol\`.

---

## 3. Governance & Parameters

All parameter changes for the Economic Layer are expected to flow through
the **governance pipeline**:

- Registry keys and resolution order are documented in  
  \`docs/architecture/psm_parameters.md\`.
- The **Parameter Playbook** describes typical changes:
  - Adjust fees/spreads in response to market conditions.
  - Tune PSMLimits caps based on volume and liquidity.
  - Adjust oracle health thresholds for specific markets.
- The **Parameter How-To** guides DAO and Risk Council operators step by step.

Supporting documents:

- \`docs/governance/parameter_playbook.md\`
- \`docs/governance/parameter_howto.md\`
- \`docs/governance/proposals/psm_parameter_change_template.json\`

---

## 4. Telemetry & Monitoring

The economic layer relies on structured telemetry for:

- Peg stability monitoring.
- Oracle health status.
- PSM flows and buyback events.

Telemetry is handled by the indexer layer:

- Spec: \`indexer/docs/INDEXING_TELEMETRY.md\`
- Schemas:
  - \`indexer/schemas/event_dto.schema.json\`
  - \`indexer/schemas/health.schema.json\`
  - \`indexer/schemas/por_rollup.schema.json\`
- Sample vectors:
  - \`tests/vectors/health.sample.json\`
  - \`tests/vectors/por_rollup.sample.json\`

BuybackVault telemetry hooks:

- Buyback events can be consumed as part of the standard event DTO stream.
- The README links the BuybackVault telemetry section to the indexer specs.

---

## 5. Release Alignment

The current Economic Layer baseline is captured in:

- \`docs/releases/v0.50.0_economic-layer.md\`  
  – PSM + Oracle consolidation.
- \`docs/releases/v0.51.0_buybackvault.md\`  
  – BuybackVault Stage A–C (PSM execution, events, telemetry docs).

Future work (beyond v0.51.0):

- Multi-asset BuybackVault strategies (multiple target assets).
- Scheduling / DCA-style strategy modules.
- Extended Guardian rules for selective module and asset-level pauses.
- Additional regression suites for complex buyback policies.


## Oracle dependencies – architecture clarification (Dec 2025)

> Internal architect note  
> This section clarifies that 1kUSD is deliberately **oracle-secured**.  
> It corrects external summaries that suggested an "oracle-free" target.

- 1kUSD is **not** oracle-free. Price feeds are a fundamental part of the
  economic design and are required by:
  - the PegStabilityModule (PSM) for pricing and limits,
  - the BuybackVault safety layer (A02) for health checks,
  - the guardian/safety stack for stress signalling.

- Disabling stale/diff checks for a given oracle **does not** mean
  the PSM can operate without a price feed. A PSM without a valid price
  feed is considered **economically broken** and must be treated as a
  configuration error.

- Any future "Kaspa-native" deployments must therefore still assume
  oracle-secured behaviour at the protocol layer. Reducing oracle
  surface area is a valid goal; removing oracles entirely is not.

This clarification is normative for future economic, integration and
governance documents.
