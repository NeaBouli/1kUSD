# 1kUSD Security Audit Plan  
## Economic Layer v0.51.0

## 1. Introduction

This document defines the security audit plan for the 1kUSD Economic Layer v0.51.0 deployed on an EVM-compatible environment (Kasplex-compatible, final deployment chain TBD).

The goal of this plan is to provide an auditable, repeatable process for identifying, triaging and remediating security issues in the core protocol components before and after mainnet deployment.

This document uses the terminology of RFC 2119. The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY" and "OPTIONAL" are to be interpreted as described in RFC 2119.

## 2. Scope Definition

### 2.1 In-Scope Components (v0.51.0)

The following components MUST be considered in scope for the initial audit wave:

- 1kUSD core token logic (stablecoin-facing Economic Layer contracts)
- PSM v0.50.0 (Peg Stability Module)
- Oracle system:
  - Oracle Aggregator
  - OracleWatcher / health gates
- Safety / control modules:
  - Guardian / SafetyAutomata
  - Pause / emergency controls
- BuybackVault (Stages A–C only)
- StrategyConfig (as currently scaffolded and wired in v0.51.0)
- Role-based access control and authorization surfaces
- Upgrade and configuration mechanisms relevant to the above (if any)
- Core economic parameters and limits directly controlling:
  - minting and redemption
  - collateral handling
  - buyback execution

All contracts and libraries that are transitively reachable from the above through delegatecalls or direct calls MUST be treated as part of the effective scope.

### 2.2 Out-of-Scope Items

The following items MUST be explicitly treated as out of scope for the v0.51.0 audit cycle and MAY be considered in later phases:

- Multi-asset buybacks
- Weighted buyback execution strategies
- Strategy automation / schedulers (off-chain or on-chain)
- TreasuryVault extensions beyond current v0.51.0 usage
- Any L2 bridge or cross-chain bridge infrastructure
- Cross-chain Proof-of-Reserves flows
- Multi-module Guardian pausing beyond the currently shipped module set
- Any feature not shipped as part of Economic Layer v0.51.0

Auditors SHOULD clearly restate this scope in their statements of work and final reports.

## 3. Objectives

The audit process MUST achieve the following objectives:

1. Identify critical vulnerabilities that can lead to:
   - loss or theft of funds
   - permanent depeg of 1kUSD
   - loss of control over protocol governance or Guardian roles
2. Detect high-severity economic or logical flaws that can:
   - break invariants of the PSM
   - bypass oracle safeguards
   - misroute or mis-account funds in BuybackVault
3. Validate that security controls and safety mechanisms:
   - behave as intended in both normal and stressed conditions
   - fail safe rather than fail open
4. Provide concrete, prioritized remediation guidance and verification steps.
5. Establish a baseline that future protocol changes MUST be measured against.

## 4. Assumptions & Threat Model

### 4.1 System Assumptions

The audit plan assumes:

- The underlying EVM chain provides standard consensus and finality guarantees.
- Deployed compiler versions, optimization settings, and toolchain parameters are fixed and reproducible.
- Off-chain actors (oracles, operators, indexers) follow the roles defined by the protocol specification.

Deviations from these assumptions MUST be documented and MAY require additional review.

### 4.2 Threat Actors (High-Level)

The following threat actors MUST be considered:

- External attackers without special privileges.
- Malicious or compromised privileged roles (Operator, Guardian, Governor).
- Economically motivated adversaries operating flash-loan based strategies.
- Oracle manipulators (price feeds, liquidity manipulation on reference markets).

The detailed threat model MAY be extended in a separate risk document and referenced from this plan.

## 5. Audit Phases

The audit program SHALL be structured into several phases.

### 5.1 Phase 0 – Internal Readiness Review

Before engaging external auditors, the core team SHOULD:

- Run internal static analysis (e.g., Slither).
- Run internal fuzz and property tests (Foundry, Echidna).
- Ensure documentation for each module is up to date.
- Freeze the v0.51.0 scope with a tagged commit and a deployment plan.

Deliverables:
- Internal checklist confirming readiness.
- Tag reference for the audit baseline (e.g., `v0.51.0-audit`).

### 5.2 Phase 1 – Primary External Audit

A primary audit SHOULD be performed by at least one reputable external firm (e.g., Trail of Bits, MixBytes, PeckShield, CertiK or similar). Independent auditors MAY also be engaged (e.g., individual reviewers).

Focus areas:

- PSM v0.50.0 invariants and limits.
- Oracle aggregation and OracleWatcher protections.
- Guardian / SafetyAutomata control plane.
- BuybackVault (Stages A–C) accounting and execution flows.
- StrategyConfig correctness and update surfaces.
- Role-based access control and upgradability patterns.

The firm MUST receive:

- Exact commit hash and tag for v0.51.0.
- Full contract set, including dependencies.
- Architectural and economic design documentation.
- Known issues list and assumptions.

### 5.3 Phase 2 – Secondary / Follow-up Audits (Optional)

Depending on the severity and volume of findings from Phase 1, additional audits MAY be scheduled:

- Follow-up verification of fixes.
- Focused reviews on:
  - Guardian / emergency flows
  - BuybackVault strategies
  - Oracle failover behavior

Optional independent reviewers MAY be allocated to cross-check critical areas already reviewed in Phase 1.

### 5.4 Phase 3 – Post-Deployment Monitoring & Review

After deployment, the team SHOULD:

- Monitor on-chain activity and telemetry for anomalies.
- Periodically reassess critical assumptions (collateral, oracles, liquidity).
- Schedule re-audits before major upgrades or parameter changes.

## 6. Methodology

External and internal auditors MUST apply a combination of the following techniques:

1. **Manual Code Review**  
   - Line-by-line review of core contracts.
   - Verification of invariants and safety properties.

2. **Static Analysis**  
   - Use tools such as Slither to detect:
     - reentrancy
     - unchecked external calls
     - dangerous delegatecalls
     - arithmetic edge cases
     - uninitialized storage or shadowing

3. **Fuzzing & Property Testing**  
   - Use tools such as Foundry and Echidna to:
     - encode key invariants for the PSM, BuybackVault and Guardian.
     - test a wide range of state transitions under adversarial inputs.

4. **Differential Testing (Where Applicable)**  
   - Compare behavior of implementations under varied oracle and collateral configurations.

5. **Economic & Game-Theoretic Analysis**  
   - Assess whether an attacker can profitably:
     - manipulate oracles,
     - bypass limits,
     - trigger harmful buybacks or redemptions.

Auditors SHOULD document which techniques were applied to which components and with what coverage.

## 7. Severity Classification & SLAs

Findings MUST be categorized at least into:

- Critical
- High
- Medium
- Low
- Informational

Severity criteria SHALL align with the bug bounty specification in `docs/security/bug_bounty.md` (DEV-81). Response time targets and remediation SLAs SHOULD be:

- Critical: immediate triage, patch design as soon as possible, on-chain fix prioritized.
- High: short-term remediation plan and implementation.
- Medium: planned for upcoming maintenance release.
- Low / Informational: addressed as part of ongoing refactors or documentation updates.

Exact reward mapping and timelines MUST be defined in the bug bounty document.

## 8. Fix-Wave & Verification Plan

### 8.1 Triage Wave

After receiving audit reports, the core team MUST:

- Acknowledge receipt within a defined timeframe.
- Classify each issue by severity and impact.
- Decide on remediation strategy (code change, parameter adjustment, documentation change).

### 8.2 Fix Wave

For all Critical and High findings:

- Remediation patches MUST be developed and internally reviewed.
- Additional tests and properties SHOULD be added to cover the identified class of issues.
- Changes MUST be based on the original audited tag and isolated into minimal, auditable diffs.

### 8.3 Retest Wave

External auditors SHOULD be engaged to:

- Verify that all Critical and High findings were correctly fixed.
- Confirm that fixes did not introduce new vulnerabilities.
- Produce an updated report or addendum.

Medium and Low findings MAY be optionally re-verified.

## 9. On-Chain Verification & Release Management

For each audited deployment, the following steps MUST be followed:

1. **Reference Tag**  
   - A Git tag (e.g., `v0.51.0-audit`) MUST correspond to the exact code used for deployment.

2. **Compiler & Settings**  
   - Compiler versions and optimization settings MUST be recorded.
   - These settings MUST match those used to produce the deployed bytecode.

3. **Contract Verification**  
   - Contracts MUST be verified on the relevant explorer (Etherscan-style) or equivalent verification system.
   - Verification links SHOULD be included in public documentation.

4. **Address Registry**  
   - All core component addresses (PSM, Oracle Aggregator, Guardian, BuybackVault, StrategyConfig) MUST be collected in a canonical registry document and/or on-chain registry.

5. **Change Control**  
   - Any change to audited contracts or parameters MUST:
     - be documented
     - be reviewed
     - pass through proper governance / Guardian flows
   - Material changes SHOULD trigger a new or partial audit.

## 10. Roles & Responsibilities

The following roles are expected in the audit process:

- **Core Developers (Operator role)**  
  - Provide code, documentation and support for auditors.
  - Implement fixes and additional tests.

- **Guardian / Safety Operators**  
  - Evaluate emergency procedures and operational runbooks.
  - Ensure operational readiness of pause and mitigation tools.

- **Governors / Risk Council**  
  - Decide on parameter changes and deployment timelines.
  - Approve major design changes that impact security assumptions.

- **External Auditors**  
  - Perform independent assessments.
  - Provide comprehensive reports with clear findings and recommendations.

Exact governance details SHALL be refined in `docs/reports/DEV87_Governance_Handover_v051.md`.

## 11. Dependencies & Integration Points

The audit MUST examine:

- Integration points between:
  - PSM and collateral tokens (USDT, USDC, optionally WBTC and WETH / ETH as risk-on collateral).
  - Oracles and pricing logic.
  - Guardian and protocol modules (PSM, BuybackVault, StrategyConfig).
- Assumptions regarding external contracts, such as:
  - ERC20 compliance of collaterals.
  - Behavior of external bridges or derivatives (even if out of scope, assumptions MUST be stated).

Where dependencies are outside full control of the protocol, auditors SHOULD note residual risks.

## 12. Documentation & Public Communication

The audit process MUST produce:

- At least one public-facing audit report or summary.
- Clear indication of:
  - commit hash
  - tag
  - deployment addresses
  - scope and out-of-scope items

The project SHOULD:

- Publish links to the reports in the README Security & Risk section.
- Clearly communicate limitations and residual risks to users and integrators.

## 13. Future Work

Future versions of the protocol (beyond v0.51.0) MAY require:

- New audits for:
  - multi-asset buybacks
  - advanced strategy automation
  - cross-chain PoR and bridging
- Extended threat models and risk frameworks.

Such work MUST NOT be assumed covered by the v0.51.0 audit and SHALL be tracked separately.

