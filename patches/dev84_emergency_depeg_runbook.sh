#!/bin/bash
set -e

# DEV-84: Emergency Depeg Runbook for 1kUSD Economic Layer v0.51.0

mkdir -p docs/risk logs

cat > docs/risk/emergency_depeg_runbook.md <<'EOD'
# 1kUSD Emergency Depeg Runbook  
## Economic Layer v0.51.0

## 1. Purpose & Scope

This runbook defines the procedural steps, roles and decision criteria for responding to depeg events affecting:

- the 1kUSD stablecoin itself, and/or
- the collateral assets backing 1kUSD (USDT, USDC, optionally WBTC, WETH / ETH),

on an EVM-compatible environment (Kasplex-compatible, final deployment chain TBD).

It is intended for use by Operators, Guardians, Governors and the Risk Council. It MUST be kept up to date with Economic Layer releases and parameter changes.

This document uses the terminology of RFC 2119.

## 2. Roles

The following roles are involved in depeg response:

- **Operator**  
  - Executes technical actions (parameter updates, contract interactions) within approved boundaries.

- **Guardian**  
  - Triggers emergency controls (pauses, circuit breakers) when pre-defined thresholds are breached.

- **Governor**  
  - Approves structural changes and medium-/long-term responses (e.g., collateral removal, policy changes).

- **Risk Council**  
  - Monitors markets and protocol metrics, proposes emergency measures, coordinates multi-role response.

External participants (e.g., auditors, indexer operators, community contributors) MAY be consulted but have no direct authority under this runbook.

## 3. Depeg Types & Severity Levels

### 3.1 Depeg Types

The runbook distinguishes three primary depeg types:

1. **Collateral depeg**  
   - One or more collateral assets (USDT, USDC, WBTC, WETH / ETH) deviate significantly from their reference value.

2. **1kUSD market depeg**  
   - 1kUSD trades materially away from 1 USD on secondary markets, despite underlying collateral being intact.

3. **Systemic / multi-asset depeg**  
   - Simultaneous stress across multiple collaterals and/or 1kUSD itself.

### 3.2 Severity Levels (Indicative)

Severity MAY be classified as:

- **Level 1 – Alert**  
  - Short-lived deviation within a small band (e.g., 0.98–1.02) for key assets.
  - No immediate threat to solvency.

- **Level 2 – Incident**  
  - Sustained deviation beyond small band (e.g., 0.95–1.05) or visibly stressed liquidity conditions.

- **Level 3 – Emergency**  
  - Severe, sustained deviation (e.g., < 0.9 or > 1.1) or strong evidence of issuer failure, regulatory shutdown, or chain-level crisis.

Exact numerical thresholds MUST be defined and maintained in the parameter set governed by the Risk Council and Governors.

## 4. Monitoring & Detection

### 4.1 Inputs

Detection SHOULD rely on:

- On-chain prices via the oracle stack (with OracleWatcher safeguards).
- Off-chain market data from major CEX/DEX venues for:
  - USDT/USD
  - USDC/USD
  - BTC/USD (for WBTC)
  - ETH/USD (for WETH / ETH)
  - 1kUSD/USD or 1kUSD/stablecoin pairs.

- PoR metrics:
  - reserve ratios from the PoR view contract,
  - 6h PoR snapshots and JSON reports.

- Liquidity and slippage metrics on main trading venues.

### 4.2 Automated Alerts

Telemetry and monitoring SHOULD:

- Raise alerts when:
  - prices move outside configured bands for a sustained period,
  - reserve ratio drops below target values,
  - PoR snapshots are delayed or missing,
  - unusual PSM or BuybackVault flows occur.

Guardians and the Risk Council MUST be reachable via pre-defined emergency channels (e.g., secure messaging groups or incident response tools).

## 5. Initial Triage (T0–T1)

When an alert is fired, the following triage process applies:

1. **Confirm signal validity (Operator + Risk Council)**  
   - Cross-check multiple data sources (oracles, CEX data, DEX prices).
   - Ensure there is no obvious oracle misconfiguration or feed outage.

2. **Classify severity and depeg type**  
   - Collateral depeg vs. 1kUSD-only vs. systemic.
   - Approximate magnitude and duration.

3. **Assess immediate risk**  
   - Impact on solvency (PoR ratio).
   - Impact on user redemptions and PSM flows.
   - Presence of active exploit or manipulation attempts.

If severity is classified as Level 2 or Level 3, Guardians MUST be prepared to trigger pre-approved emergency actions as described below.

## 6. Emergency Actions – Collateral Depeg

This section covers cases where one or more collaterals show significant depeg or issuer risk.

### 6.1 Immediate Actions (Guardian + Operator)

For Level 2 or Level 3 collateral depeg:

- **Step 1 – Rate limiting & parameter tightening**  
  - Operator SHOULD reduce PSM limits and/or increase fees for the affected collateral(s).
  - Where supported, minting or swap directions that increase exposure to the distressed asset MAY be temporarily disabled.

- **Step 2 – BuybackVault restriction**  
  - Strategies that rely heavily on the distressed asset MUST be paused or limited.
  - New buyback operations involving that collateral SHOULD be temporarily halted.

- **Step 3 – PoR signposting**  
  - PoR view contracts and JSON reports SHOULD explicitly reflect:
    - stressed valuation of the distressed asset,
    - updated reserve ratio under conservative assumptions.

