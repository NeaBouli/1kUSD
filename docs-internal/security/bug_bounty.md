# 1kUSD Bug Bounty Program  
## Economic Layer v0.51.0

## 1. Overview

This document defines the bug bounty program for the 1kUSD Economic Layer v0.51.0 deployed on an EVM-compatible environment (Kasplex-compatible, final deployment chain TBD).

The purpose of this program is to incentivize responsible disclosure of security vulnerabilities in the protocol's core components and to reduce the risk of loss of funds, depeg events, or governance compromise.

This document uses the terminology of RFC 2119. The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY" and "OPTIONAL" are to be interpreted as described in RFC 2119.

## 2. Scope

### 2.1 In-Scope Components

The following components are considered in scope for this bug bounty program, aligned with the audit plan for Economic Layer v0.51.0:

- Core Economic Layer contracts related to the 1kUSD stablecoin.
- PSM v0.50.0 (Peg Stability Module) and its parameters.
- Oracle system:
  - Oracle Aggregator
  - OracleWatcher / health gates
- Guardian / SafetyAutomata and pause/emergency mechanisms.
- BuybackVault (Stages A–C only).
- StrategyConfig as integrated in v0.51.0.
- Role-based access control and privileged operations affecting the above.
- Upgrade and configuration mechanisms that directly impact in-scope components.

Any contract or module that is transitively reachable from these components and can cause loss of funds or depeg events MAY be treated as in scope, at the discretion of the Bug Bounty Committee.

### 2.2 Out-of-Scope Items

The following items are out of scope for this bug bounty program:

- Multi-asset buybacks and weighted buyback execution.
- Strategy automation / schedulers (off-chain or on-chain).
- TreasuryVault extensions beyond current v0.51.0 integration.
- L2 or cross-chain bridges and non-EVM assets.
- Cross-chain Proof-of-Reserves flows.
- Multi-module Guardian pausing beyond the currently shipped modules.
- Third-party services, infrastructure, wallets, or exchanges.
- Frontend UX issues that do not impact security or funds.
- Denial-of-service (DoS) issues that do not lead to permanent loss of funds or governance control.
- Spam, phishing, or social engineering against team members or community.

The Bug Bounty Committee MAY, at its sole discretion, treat an otherwise out-of-scope issue as in scope if it is deemed to pose a material risk.

## 3. Eligibility & Rules

To be eligible for a reward, researchers MUST follow these rules:

- Act in good faith and avoid privacy violations, destruction of data, or service degradation beyond what is necessary to prove the vulnerability.
- Do NOT exploit a vulnerability to access, transfer, or freeze funds that do not belong to you.
- Do NOT perform attacks that could cause irreversible damage, including but not limited to:
  - large-scale fund loss,
  - permanent depeg,
  - chain-wide disruption.
- Do NOT use automated scanning or exploitation in a way that could be reasonably considered abusive or harmful to users or infrastructure.
- Comply with all applicable laws and regulations in your jurisdiction and any relevant jurisdiction.
- Follow the coordinated disclosure process defined in this document.

The Bug Bounty Committee MAY declare a submission ineligible if these rules are violated.

## 4. Severity Classification

Findings MUST be classified into severity levels, broadly aligned with the security audit plan:

- **Critical**  
  - Vulnerabilities that can lead directly to:
    - total or near-total loss of protocol funds,
    - permanent depeg of 1kUSD,
    - irrevocable governance or Guardian capture.

- **High**  
  - Vulnerabilities that can:
    - cause substantial but partial loss of funds,
    - temporarily break critical invariants (e.g., PSM limits, oracle bounds),
    - cause severe mispricing or mis-accounting without an easy recovery.

- **Medium**  
  - Vulnerabilities that:
    - require significant preconditions or complex setups,
    - may impact specific users or edge cases,
    - degrade safety margins but are unlikely to cause system-wide collapse.

- **Low**  
  - Vulnerabilities that:
    - have minimal impact on safety or funds,
    - are misconfigurations or minor logic flaws with limited exploitability,
    - relate to best practices and defense-in-depth.

Informational findings (e.g., documentation gaps, minor gas optimizations) MAY be acknowledged but are typically not rewarded.

The final severity is determined by the Bug Bounty Committee, which MAY adjust it relative to the reporter’s initial assessment.

## 5. Rewards

### 5.1 Reward Currencies

