#!/bin/bash
set -e

echo "== DEV-10 02: enrich PSM Integration Guide content =="

PSM_GUIDE="docs/integrations/psm_integration_guide.md"

if [ ! -f "$PSM_GUIDE" ]; then
  echo "File $PSM_GUIDE not found, aborting."
  exit 1
fi

cat <<'EOD' > "$PSM_GUIDE"
# PSM Integration Guide

> Status: DEV-10 – integration-focused documentation, no contract changes implied.  
> This guide is written for external builders (dApps, wallets, backends, indexers).

The Peg Stability Module (PSM) is the primary on-chain entry point for
swapping between **collateral assets** and **1kUSD** under well-defined
fees, limits and safety rules.

This guide explains how to integrate with the PSM from an *external
integrator* perspective:

- what to know before calling it,
- how typical flows look like,
- which failure modes to expect,
- and what to monitor off-chain.

For deep architectural details, see:

- `docs/architecture/psm_flows_invariants.md`
- `docs/architecture/psm_parameters.md`
- `docs/specs/PSM_SPEC.md` (if present)
- relevant economic / governance reports under `docs/reports/`.

---

## 1. High-level model

At a high level, the PSM:

- holds one or more **collateral tokens** (e.g. stable-ish assets),
- mints / burns **1kUSD** against that collateral within configured limits,
- enforces **fees, spreads, and risk limits**,
- relies on oracle prices and safety guards to avoid pathological states.

From an integrator view:

- You pass in:
  - which asset you want to swap,
  - how much you want to swap,
  - an optional minimum/maximum constraint (slippage protection),
  - a recipient.
- The PSM:
  - checks parameters, limits and oracle health,
  - may charge a fee / spread,
  - performs the swap or reverts.

---

## 2. Integration modes

There are two typical integration modes:

### 2.1 Direct smart contract integration

A smart contract (e.g. a dApp / vault / routing contract) calls the PSM
directly:

- The calling contract:
  - holds collateral or 1kUSD on behalf of users,
  - approves / transfers tokens to the PSM if needed,
  - calls the relevant swap function,
  - distributes the resulting tokens.

This mode is suitable for:

- routers / aggregators,
- vaults,
- protocol-level integrations.

**Key considerations:**

- The integrating contract must:
  - handle reverts gracefully,
  - validate returned amounts against expectations,
  - enforce its own additional risk checks where appropriate
    (e.g. user-specific limits).

### 2.2 Backend / off-chain integration

A backend service (exchange, wallet, bridging service) sends transactions
on behalf of users:

- The backend:
  - constructs and signs PSM swap transactions,
  - tracks user balances off-chain,
  - sends transactions to a node or RPC.
- The on-chain PSM interaction is still the same, but the user experience
  is frontend/backend driven.

**Key considerations:**

- You still must:
  - anticipate reverts and error codes,
  - surface failures clearly to the user,
  - keep off-chain accounting consistent with on-chain results.

---

## 3. Core concepts for integrators

Before integrating, it is important to understand the main concepts the PSM
operates with.

### 3.1 Collateral tokens vs 1kUSD

- **Collateral tokens:**
  - Supported ERC-20-like assets configured in the system.
  - Each collateral asset has:
    - decimals,
    - a price feed,
    - specific limits and parameters (caps, fees, spreads, etc.).

- **1kUSD:**
  - The protocol-stable asset targeted at 1.00 USD.
  - Minted / burned by the PSM, subject to constraints and safety rules.

### 3.2 Fees & spreads (conceptual)

The PSM may apply:

- **Mint fee**: charged when swapping collateral → 1kUSD.
- **Redeem fee**: charged when swapping 1kUSD → collateral.
- **Spread**: effectively a difference between buy and sell prices or
  a margin against the oracle price.

From an integrator perspective:

- You must **never assume 1:1** conversion.
- Always compute and/or verify the **expected output amount** based on:
  - input amount,
  - oracle price(s),
  - configured fees / spreads (retrieved from the parameter registry or
    dedicated getter functions),
  - any protocol-level roundings.

When PSM helper libraries or SDKs become available, integrators should
prefer them for computing expected amounts.

### 3.3 Limits & safety constraints (conceptual)

The PSM enforces various limits, including (conceptually):

- **Per-transaction limits** (e.g. max swap size),
- **Per-day / rolling limits** (e.g. total volume per asset per time window),
- **Global caps** (e.g. max 1kUSD minted for a given collateral),
- **Pause / circuit-breaker states** via Guardian / Safety Automata.

If a limit would be violated, the call is expected to **revert**, and the
integrator must handle that.

---

## 4. Typical flows (collateral ↔ 1kUSD)

The exact function names and signatures are defined in the contracts and
specs. This section focuses on the **logical flow** and what an integrator
needs to consider.

### 4.1 Collateral → 1kUSD (mint-like swap)

1. **Setup**
   - User or integrating contract holds an approved collateral token.
   - PSM is configured to accept this collateral asset.

