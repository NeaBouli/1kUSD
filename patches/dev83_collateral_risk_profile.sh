#!/bin/bash
set -e

# DEV-83: Collateral Risk Profile for 1kUSD Economic Layer v0.51.0

mkdir -p docs/risk logs

cat > docs/risk/collateral_risk_profile.md <<'EOD'
# 1kUSD Collateral Risk Profile  
## Economic Layer v0.51.0

## 1. Overview

This document defines the collateral risk profile for the 1kUSD Economic Layer v0.51.0 on an EVM-compatible environment (Kasplex-compatible, final deployment chain TBD).

The focus is on collateral assets held by the protocol to back 1kUSD:

- **Primary collateral (stablecoins)**:
  - USDT (ERC20, Ethereum mainnet)
  - USDC (ERC20, Ethereum mainnet)
- **Optional "risk-on" collateral**:
  - WBTC (ERC20)
  - WETH / ETH (ERC20)

This risk profile provides a structured assessment of:

- depeg risk,
- counterparty risk,
- regulatory risk,
- oracle risk,
- liquidity risk,
- stress scenarios.

It uses the terminology of RFC 2119 for normative statements.

## 2. Risk Dimensions

The following dimensions are used across all collateral types:

1. **Depeg Risk**  
   - Risk that the asset deviates significantly from its intended reference value (e.g., 1 USD).

2. **Counterparty / Issuer Risk**  
   - Risk that the issuer or custodian fails, becomes insolvent, or otherwise cannot honour redemptions.

3. **Regulatory / Jurisdictional Risk**  
   - Risk that regulators impose restrictions or actions that materially affect the asset (freezes, sanctions, forced redemptions).

4. **Oracle / Price Discovery Risk**  
   - Risk that price feeds are manipulated, stale, or diverge from real market prices.

5. **Liquidity & Market Structure Risk**  
   - Risk that sufficient depth does not exist on spot/AMM markets to execute required trades without excessive slippage.

6. **Technical / Smart Contract Risk**  
   - Risk that the token contract itself, or critical infrastructure around it, contains bugs or behaves unexpectedly.

For each collateral, this document provides a qualitative assessment and outlines mitigation measures that the protocol SHOULD apply.

## 3. Primary Collateral: USDT (ERC20)

### 3.1 Depeg Risk

USDT aims to track 1 USD but has historically shown:

- short-lived deviations around market stress events,
- exchange-specific or localized liquidity imbalances.

**Risk**:  
- Moderate depeg risk under severe market stress.  
- Short-term deviations of a few percent are plausible; extreme events MAY see larger deviations.

**Mitigations**:

- PSM parameters MUST limit single-block and aggregate flows involving USDT.
- Maximum USDT share in total reserves SHOULD be capped (e.g., via governance-controlled limits).
- 1kUSD PoR logic SHOULD treat USDT at a conservative valuation when signs of stress appear.

### 3.2 Counterparty / Issuer Risk

USDT is issued by a centralized entity holding reserves off-chain.

**Risk**:

- Centralized issuer and banking relationships introduce credit and operational risk.
- Asset backing and transparency have historically been debated.

**Mitigations**:

- Risk Council SHOULD regularly review issuer attestations and third-party analyses.
- Governance SHOULD be able to adjust:
  - maximum allowed USDT exposure,
  - PSM configuration to reduce USDT reliance if risk increases.
- Diversification across multiple stablecoins (e.g., USDC) is RECOMMENDED.

### 3.3 Regulatory Risk

USDT operates across multiple jurisdictions.

**Risk**:

- Regulatory enforcement actions MAY target the issuer, banking partners, or specific counterparties.
- Frozen or blacklisted addresses (via token contract controls) can impact liquidity.

**Mitigations**:

- Protocol vault addresses SHOULD avoid engaging with sanctioned or high-risk counterparties.
- Governance SHOULD retain the ability to unwind or reduce USDT exposure in response to regulatory events.
- Monitoring of issuer blacklist activity SHOULD be part of operational procedures.

### 3.4 Oracle / Price Risk

USDT price is generally close to 1 USD but can deviate on:

- thinly traded pairs,
- stressed centralized exchanges.

**Risk**:

- Oracles that rely on limited venues MAY report distorted prices.
- Short-lived spikes or drops can trigger undesired PSM flows.

**Mitigations**:

- Oracles SHOULD aggregate prices from multiple reputable venues and pairs.
- Outlier rejection and TWAP mechanisms SHOULD be used to prevent spurious ticks.
- OracleWatcher MUST enforce bounds and liveness checks.