Rewards will be paid primarily in **KAS**. For lower-severity issues (Medium/Low), the committee MAY choose to pay part or all of the reward in **1kUSD**.

### 5.2 Reward Ranges

The following ranges are indicative and MAY be adjusted based on:

- actual impact,
- exploit complexity,
- quality of the report and proof-of-concept,
- existence of prior reports for the same issue.

- **Critical**: up to **50,000 KAS**  
- **High**: approximately **5,000–10,000 KAS**  
- **Medium**: approximately **1,000–2,000 KAS** (may include 1kUSD)  
- **Low**: approximately **250–500 KAS** (may include 1kUSD)

Multiple reports for the same underlying issue MAY be consolidated, in which case the Bug Bounty Committee decides the distribution of the reward.

There is no guarantee that every report will receive a reward. The final decision on reward and amount rests solely with the Bug Bounty Committee, in coordination with the Protocol Treasury Multisig and relevant governance roles.

## 6. Reporting Process

### 6.1 Submission Channel

Researchers SHOULD use a dedicated security contact address (for example: `security@<project-domain>`) or another official channel announced by the project to submit their findings.

Submissions SHOULD include:

- A clear and concise description of the vulnerability.
- A severity assessment (Critical/High/Medium/Low).
- Step-by-step instructions to reproduce the issue.
- Proof-of-concept code or transactions, if applicable.
- Any suggested mitigations or remediation ideas (OPTIONAL but RECOMMENDED).

Where possible, reporters MAY encrypt sensitive details using a published PGP key for the security contact.

### 6.2 Acknowledgment & Triage

The project SHOULD:

- Acknowledge receipt of a valid security report within a reasonable timeframe (e.g., 72 hours).
- Begin triage and classification as soon as practical.
- Provide periodic updates to the reporter on triage and remediation progress, subject to operational constraints.

The Bug Bounty Committee, in collaboration with core developers and the Risk Council, SHALL determine severity and eligibility for a bounty.

## 7. Disclosure Policy

This bug bounty program follows a coordinated disclosure model:

- Reporters MUST NOT publicly disclose vulnerabilities, exploit details, or proof-of-concept code before:
  - the vulnerability has been remediated, and
  - a reasonable notice period has been provided to users, if necessary.
- The project MAY publish a post-mortem or incident report for Critical/High issues, including:
  - a description of the vulnerability,
  - impact assessment,
  - mitigation steps taken,
  - recommendations for users and integrators.
- If a reporter and the project disagree on timelines, both parties SHOULD make reasonable efforts to reach an agreement that balances user safety, transparency, and operational constraints.

The project MAY credit researchers by name or handle in public acknowledgements, subject to their consent.

## 8. Treasury & Governance Handling

Rewards are funded and approved by:

- **Protocol Treasury Multisig** (funding and final approval),
- **Bug Bounty Committee** (triage, severity assessment, recommendations),
- In coordination with:
  - **Guardian Council** (if emergency actions or protocol pauses are needed),
  - **Risk Council** (for systemic risk assessment and follow-up measures).

In the event that a vulnerability requires emergency actions (e.g., Guardian-triggered pause, parameter changes), the bug report MAY be shared with the Guardian Council under strict confidentiality to coordinate mitigation.

All treasury movements for bounty payouts SHOULD be transparent and, where feasible, linked to the corresponding anonymized or pseudonymized report ID.

## 9. Non-Qualifying Reports

The following categories of issues are generally not eligible for rewards, unless they have an unexpectedly severe impact:

- Issues in third-party platforms, libraries, or infrastructures not operated by the project.
- Attacks requiring compromised end-user wallets or private keys.
- Reports of outdated dependencies that do not directly affect security.
- Low-impact best practice recommendations without a clear security implication.
- Non-exploitable theoretical issues without a plausible attack path.
- Social engineering, phishing, or impersonation attacks.
- Physical attacks against infrastructure or personnel.

The Bug Bounty Committee MAY still acknowledge such reports and track them internally.

## 10. Legal

By participating in this bug bounty program, you agree:

- to comply with all applicable laws in your jurisdiction and any other relevant jurisdiction;
- not to exploit vulnerabilities for any purpose other than testing and reporting;
- not to engage in extortion, threats, or coercion;
- that the project and its contributors are not obligated to enter into any contract beyond what is stated in this document.

The project reserves the right to modify, suspend, or terminate this bug bounty program at any time, including changes to scope, rewards, and rules.

