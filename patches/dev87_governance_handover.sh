#!/bin/bash
set -e

# DEV-87: Governance Handover Document for Economic Layer v0.51.0

mkdir -p docs/reports logs

cat > docs/reports/DEV87_Governance_Handover_v051.md <<'EOD'
# 1kUSD Governance Handover – Economic Layer v0.51.0

## 1. Purpose

This document is a **technical governance handover** for the 1kUSD **Economic Layer v0.51.0** on an EVM-compatible environment (Kasplex-compatible, final deployment chain TBD).

It is intended for:

- **Core Maintainers**
- **Future Governance Multisig signers**
- **Risk Council members**
- **Guardians / Operators**

It explains:

- what the Economic Layer does,
- which parameters are **governance-sensitive**,
- which roles MUST do what,
- how safety, risk and monitoring are tied together.

This document uses the terminology of RFC 2119.

## 2. Scope & Version

- Economic Layer code baseline: **v0.51.0**
- PSM: **v0.50.0** (in-scope)
- BuybackVault: **Stages A–C** (in-scope)
- StrategyConfig: **as scaffolded and wired in v0.51.0**
- Oracle / OracleWatcher: **current v0.51.0 integration**
- Guardian / SafetyAutomata: **current pause and safeguard mechanisms**

Out of scope for this handover:

- future multi-asset buybacks,
- advanced automation/scheduler components,
- L2 bridge or cross-chain deployments,
- cross-chain PoR, multi-chain 1kUSD instances.

Any change beyond v0.51.0 MUST be documented and may require an updated handover document.

## 3. Roles & Responsibilities

The 1kUSD governance model distinguishes four primary technical roles:

### 3.1 Operator

The **Operator**:

- executes day-to-day operations within approved governance parameters,
- applies parameter changes that have been formally approved,
- manages deployments and upgrades (when authorized),
- configures monitoring and alerting.

The Operator MUST NOT:

- unilaterally change safety-critical parameters beyond approved ranges,
- bypass Guardian or Governor decisions.

### 3.2 Guardian

The **Guardian**:

- has authority to trigger **emergency actions**:
  - pausing selected modules,
  - activating/deactivating emergency modes,
  - enforcing protective configurations during incidents.
- acts according to documented runbooks and thresholds.

The Guardian MUST:

- act in the protocol’s safety interest,
- follow the **Emergency Depeg Runbook** (`docs/risk/emergency_depeg_runbook.md`),
- coordinate with Operator and Risk Council during incidents.

### 3.3 Governor

The **Governor**:

- defines the **long-term configuration** of the Economic Layer,
- approves:
  - collateral inclusion and removal,
  - major parameter changes,
  - large structural upgrades.

Governors MUST:

- base decisions on:
  - risk assessments,
  - audit results,
  - PoR and stress test data,
- avoid changes that **weaken safety margins** without clear rationale.

### 3.4 Risk Council

The **Risk Council**:

- designs and maintains the **risk framework**,
- proposes:
  - collateral limits,
  - PoR thresholds,
  - stress scenarios,
- monitors collateral and protocol health on an ongoing basis.

The Risk Council SHOULD:

- regularly review:
  - **Collateral Risk Profile** (`docs/risk/collateral_risk_profile.md`),
  - **PoR metrics** (`docs/risk/proof_of_reserves_spec.md`),
  - **stress test results** (`docs/testing/stress_test_suite_plan.md`).

## 4. Economic Layer Overview (v0.51.0)

At a high level, the Economic Layer v0.51.0 consists of:

1. **1kUSD Stablecoin Logic**  
   - minting and redemption according to protocol rules,
   - integration with the PSM.

2. **PSM v0.50.0 (Peg Stability Module)**  
   - handles swaps between 1kUSD and collateral (USDT, USDC),
   - enforces fees, limits, and bands to maintain the peg.

3. **Oracle Stack**  
   - Oracle Aggregator: collects prices for collaterals and 1kUSD pairs,
   - OracleWatcher: checks liveness, bounds, and sanity.

4. **Guardian / SafetyAutomata**  
   - emergency pauses and safety controls,
   - enforcement of safe behaviour in stressed conditions.

5. **BuybackVault (Stages A–C)**  
   - executes buybacks according to StrategyConfig,
   - interacts with collateral and target assets.

6. **StrategyConfig**  
   - holds strategy definitions and parameters for BuybackVault.

7. **Monitoring & Indexer Layer**  
   - PoR view contract(s) and off-chain snapshots,
   - BuybackVault indexer and KPIs,
   - general telemetry and alerting.

## 5. Governance-Sensitive Parameters

The following parameter categories are **governance-critical** and MUST be controlled by Governors and the Risk Council (with Operators only applying decisions).

### 5.1 PSM Parameters

Examples (exact names are implementation-dependent):

- per-asset swap limits (per tx, per block, per time window),
- fees and spreads,
- acceptable price/deviation bands,
- collateral-specific enable/disable flags.

**Impact**:

- Too permissive → risk of large flows during depeg, potential insolvency.
- Too restrictive → impaired peg maintenance and reduced liquidity.

Governors MUST ensure that PSM parameters are aligned with:

- collateral risk levels,
- liquidity conditions,
- stress test results.

### 5.2 Collateral Composition & Limits

Governance MUST define:

- which assets are **eligible collateral** (USDT, USDC, optional WBTC, WETH / ETH),
- maximum exposure per asset (e.g., percentage of total reserves),
- allowed ranges for portfolio shifts over time.

Changes to collateral composition MUST be:

- justified by updated risk assessments,
- reflected in the **Collateral Risk Profile** and **PoR** documents.

### 5.3 PoR Thresholds & Policies

Governance MUST define:

