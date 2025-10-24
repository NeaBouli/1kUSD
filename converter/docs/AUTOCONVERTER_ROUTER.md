
AutoConverter Router — Policy & Data (v1)

Language: EN. Status: Spec.

Purpose

Define allowed source→stable routes for AutoConverter with safety guards.

Prefer best-execution while enforcing min liquidity, slippage caps, and adapter allowlist.

Route Selection (high level)

Enumerate candidate adapters per pair (from oracles/catalog + internal adapters).

Filter by policy:

adapter whitelisted == true

minLiquidityUSD >= threshold

maxSlippageBps <= policy cap

Rank by expected netOut (after fees) and pick highest.

Execute with CEI and Safety guards; revert if no route passes policy.

Data Files

Schema: converter/schemas/router.schema.json

Sample routes: tests/vectors/routes.sample.json

Policy Fields

maxSlippageBps: global and per-asset cap

minLiquidityUSD: per-route threshold

adapter: string id (must match deployed adapter registry)