### 6.2 Further Actions (Governors + Risk Council)

If conditions deteriorate or remain severe:

- Consider **partial or full removal of the affected collateral** from the eligible set.
- Define a **controlled unwind plan** to reduce exposure over time, avoiding panic selling.
- Communicate clearly to users and integrators about:
  - affected assets,
  - protocol response,
  - expected next steps.

## 7. Emergency Actions – 1kUSD Market Depeg

This section covers cases where 1kUSD itself trades away from 1 USD despite collateral being mostly healthy.

### 7.1 Diagnosis

Risk Council MUST determine whether the depeg is driven by:

- liquidity imbalances (thin markets),
- confidence or narrative shocks,
- technical issues in PSM, oracles, or integrations,
- broader system or regulatory concerns.

### 7.2 Mitigation Steps

Depending on cause and severity:

- **Enhance market support**  
  - Where permitted by policy, the protocol MAY incentivize liquidity provision or adjust PSM parameters to improve on-chain support.

- **Review PSM behaviour**  
  - Operators MUST check whether:
    - PSM limits are too tight,
    - fee structures are misaligned,
    - certain directions of flow are blocked unintentionally.

- **Assess communication needs**  
  - Provide factual, non-promotional status updates:
    - current PoR metrics,
    - protocol health indicators,
    - actions being taken.

If depeg persists despite adequate collateral backing and functional PSM, Governors and the Risk Council MUST consider structural adjustments (e.g., parameter re-balancing, clarifying collateral policies).

## 8. Emergency Actions – Systemic / Multi-Asset Depeg

When multiple collaterals and/or the 1kUSD token are simultaneously stressed:

### 8.1 Guardian Response

- Guardians MAY trigger partial or full pause of:

  - PSM operations,
  - selected redemption or minting flows,
  - certain BuybackVault strategies.

- The goal is to **prevent uncontrolled feedback loops** and buy time for analysis.

### 8.2 Risk Council & Governors

- Perform a rapid but thorough assessment of:
  - overall reserve ratio under conservative haircuts,
  - cross-market liquidity,
  - regulatory or macro events driving the shock.

- Decide on:

  - target reserve composition post-crisis,
  - conditions for resuming normal operations,
  - whether any collaterals MUST be fully unwound or replaced.

## 9. Communication Plan

Clear communication is critical during depeg events.

### 9.1 Principles

- Communications MUST be:
  - factual,
  - non-misleading,
  - free of unwarranted assurances.

- Sensitive operational details (e.g., specific key management or vulnerabilities) MUST NOT be disclosed before mitigations are in place.

### 9.2 Channels

- Official website / documentation updates.
- Public announcements on major community channels.
- Optional: incident reports or post-mortems for severe events.

### 9.3 Content Guidelines

For Level 2–3 events, communications SHOULD cover:

- Nature of the event (collateral vs. 1kUSD vs. systemic).
- Current reserve ratio (with conservative estimates).
- Immediate steps taken (pauses, parameter changes).
- Expected short-term roadmap (re-evaluation windows, decision points).

## 10. Timelines & Checkpoints

Indicative timelines for Level 2–3 incidents:

- **T0–1h**  
  - Detection and triage.
  - Initial classification and decision if emergency actions are needed.

- **T1–6h**  
  - Execution of first-line emergency actions.
  - Initial communication to users and integrators.
  - Monitoring of market reaction and collateral movements.

- **T6–48h**  
  - Reassessment of risk, with:
    - updated PoR snapshots,
    - revised reserve ratios.
  - Decision on sustained measures (collateral caps, removals, or re-weighting).

- **T48h+**  
  - Consolidation into a medium-term plan.
  - If necessary, governance proposals for structural changes.

Exact timelines MUST be adapted to incident severity and evolving conditions.

## 11. Post-Incident Review

After conditions stabilize, a post-incident review SHOULD be conducted:

- **Technical review**  
  - Evaluate protocol behaviour under stress:
    - PSM flows,
    - oracle performance,
    - Guardian / pause actions,
    - BuybackVault interactions.

- **Process review**  
  - Assess responsiveness of:
    - detection systems,
    - communication channels,
    - coordination between roles.

- **Parameter review**  
  - Adjust collateral limits, PSM parameters, and monitoring thresholds where warranted.

Key findings SHOULD be documented and referenced in:

- the stress test suite plan (`docs/testing/stress_test_suite_plan.md`),
- the governance handover document (`docs/reports/DEV87_Governance_Handover_v051.md`).

## 12. Relationship to Other Documents

This runbook is part of a broader safety and risk framework:

- **Audit Plan** – `docs/security/audit_plan.md`  
  Defines how vulnerabilities and design flaws are identified and remediated.

- **Bug Bounty Program** – `docs/security/bug_bounty.md`  
  Defines incentives and processes for responsible disclosure.

- **Proof-of-Reserves Spec** – `docs/risk/proof_of_reserves_spec.md`  
  Defines how reserves and liabilities are measured and exposed.

- **Stress Test Suite Plan** – `docs/testing/stress_test_suite_plan.md`  
  Defines how depeg and stress scenarios are translated into systematic tests.

This runbook MUST remain consistent with these documents and SHOULD be updated whenever major changes are introduced to the protocol or collateral universe.

EOD

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") DEV-84 add emergency depeg runbook for Economic Layer v0.51.0" >> logs/project.log
