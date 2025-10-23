# Routes Plan (Phase 0 — Docs)

> No implementation yet. The list informs component contracts & SDK needs.

## Routes
- `/` — **Home**
  - Cards: Supply (1kUSD), PoR (USD total), Latest Events.
  - Calls: `GET /v1/reserves` (indexer), `token.totalSupply()` (RPC).

- `/swap` — **PSM Swap**
  - Panels: To 1kUSD / From 1kUSD; quotes; fee hint.
  - Calls: `PSM.quoteTo1kUSD/quoteFrom1kUSD` (RPC); supported tokens from Vault/PSM.
  - Guard states: paused (Safety), oracle healthy/deviation.

- `/vault` — **Collateral Vault**
  - Tables: Supported assets, (future) balances, caps (params).
  - Calls: `Vault.isAssetSupported/batch`, params per-asset from registry.

- `/oracle` — **Oracles**
  - Table: Assets, price, decimals, healthy, updatedAt.
  - Calls: `Oracle.getPrice(asset)`.

- `/governance` — **DAO/Timelock**
  - Timeline: queued/executed ops (read-only).
  - Calls: indexer governance feed (future spec).

- `/status` — **System Status**
  - Widgets: Pause states (per module), versions, addresses.
  - Calls: Safety `moduleEnabled/isPaused`, addresses/params JSON.

## Components (atoms/molecules)
- TokenSelector, AmountInput, QuotePanel, HealthBadge, PauseBadge, AddressBadge.

## Empty States & Errors
- No supported tokens → show docs link.
- Oracle unhealthy → disable action & show help.
- Paused → CTA disabled, pause reason hint (from Safety docs).

