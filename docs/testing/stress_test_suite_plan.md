# 1kUSD Stress Test Suite Plan  
## Economic Layer v0.51.0

## 1. Purpose

This document defines the stress test and adversarial testing plan for the 1kUSD Economic Layer v0.51.0 on an EVM-compatible environment (Kasplex-compatible, final deployment chain TBD).

The plan describes *what* MUST be tested and *how* it SHOULD be tested using:

- Foundry (forge) for fuzzing, property testing, fork tests,
- Echidna for additional property/invariant testing,
- Slither for static analysis and pattern-based checks.

It focuses on identifying failures or weaknesses in:

- PSM v0.50.0,
- Oracle Aggregator and OracleWatcher,
- Guardian / SafetyAutomata (pause and emergency controls),
- BuybackVault (Stages A–C) and StrategyConfig,
- collateral risk handling (USDT, USDC, optional WBTC, WETH / ETH).

This document does not define concrete test implementations, only the design and coverage requirements.

## 2. Tooling

### 2.1 Foundry (forge)

Foundry MUST be the primary test harness for:

- unit and integration tests,
- fuzzing of protocol entry points,
- mainnet fork tests for realistic liquidity and oracle conditions.

Expected usage:

- `forge test` for baseline regression suites,
- `forge test --fuzz-runs <N>` for property-based fuzz tests,
- `forge test --fork-url <RPC>` for fork-based stress tests.

### 2.2 Echidna

Echidna SHOULD be used to express high-level invariants and protocol properties, especially around:

- PSM invariants (no free value creation, peg bounds),
- oracle assumptions (bounded prices, stable ordering),
- Guardian / pause behaviour (safety invariants),
- BuybackVault safety (no loss of funds under allowed operations).

Tests MUST encode explicit invariants rather than expected traces.

### 2.3 Slither

Slither SHOULD be used to:

- detect common vulnerability patterns (reentrancy, tx-origin misuse, etc.),
- flag uninitialized variables, storage collisions, or unexpected inheritance complexity,
- check simple, automated invariants around arithmetic and access control.

Static analysis MUST complement but not replace manual review.

## 3. Core Stress Themes

Stress testing MUST cover at least the following themes:

1. **Flash-loan and multi-block attacks**  
   - attempts to profit from transient states or oracle lags.

2. **Oracle manipulation and lag**  
   - stale data, sudden jumps, and partial venue failures.

3. **Guardian and pause abuse / misconfiguration**  
   - ensuring safety mechanisms fail safe, not fail open.

4. **Vault drain and approval surface attacks**  
   - preventing systematic draining of protocol reserves.

5. **Buyback misrouting and strategy misconfiguration**  
   - ensuring buybacks do not send funds to wrong assets or addresses.

6. **Parameter edge cases and limit behaviour**  
   - behavior at or near configured economic limits.

## 4. PSM Stress Tests

### 4.1 Invariants

Stress tests MUST verify that, under adversarial sequences of operations:

- No sequence of PSM operations can create unbacked 1kUSD (no free minting).
- Redemptions respect configured bounds and do not underpay users.
- System cannot be trivially drained of collateral through fee or rounding exploits.
- PSM behaves reasonably under extreme but valid inputs (max sizes, repeated calls).

### 4.2 Flash-Loan Scenarios

Foundry-based fuzz and scenario tests SHOULD simulate:

- Large flash-loan-based swaps through the PSM in rapid succession.
- Price oscillations within a single block and across adjacent blocks.
- Attempts to exploit rounding or fee calculations to gain value.

### 4.3 Depeg & Boundary Behaviour

Tests MUST cover:

- USDT or USDC price deviating from 1 USD within configured tolerances.
- PSM response when an oracle feed flags a collateral as out of acceptable bands.
- Step changes in PSM limits (e.g., tightening in emergency) and how existing positions are affected.

## 5. Oracle & OracleWatcher Stress Tests

### 5.1 Stale and Missing Data

Tests MUST simulate:

- oracles returning stale prices beyond acceptable liveness thresholds,
- partial outage of price feeds or data sources,
- reversion to fallback or conservative values.

Expected behaviours:

- OracleWatcher MUST flag stale data and MAY block dependent operations.
- Protocol MUST fail safe: critical functions SHOULD revert rather than proceed on untrusted data.

### 5.2 Price Manipulation Attempts

Tests SHOULD attempt:

- temporary price spikes or crashes in individual venues,
- divergences between on-chain and off-chain observed prices,
- feed skew in favour of attackers.

Metrics and checks:

- maximum tolerated deviation before safety triggers.
- absence of obvious arbitrage windows allowing unbacked 1kUSD creation.

## 6. Guardian / SafetyAutomata Stress Tests

### 6.1 Emergency Pauses

Tests MUST verify that:

