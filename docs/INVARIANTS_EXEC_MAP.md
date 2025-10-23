
Invariants — Executable Mapping (v1)

Status: Normative. Language: EN.

Scope

Bridges formal invariants (docs/INVARIANTS.md) to concrete executable checks (unit/integration/fuzz). Each invariant has:

ID, Description

Scope (module/contracts)

Checkpoint (when to assert)

Metric(s) to measure

Test Harness Notes

I1 — Supply Bound

Desc: Σ USD(vault balances minus fees) ≥ total 1kUSD supply

Scope: PSM, Vault, Token, Oracle (advisory)

Checkpoint: after each swap/deposit/withdraw

Metrics: supply1k, balances[asset], pendingFees[asset], price[asset]

Harness: mock oracle snapshot; compute advisory sumUSD and compare with supply1k

I2 — PSM Conservation

Desc: Accounting (in/out) and fee accrual consistent for both directions

Checkpoint: after swapTo / swapFrom

Metrics: gross, fee, net; events emitted; vault deltas

Harness: compare vectors (docs/PSM_QUOTE_MATH.md, tests/vectors/psm_quote_vectors.json)

I3 — No Free Mint

Desc: Mint only after Vault deposit success

Checkpoint: swapTo path

Harness: force deposit revert or zero-received (FoT extreme) → ensure no mint

I4 — No Unauthorized Burn

Desc: Burn only callable by authorized modules

Harness: attempt burn from EOA or foreign contract → revert

I5 — Caps Enforced

Desc: Ingress reverts if cap exceeded

Harness: use vault_edge_vectors.json (cap exceed)

I6 — Rate Limits

Desc: Sliding window gross flow ≤ maxAmount

Harness: rate_limiter_vectors.json

I7 — Pause Safety

Desc: When paused, state-changing ops revert

Harness: pause via Safety → swaps revert

I8 — Oracle Liveness

Desc: stale prices block quotes/exec

Harness: oracle_guard_vectors.json (stale)

I9 — Deviation Guard

Desc: dispersion beyond maxDeviationBps marks unhealthy

Harness: oracle_guard_vectors.json (outlier)

I10 — Atomic Snapshot

Desc: quote snapshot == exec snapshot (or strict re-read rule)

Harness: compare IDs or values within tx; mismatch → revert

I11–I13 — Events Consistency

Desc: emitted events reflect state deltas and accounting

Harness: decode events and cross-check with vault/token balances

I14–I15 — Reentrancy/Order

Desc: CEI, nonReentrant; no external callbacks

Harness: reentrancy harness; attempt callback on token hooks (mock ERC-777-like)

I16 — Treasury Path Only

Desc: Vault GOV_SPEND only via Timelock

Harness: spend from non-timelock → revert

I17 — Governance-Only Params

Desc: Parameter changes only via Timelock

Harness: setUint/setAddress from EOA → revert; timelock path → ok