- target reserve ratio (e.g., > 100%),
- minimum threshold for safe operation (e.g., 10000 basis points for parity),
- conditions under which:

  - buybacks are slowed or suspended,
  - minting or redemptions are modified,
  - emergency modes are activated.

These settings MUST be coherent with:

- the **PoR Spec** (`docs/risk/proof_of_reserves_spec.md`),
- the **Emergency Depeg Runbook**.

### 5.4 BuybackVault & StrategyConfig

Governance MUST approve:

- which strategies are allowed (strategy types),
- per-strategy and global limits:
  - maximum notional per period,
  - slippage bounds,
  - whitelisted venues or paths (if applicable).

Risk-on or experimental strategies MUST be clearly identified and limited relative to total reserves.

### 5.5 Guardian & Operator Permissions

Governors MUST define:

- which actions are allowed by Guardians without prior governance vote,
- which actions require ex-post ratification,
- which actions are reserved strictly for Governors (e.g., changing core contracts or roles).

This distribution MUST ensure that safety-critical responses are fast, but not unbounded.

## 6. Safety & Risk Framework Linkage

The Economic Layer v0.51.0 is governed within a broader safety and risk framework:

- **Audit Plan** – `docs/security/audit_plan.md`  
  - defines how code and design are externally reviewed.

- **Bug Bounty Program** – `docs/security/bug_bounty.md`  
  - incentivizes responsible disclosure by external researchers.

- **PoR Spec** – `docs/risk/proof_of_reserves_spec.md`  
  - defines how reserves and liabilities are measured and exposed.

- **Collateral Risk Profile** – `docs/risk/collateral_risk_profile.md`  
  - describes qualitative and structural risks per collateral.

- **Emergency Depeg Runbook** – `docs/risk/emergency_depeg_runbook.md`  
  - defines operational steps for depeg scenarios.

- **Stress Test Suite Plan** – `docs/testing/stress_test_suite_plan.md`  
  - maps risk scenarios to systematic tests.

Governors and the Risk Council MUST use these documents together as a coherent set when making decisions.

## 7. Operational Governance Flows

### 7.1 Regular Parameter Changes

1. **Proposal (Risk Council / Maintainers)**  
   - draft parameter changes (e.g., PSM limits, collateral caps),
   - justify using PoR data, stress tests, and risk analysis.

2. **Review (Governors)**  
   - assess proposal vs. risk appetite and protocol goals.

3. **Approval (Governors)**  
   - on-chain or off-chain approval, depending on governance model.

4. **Execution (Operator)**  
   - apply changes within the agreed window,
   - confirm via monitoring and post-change checks.

### 7.2 Emergency Responses

1. **Detection & Alert (Monitoring + Risk Council)**  
   - triggered via telemetry and PoR alerts.

2. **Immediate Action (Guardian)**  
   - pause or restrict operations as defined in the runbook.

3. **Short-Term Governance Response (Governors + Risk Council)**  
   - refine emergency settings,
   - define criteria for resuming normal operations.

4. **Post-Incident Review**  
   - feed lessons back into:
     - stress test scenarios,
     - risk profiles,
     - governance thresholds.

### 7.3 Upgrades & Migrations

Before any Economic Layer upgrade:

- new version MUST be audited according to the **Audit Plan**,
- critical changes MUST be tested via the stress test suite,
- PoR implications MUST be understood,
- governance handover MUST be updated.

Governors MUST ensure that upgrades do not silently weaken safety properties.

## 8. Onboarding Checklist for New Governors / Maintainers

A new Governor or core Maintainer SHOULD be onboarded with at least the following steps:

1. **Document Familiarity**  
   - Read:
     - this handover document,
     - Audit Plan,
     - Bug Bounty Program,
     - PoR Spec,
     - Collateral Risk Profile,
     - Emergency Depeg Runbook,
     - Stress Test Suite Plan.

2. **System Overview**  
   - Review architecture and Economic Layer overview in the main documentation (README and design docs).

3. **Parameter Map**  
   - Receive a current snapshot of:
     - PSM parameters,
     - collateral composition and caps,
     - PoR thresholds,
     - Buyback strategies and limits.

4. **Monitoring & Alerting**  
   - Gain access to dashboards and alert channels (Prometheus/Grafana, explorers, etc.).

5. **Role-Specific Training**  
   - Guardian: run through simulated incident scenarios.
   - Operator: dry-run parameter changes on test/staging environments.
   - Governor / Risk Council: review historical decisions and rationale.

6. **Access Control Verification**  
   - Ensure appropriate keys, accounts and permissions are correctly configured and tested in a safe environment first.

## 9. Minimum Governance Practices

At minimum, the following practices SHOULD be maintained:

- **Multi-person decision-making**  
  - critical changes SHOULD require more than one individual’s approval.

- **Change logs and transparency**  
  - parameter changes and governance decisions SHOULD be logged and, where possible, disclosed.

- **Formalized incident handling**  
  - on-call responsibilities and escalation paths MUST be clear.

- **Periodic review**  
  - at least quarterly review of:
    - collateral composition,
    - PoR metrics,
    - stress test coverage,
    - incident reports (if any).

## 10. Handover Summary

This document summarizes the governance-relevant aspects of the 1kUSD Economic Layer v0.51.0.

New Governors, Guardians, Operators and Risk Council members MUST:

- understand the Economic Layer architecture and its safety mechanisms,
- operate within the defined risk and governance framework,
- keep this document and related specifications up to date as the protocol evolves.

Any material change to:

- collateral universe,
- core contracts,
- governance process,

MUST trigger a review and, if necessary, an updated version of this governance handover.

EOD

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") DEV-87 add governance handover document for Economic Layer v0.51.0" >> logs/project.log
