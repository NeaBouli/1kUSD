# Oracle Aggregator Integration Guide

> Status: DEV-10 – integration-focused documentation, no contract changes implied.  
> Audience: external builders (dApps, wallets, indexers, risk / monitoring systems).

The Oracle Aggregator is the **single on-chain entry point** for price
information used by the 1kUSD Economic Core.  
It combines data from one or more underlying oracles and applies safety
rules before exposing prices to downstream components (PSM, Guardian,
BuybackVault strategies, etc.).

This guide explains how to **consume oracle data safely** as an integrator:

- how to read prices and metadata,
- how to interpret health checks (staleness, diff checks),
- how to design off-chain monitoring around the aggregator.

For detailed architecture and specs, see:

- `docs/architecture/oracle_layer_overview.md`
- `docs/architecture/oracle_health_gates.md`
- `docs/reports/DEV4x_Oracle_Layer_*.md` (where applicable).

---

## 1. High-level responsibilities

From an integrator perspective, the Oracle Aggregator:

- exposes **normalized prices** for supported assets / pairs,
- enforces **minimum freshness** (stale checks),
- enforces **maximum deviation** between sources (diff checks),
- may provide **explicit health flags** or revert when conditions are not met.

The Economic Layer is designed such that:

- **price consumers** (PSM, Vaults, Guardian, etc.) should not directly
  query raw underlying oracles,
- instead, they rely on the **Aggregator as the canonical source**.

As an external integrator, you should mirror this behaviour:

- query prices through the same aggregator the protocol uses,
- adopt the same health criteria for your own risk assessment.

---

## 2. Integration modes

There are two main ways integrators interact with the Oracle Aggregator.

### 2.1 On-chain integration

A smart contract directly calls the Oracle Aggregator to obtain:

- the current price for an asset (or asset pair),
- possibly metadata such as:
  - last update timestamp,
  - a health flag,
  - number of sources.

This mode is typical for:

- dApps that want to align their own logic with the protocol’s price view,
- composed protocols that want to guard actions using the same oracle rules.

**Key considerations:**

- On-chain calls are subject to:
  - revert behaviour when health checks fail,
  - gas costs,
  - potential differences between “view-only” and “state-changing” paths.
- Your contract must:
  - handle reverts from the Aggregator,
  - treat any health failure as **“no price”** rather than “stale but usable”.

### 2.2 Off-chain integration

Backends, risk engines and indexers read from the Aggregator via RPC:

- call `eth_call`/equivalent against the Aggregator’s view functions,
- parse returned price/metadata,
- store data in their own databases.

This is useful for:

- dashboards,
- risk monitoring,
- backtesting and analytics.

**Best practice:**

- Use the **same encoding and scaling** conventions as on-chain consumers,
- do not “fix up” unhealthy data off-chain (e.g. by ignoring stale flags)
  unless you have a very deliberate, documented reason.

---

## 3. Core concepts and data model (integration view)

Exact function names and types are defined in the contracts/specs.  
This section describes the **conceptual model** integrators should expect.

### 3.1 Price representation

Typical elements you may encounter:

- **price**:  
  A scaled integer representing the asset price (e.g. asset per USD or USD
  per asset). You must know:
  - the **price decimals** (e.g. 8 or 18),
  - whether it is **asset/quote** or **quote/asset** (convention).

- **timestamp / updatedAt**:  
  When the price was last updated, as a unix timestamp.

- **round id / observation id** (optional):  
  ID of the observation, useful for correlation with underlying feeds.

From an integrator perspective:

- Always treat prices as **scaled integers** and apply proper division in your
  own code when converting to human-readable values.
- Never assume the same decimals as ERC-20 tokens; price scaling is separate.

### 3.2 Stale checks

The Aggregator is expected to enforce **freshness windows** such as:

- a maximum age for data (e.g. “price must be < X seconds old”),
- possibly asset-specific windows for different markets.

Integration implications:

- If data is **too old**, the Aggregator may:
  - revert,
  - return a zero/invalid price with a “not healthy” flag,
  - or encode staleness in an explicit field (depending on implementation).
- As integrator, treat stale data as **unusable for safety-sensitive
  decisions**.

### 3.3 Diff checks (source deviation)

When multiple oracle sources are combined, the Aggregator may enforce a
maximum allowed deviation between:

- the median and individual sources, or
- the min / max values in the set.

If the deviation exceeds a configured threshold, the Aggregator should:

- consider the aggregate **unhealthy**,
- revert or mark the price as invalid.

Integration implications:

- You must never “average out” obviously diverging sources on your own.
- Instead, rely on the Aggregator’s decision: if the aggregator refuses to
  provide a price under diff stress, external systems should also refrain
  from acting as if there is a valid price.

---

## 4. Reading prices: typical patterns

This section describes **usage patterns**, not exact signatures.

### 4.1 Single-asset price read

A common pattern is a view function:

- input: asset identifier (e.g. address or key),
- output: `(price, updatedAt, isHealthy)` or revert-on-unhealthy.

Integrator behaviour:

1. **Call the aggregator view** with the desired asset key.
2. If the call reverts:
   - treat this as “no usable price”,
   - propagate a safe error upstream.
3. If the call returns:
   - validate that `isHealthy == true` (if present),
   - validate that `updatedAt` is within your own acceptable range
     (you may apply stricter freshness than the aggregator’s internal one),
   - use `price` with the documented scaling.

### 4.2 Pair / cross-asset price read

If the aggregator natively supports cross-asset prices:

- e.g. price of asset A denominated in asset B or directly in 1kUSD,

then:

1. Pass the pair identifier(s) to the Aggregator.
2. Receive a price with the appropriate scaling.
3. Follow the same health checks as in single-asset reads.

If cross prices are **not** provided directly:

- some integrations derive them from common bases (e.g. both assets priced
  against USD). This should only be done if:
  - both base prices are healthy,
  - you are comfortable with the resulting rounding behaviour.

### 4.3 Sampling / history

The core Aggregator may or may not expose history directly.  
For risk/analytics use cases, integrators usually:

- record prices periodically off-chain (e.g. via cron or event triggers),
- store them in time-series databases,
- run their own analysis (volatility, trend detection, etc.).

When deriving your own metrics, remember:

- The on-chain Aggregator’s **instantaneous state** is the source of truth
  for protocol decisions.
- Off-chain derived metrics are advisory and should not contradict the
  Aggregator’s own health gates.

---

## 5. Handling failures and health signals

Even when calls are technically successful, the data may not be suitable
for critical decisions. Integrators should implement a clear handling model.

### 5.1 Types of failures

Conceptually expect:

- **Reverts**:
  - asset not supported,
  - internal oracle failure,
  - staleness or diff conditions triggered,
  - configuration issues.

- **Unhealthy but non-reverting responses** (if design allows):
  - explicit `isHealthy == false`,
  - sentinel values (e.g. price == 0) accompanied by a flag.

Integrator best practice:

- Treat both **reverts** and **explicitly unhealthy responses** as
  “no price”.
- Avoid using fallback heuristics (e.g. “just use last known price”) unless:
  - you have strict, well-documented rules,
  - the decision is not safety-critical.

### 5.2 Backoff and retry strategy

If the Aggregator indicates that price data is temporarily unavailable:

- Do **not** aggressively spam retries with the exact same parameters.
- Instead:
  - implement reasonable backoff (e.g. exponential or capped),
  - surface the situation to monitoring / operators.

For user-facing UIs:

- Explain that the protocol is temporarily rejecting price-dependent actions
  due to safety conditions, rather than “failing randomly”.

---

## 6. Monitoring the Oracle Layer

Because the Oracle Aggregator is a critical dependency, integrators are
encouraged to monitor it explicitly.

### 6.1 Useful signals to track

Depending on available events / view functions, look for:

- **Price update frequency per asset**
  - expected cadence vs actual cadence.
- **Rate of unhealthy states / reverts**
  - how often reads fail due to staleness / diff checks.
- **Configuration changes**
  - updates to thresholds, sources, or enabled feeds.

These can be ingested by:

- custom indexers,
- Prometheus exporters,
- log/metric pipelines of your choice.

### 6.2 Alerting examples

Practical alert rules might include:

- **Stale data persistence**:
  - price for a major asset is stale (unhealthy) for longer than N minutes.

- **Spike in failed reads**:
  - sudden increase in Aggregator read failures for specific assets.

- **Configuration drift**:
  - thresholds or source sets changed unexpectedly (from an integrator’s
    perspective) without corresponding governance signals.

Design your alerting so that:

- false positives are minimized,
- truly abnormal states or outages are caught quickly.

---

## 7. Integration checklist

Before relying on the Oracle Aggregator in a production integration:

1. **Understand the scaling and units**
   - confirm price decimals and direction (asset/quote vs quote/asset),
   - validate your conversion functions with known test cases.

2. **Validate health handling**
   - check how your integration behaves under:
     - staleness scenarios,
     - diff violations,
     - unsupported assets.
   - ensure your system does not silently proceed with bad data.

3. **Exercise failure paths**
   - simulate Aggregator reverts,
   - observe how your backend / contract reacts,
   - ensure the user / upstream system gets a clear, actionable error.

4. **Set up monitoring**
   - track read success rates, latency and failure reasons (where observable),
   - define thresholds and alert rules.

5. **Document assumptions**
   - internal docs should describe:
     - which Aggregator functions you rely on,
     - what health checks you honour,
     - which fallback behaviour (if any) is acceptable.

As the protocol evolves, this guide may be extended with:

- concrete function signatures,
- code snippets for common client libraries,
- recommended patterns for specific environments (e.g. EVM SDKs, indexer
  frameworks).
