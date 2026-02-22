
Collateral Vault — Accounting Edge Cases (v1)

Status: Docs (normative). Language: EN. Audience: Core devs, auditors, SDK.

0) Scope

Covers: fee-on-transfer (FoT) tokens, decimal mismatches (6 vs 18), caps & headroom checks, and ingress/egress invariants.

1) Ingress (deposit)

Call: Vault.deposit(asset, from, amountIn)

MUST pull amountIn via safeTransferFrom(from -> vault).

MUST read actual balance delta:
pre = bal(asset, vault); transfer; post = bal(asset, vault); received = post - pre;

If received < amountIn (FoT), then:

received is the authoritative deposit amount.

PSM quotes MUST NOT rely on exact amountIn arriving; only To1k path uses deposit-before-mint CEI ensuring minted amount matches oracle USD of (received - feeAsset).

MUST enforce cap after applying received:

if (balance(asset) + received > cap(asset)) revert CAP_EXCEEDED;

MUST emit Deposit(asset, from, received) (not amountIn).

2) Egress (withdraw)

Call: Vault.withdraw(asset, to, amount, reason)

MUST check liquidity: balance(asset) >= amount.

MUST emit Withdraw(asset, to, amount, reason) after state updates.

MUST NOT apply FoT logic on egress (receiver-side FoT is external and out-of-scope).

3) Fee accrual and sweep

Accrue fees per-asset in vault storage: pendingFees[asset].

FeeSwept(asset, to, amount) emitted for sweeps to treasury.

Invariant: Σ pendingFees + Σ swept == Σ accrued.

4) Decimals and normalization

Vault stores raw token units.

All USD math is performed in PSM using oracle snapshot; vault never converts units.

Indexers should apply decimals metadata for reporting only.

5) Unsupported/changed tokens

On isAssetSupported(asset) == false → deposits revert.

If a token changes decimals or behavior (rare), governance MUST disable the asset, sweep balances, and rotate to a compliant wrapper.

6) Invariants

I1 Supply Bound: ΣUSD(vault balances minus fees) ≥ 1kUSD total supply (snapshot-based, advisory).

I5 Caps enforced on all ingress paths.

Event parity: Deposit.received equals on-chain balance delta.

7) Tests

See tests/vectors/vault_edge_vectors.json for FoT and decimals cases.