### 3.5 Liquidity Risk

USDT has deep liquidity on major centralized and decentralized venues.

**Risk**:

- Liquidity can become fragmented across chains and pools.
- Extreme scenarios (exchange failures, chain congestion) MAY temporarily impair exit capacity.

**Mitigations**:

- 1kUSD rebalancing operations SHOULD be sized relative to observed liquidity.
- Risk Council SHOULD periodically re-evaluate:
  - depth of USDT markets used by the protocol,
  - maximum trade size per operation.

## 4. Primary Collateral: USDC (ERC20)

### 4.1 Depeg Risk

USDC aims to track 1 USD with fully reserved backing in fiat or equivalents.

**Risk**:

- Depeg events MAY occur around:
  - issuer banking issues,
  - systemic shocks.

Historical precedent has shown temporary depegs when underlying bank partners were under stress.

**Mitigations**:

- PSM parameters MUST limit excessive inflow of USDC during suspected depeg events.
- Oracles SHOULD track both on-chain and off-chain reference prices where possible.
- Risk Council SHOULD define explicit policies for:
  - how to treat USDC during known stress,
  - how to rebalance between USDT and USDC.

### 4.2 Counterparty / Issuer Risk

USDC is centralized, with reserves held in off-chain financial instruments and accounts.

**Risk**:

- Issuer failure, mismanagement, or regulatory intervention COULD impact redemptions.
- Concentration of reserves in particular instruments or banks introduces systemic exposure.

**Mitigations**:

- Regular review of issuer transparency reports and audits is RECOMMENDED.
- The protocol SHOULD avoid overconcentration in USDC beyond defined risk thresholds.
- Governance MUST retain the authority to alter PSM parameters to reduce USDC exposure if risk increases.

### 4.3 Regulatory Risk

USDC and its issuer operate under stricter regulatory regimes relative to some other stablecoins.

**Risk**:

- Regulatory changes MAY:
  - improve oversight and safety,
  - or restrict usage in certain regions or for certain addresses.

**Mitigations**:

- Protocol operators SHOULD monitor regulatory communications affecting USDC.
- Vault address policies MUST respect applicable sanctions and compliance requirements.
- If regulatory risk escalates, Risk Council SHOULD consider diversification or reallocation strategies.

### 4.4 Oracle / Price Risk

USDC typically trades close to 1 USD with high liquidity.

**Risk**:

- Short-term divergence from 1 USD during market stress.
- Potential for oracle feeds to be skewed if only a subset of markets is considered.

**Mitigations**:

- Oracles SHOULD:
  - include multiple chain venues where relevant,
  - apply conservative aggregation and outlier filtering.
- OracleWatcher MUST enforce price sanity checks and liveness guarantees.

### 4.5 Liquidity Risk

USDC enjoys deep liquidity across major CEX and DEX platforms.

**Risk**:

- Localized liquidity shocks MAY occur on specific venues.
- Cross-chain bridging for USDC introduces additional layers of risk not covered here.

**Mitigations**:

- The protocol SHOULD prefer native mainnet liquidity over bridged liquidity whenever possible.
- Rebalancing operations SHOULD respect liquidity conditions and transaction cost constraints.

## 5. Optional Risk-On Collateral: WBTC (ERC20)

### 5.1 Depeg & Market Risk

WBTC represents wrapped Bitcoin on Ethereum.

**Risk**:

- Although WBTC itself generally tracks BTC, BTC is volatile:
  - sudden price movements can rapidly change reserve value.
- Depeg between WBTC and BTC (custodial/technical issues) is possible but historically rare.

**Mitigations**:

- Protocol SHOULD treat WBTC as "risk-on" and limit its share in reserves.
- Conservative haircuts in PoR and risk calculations SHOULD be applied.
- WBTC MAY be excluded from reserve ratio calculations in extreme stress scenarios.

### 5.2 Counterparty / Issuer Risk

WBTC relies on custodians redeeming BTC for WBTC and vice versa.

**Risk**:

- Custodian failure or operational issues can freeze redemptions.
- Centralized control may introduce additional tail risks.

**Mitigations**:

- Risk Council SHOULD review custodian governance and transparency.
- WBTC exposure SHOULD be capped with thresholds set by governance.
- Participation of multiple custodians (if applicable) SHOULD be tracked.

### 5.3 Oracle & Liquidity Risk

WBTC inherits BTC market structure plus Ethereum-specific liquidity.

**Risk**:

- Rapid BTC price movements can propagate to WBTC with latency.
- Extreme market moves MAY expose PSM and BuybackVault to large PnL swings.