- guard/pause functions can be triggered under configured conditions,
- once paused, the system:

  - blocks sensitive operations (minting, redemptions, buybacks),
  - preserves existing balances and invariants.

- resuming operations requires explicit action and cannot be bypassed by regular users.

### 6.2 Abuse Resistance

Tests SHOULD simulate:

- repeated toggling of pause states,
- attempts by misconfigured or compromised Guardian roles to create unsafe states,
- interactions between Guardian actions and oracles / PSM / BuybackVault.

The system MUST be designed so that Guardian misuse cannot silently break invariants without being observable at the state or event level.

## 7. BuybackVault & StrategyConfig Stress Tests

### 7.1 Buyback Execution Safety

Tests MUST check that:

- buyback operations do not send funds to arbitrary or attacker-controlled addresses,
- execution cannot be abused to swap collateral into unsupported or overly risky assets,
- slippage and price impact constraints are respected in fork-based simulations.

### 7.2 Strategy Updates

Stress tests SHOULD simulate:

- frequent StrategyConfig updates within allowed governance rules,
- improper or extreme parameter values (within technically valid ranges),
- delayed or failed updates during market stress.

Expected outcomes:

- system SHOULD reject obviously unsafe configurations if guards exist.
- if unsafe configurations are technically allowed, their impact MUST be well understood and documented.

## 8. Collateral Risk & Portfolio Stress

### 8.1 Single-Asset Depeg

Tests MUST cover scenarios where:

- USDT or USDC experiences a sustained discount to 1 USD,
- risk-on assets (WBTC, WETH / ETH) experience large drawdowns.

Outcomes to measure:

- resulting PoR ratios,
- PSM and BuybackVault behaviour under reduced valuations,
- effect on user-facing redemption paths.

### 8.2 Multi-Asset & Systemic Stress

Scenarios SHOULD include:

- simultaneous stress on multiple collaterals,
- oracle reliability issues combined with price shocks,
- liquidity drying up on key venues used for rebalancing.

The goal is to evaluate whether the protocol can avoid:

- forced selling at unfavourable prices,
- insolvency-like states,
- uncontrolled depeg dynamics.

## 9. Attack Vector Focus (Priority Set)

The following five attack vectors MUST receive special attention across tests:

1. **Oracle lag / stale prices**  
   - verifying that stale or delayed data cannot be exploited systematically.

2. **PSM limit bypass / flash-mint style attack**  
   - ensuring that configured limits are respected under adversarial input.

3. **Guardian abuse / pause edge cases**  
   - ensuring safety controls cannot be misused to steal funds or create hidden backdoors.

4. **Vault drain / approval surface**  
   - ensuring allowances, approvals and vault access patterns do not permit systematic draining.

5. **Buyback misrouting / wrong-asset execution**  
   - ensuring buyback logic cannot be coerced into routing funds incorrectly.

Each vector SHOULD be addressed with:

- unit-level tests,
- fuzz/property tests,
- fork-based scenarios where applicable.

## 10. Test Coverage & Reporting

### 10.1 Coverage Goals

The testing framework SHOULD aim for:

- high branch and path coverage for core components,
- explicit coverage of all key economic and safety invariants,
- scenario coverage for each of the stress themes listed above.

Coverage metrics SHOULD be tracked via Foundry tooling and reported as part of CI where feasible.

### 10.2 Reporting & Regression

- New test failures MUST be treated as regressions and investigated promptly.
- Critical and High severity findings from audits or bug bounty reports MUST result in:
  - new tests or strengthened properties,
  - explicit linkage between issue IDs and tests covering them.

## 11. Relationship to Other Documents

This stress test suite plan is linked to:

- **Audit Plan** – `docs/security/audit_plan.md`  
  - Audits SHOULD verify that the described stress tests exist and are maintained.

- **Bug Bounty Program** – `docs/security/bug_bounty.md`  
  - New classes of issues found by external researchers SHOULD lead to new tests.

- **Collateral Risk Profile** – `docs/risk/collateral_risk_profile.md`  
  - Stress scenarios MUST reflect the qualitative risks and scenarios described there.

- **Emergency Depeg Runbook** – `docs/risk/emergency_depeg_runbook.md`  
  - Operational depeg responses SHOULD be rehearsed and validated through stress tests.

- **PoR Spec** – `docs/risk/proof_of_reserves_spec.md`  
  - Tests SHOULD validate correct PoR behaviour under stressed collateral valuations.

## 12. Maintenance

The stress test suite MUST be updated when:

- new collateral assets are added or removed,
- significant protocol changes are introduced (e.g., new buyback strategies),
- incident reviews identify weaknesses in existing tests.

The Risk Council and core developers SHOULD periodically review:

- coverage levels,
- relevance of scenarios,
- alignment with real-world events and emerging threats.