2. **Determine parameters**
   - Retrieve:
     - oracle price(s) for the collateral,
     - fee and spread settings,
     - per-asset limits (if exposed via view functions/registry).
   - Compute a **conservative expectation** of how much 1kUSD should be
     received, after fees and spreads.

3. **Prepare transaction**
   - Ensure the PSM has token allowance (for direct ERC-20 based transfers)
     or that your contract transferred collateral to the PSM.
   - Construct the PSM swap call with:
     - input asset identifier (collateral),
     - input amount,
     - **minimum acceptable output** amount of 1kUSD (slippage/fee protection),
     - recipient address.

4. **Call PSM**
   - Send the transaction.
   - Expect revert if:
     - oracle price is unavailable or unhealthy (stale/diff),
     - limits would be violated (per-tx, per-day, global),
     - PSM is paused or restricted,
     - min-out is not satisfied after fees / spreads.

5. **Post-processing**
   - On success:
     - parse events to confirm the actual 1kUSD amount delivered,
     - update off-chain accounting / UI.
   - On failure:
     - interpret the revert reason if possible,
     - translate into user-friendly error codes/messages.

### 4.2 1kUSD → collateral (redeem-like swap)

1. **Setup**
   - User or integrating contract holds 1kUSD.
   - The target collateral asset is supported and has available capacity.

2. **Determine parameters**
   - Retrieve:
     - oracle price(s),
     - redeem fee / spread settings,
     - available capacity / limits for that collateral (if exposed).

3. **Prepare transaction**
   - Ensure PSM/contract can access the user’s 1kUSD:
     - either by allowance,
     - or by holding the 1kUSD in the integrating contract.
   - Construct the call with:
     - input: 1kUSD amount,
     - desired collateral asset identifier,
     - **minimum acceptable collateral out**.

4. **Call PSM**
   - Expect revert if:
     - redeem would breach limits or capacity,
     - the system is paused / restricted,
     - the oracle is unhealthy,
     - min-out is too aggressive.

5. **Post-processing**
   - On success:
     - confirm collateral amount via events and return values,
     - update off-chain accounting.
   - On failure:
     - surface revert to user / upstream system.

---

## 5. Failure modes & how to handle them

While exact revert strings / error types are defined in the contracts,
integrators should conceptually be prepared for:

- **Parameter validation failures**
  - unsupported asset,
  - zero amount,
  - invalid recipient.

- **Limit violations**
  - per-tx size too large,
  - daily / rolling cap exceeded,
  - global mint/burn caps exceeded.

- **Oracle-related failures**
  - oracle data unavailable,
  - oracle marked as stale,
  - oracle diff between sources above thresholds.

- **Safety / Guardian actions**
  - PSM globally paused,
  - certain actions temporarily disabled,
  - rate limits / throttling.

- **Slippage / min-out failures**
  - actual amount after fees/spreads less than your min-out.

**Recommended handling pattern:**

- Treat each failed transaction as a signal:
  - log detailed context (amounts, asset, on-chain state where possible),
  - classify errors if revert reasons are structured,
  - avoid blind retries with identical parameters,
  - expose actionable messages to frontend / operators.

---

## 6. Indexing & monitoring (observer view)

Even if you only call the PSM occasionally, it is highly recommended to
monitor its activity.

### 6.1 Events to watch (conceptual)

The concrete event names are specified in the contracts and specs, but you
can expect categories such as:

- swap-executed events (collateral ↔ 1kUSD),
- parameter / limit updates (fees, caps, spreads),
- pause / unpause / emergency actions.

Integrators running an indexer should:

- consume the PSM’s events,
- maintain a structured history of:
  - swap volumes per asset,
  - fee revenues,
  - capacity usage.

### 6.2 Alerting examples

Examples of useful alerts for integrators:

- **High failure rate**:
  - many failed swaps in a short window → possible misconfiguration or
    market stress.

- **Capacity near limit**:
  - collateral capacity approaching configured caps → risk that redemptions
    will soon fail.

- **Guardian / pause actions**:
  - immediate notification when PSM is paused or unpaused.

---

## 7. Integration checklist

Before going live with a PSM integration, ensure you have:

1. **Understood the economic parameters**
   - fees, spreads, limits,
   - how they are configured and updated (governance process).

2. **Validated basic flows on a test environment**
   - collateral → 1kUSD swaps,
   - 1kUSD → collateral swaps,
   - behaviour at small and large sizes.

3. **Implemented robust error handling**
   - interpret common reverts,
   - surface clear messages to users,
   - implement safe retry / fallback logic where appropriate.

4. **Set up monitoring / alerting**
   - watch PSM-related events,
   - track your own swap success/failure ratios,
   - alert on unexpected behaviour or state changes.

5. **Documented your integration**
   - internal runbooks for operators,
   - front-end UX flows aligned with PSM behaviour.

As the protocol evolves, this guide may be extended with concrete function
signatures, example transactions and SDK snippets. Integrators should always
refer to the latest version of this document and the underlying specs.
EOD

# 2) Log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 02] ${timestamp} Enriched PSM integration guide content for external integrators" >> "$LOG_FILE"

echo "== DEV-10 02 done =="