**Mitigations**:

- Oracles SHOULD use robust BTC/USD references for WBTC pricing.
- Stress testing MUST simulate large BTC drawdowns and spikes.

## 6. Optional Risk-On Collateral: WETH / ETH (ERC20)

### 6.1 Volatility & Market Risk

ETH is a highly liquid but volatile asset.

**Risk**:

- Large, rapid price swings can materially change reserve value.
- Using ETH as backing for a USD-pegged stablecoin inherently introduces market risk.

**Mitigations**:

- ETH exposure SHOULD remain a limited fraction of total reserves.
- Risk Council MUST define maximum ETH share and rebalancing rules.
- PoR calculations SHOULD apply conservative haircuts to ETH-based reserves.

### 6.2 Liquidity & Oracle Risk

ETH has deep liquidity and widely quoted prices.

**Risk**:

- Oracle manipulation on specific pairs is possible.
- DeFi-specific events (e.g., liquidations, large MEV) MAY cause short-term dislocations.

**Mitigations**:

- Oracles MUST aggregate prices from multiple ETH/USD venues.
- OracleWatcher SHOULD enforce strict liveness checks and outlier filters.
- Stress tests MUST cover ETH-specific tail events.

## 7. Cross-Cutting Risks & Interactions

### 7.1 Correlation Risk

Stablecoins and risk-on assets MAY be exposed to correlated shocks:

- Regulatory actions affecting multiple issuers.
- Systemic crypto market crashes.
- Liquidity dry-ups during macro events.

Mitigations:

- Diversification across multiple stablecoins SHOULD be used but MUST NOT be over-relied on as a guarantee.
- Risk Council SHOULD define portfolio-level risk limits considering correlations.

### 7.2 Oracle Risk Across Assets

All collateral types depend on reliable price feeds.

Mitigations:

- Use multiple data sources and robust aggregation mechanisms.
- Clearly define fallback behaviours when oracle data is unavailable or stale.
- Ensure that critical protocol operations MUST fail safely if price data cannot be trusted.

### 7.3 Liquidity Spiral Risk

Simultaneous stress on multiple collaterals MAY create:

- slippage spirals,
- feedback loops between redemptions and market impact.

Mitigations:

- Limit rebalancing and redemption rates under stressed conditions.
- Avoid forced selling at any price; prefer controlled unwinds.

## 8. Governance & Parameterization

The following governance roles are relevant for collateral risk management:

- **Operator**  
  - Implements configuration changes within approved risk parameters.

- **Guardian**  
  - Executes emergency actions (pauses, circuit breakers) when risk thresholds are breached.

- **Governor**  
  - Votes on collateral inclusion, limits, and structural risk changes.

- **Risk Council**  
  - Proposes risk frameworks and parameter sets, monitors collateral health, and coordinates with other roles.

Parameters that MUST be governed include:

- maximum exposure per collateral (as percentage of total reserves),
- PSM limits per asset and per time interval,
- oracle configuration and bounds,
- thresholds for emergency actions (e.g., PoR ratio levels).

## 9. Stress Scenarios (High-Level)

The following stress scenarios SHOULD be considered in testing and risk review:

1. **USDT depeg event**  
   - USDT trades at a significant discount for multiple days.
   - PSM and BuybackVault behaviour MUST be analysed under reduced USDT valuations.

2. **USDC banking / custody stress**  
   - Partial depeg or redemption delays.
   - Governance MUST be able to reduce USDC exposure and adjust parameters.

3. **Crypto market crash**  
   - Sharp drop in BTC and ETH prices.
   - Impact on WBTC and WETH reserves, PoR ratio, and buyback strategies MUST be evaluated.

4. **Oracle failure**  
   - Stale or incorrect prices for one or more collaterals.
   - OracleWatcher and Guardian flows MUST demonstrate safe behaviour.

5. **Liquidity drain**  
   - Diminished depth on major trading venues.
   - Execution costs for rebalancing operations increase; protocol MUST avoid panic selling.

Detailed quantitative stress tests are defined in `docs/testing/stress_test_suite_plan.md` (DEV-85).

## 10. Summary

This collateral risk profile provides a qualitative and structural assessment of the main collateral assets backing 1kUSD in Economic Layer v0.51.0.

It MUST be kept up to date as:

- new collateral assets are added or removed,
- market structures and regulations evolve,
- protocol design or parameters change materially.

Any material change in collateral composition or risk environment SHOULD trigger a review of this document and associated risk and PoR specifications.

EOD

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") DEV-83 add collateral risk profile for Economic Layer v0.51.0" >> logs/project.log
