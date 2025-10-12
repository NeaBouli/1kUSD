# 1kUSD Reference dApp / Explorer — Specification

**Scope:** Non-custodial web reference app for observing protocol state (PoR, peg, safety), performing PSM swaps, and browsing governance.  
**Status:** Spec (no code). **Language:** EN.

## 1. Goals
- Transparent **explorer** (peg, reserves, caps/limits, safety state).
- Simple **PSM swap UI** (to/from 1kUSD) with fees, limits, health checks.
- **Governance view** (proposals, timelock ETA, execution status).
- **No private keys handled** beyond standard wallet connectors (EIP-1193).

## 2. Architecture (concept)
- **UI**: React (app-agnostic spec), routing-based SPA.
- **State**: Query cache for on-chain & indexer data; local ephemeral tx state.
- **Data Sources**:
  - SDK (xref: clients/specs/SDK_TS_SPEC.md)
  - Indexer REST/GQL (xref: interfaces/INDEXER_API.md)
  - RPC for tx submission/simulation
- **Telemetry**: anonymized UX metrics; no PII.

## 3. Routes (high-level)
- `/` — Dashboard: Peg card, Reserves, Safety status
- `/swap` — PSM swap (1kUSD <-> USDC/USDT/DAI)
- `/reserves` — Proof of Reserves details + exposure by asset
- `/governance` — Proposals list & detail (queue/ETA/executed)
- `/safety` — Paused modules, caps/limits, oracle health
- `/tx/:hash` — Tx detail with status & decoded event(s)
- `/docs` — Links to specs & whitepaper

## 4. Component Sketch (selected)
- `PegCard` (priceUSD, deviationBps, healthy)
- `ReserveTable` (asset, amount, USD, cap, breached)
- `SwapForm` (tokenIn/out, amount, feeBps, minOut, rate limit/cap warnings)
- `SafetyPanel` (pausedModules[], rateLimits, caps)
- `GovList`/`GovDetail` (proposal lifecycle)
- `TxToast` (pending/success/fail with error mapping)

## 5. Data Contracts (reads)
- SDK: `psm.getParams`, `vault.getBalances`, `oracle.getPrice`, `safety.getState`, `gov.listProposals`
- Indexer: `/v1/reserves`, `/v1/peg`, `/v1/psm/summary`, `/v1/safety/state`, `/v1/gov/proposals`

## 6. Transactions (writes)
- PSM: `swapTo1kUSD` / `swapFrom1kUSD` via SDK (simulate → build → sign → broadcast).
- Wallet: EIP-1193 provider; chain switch if needed.

## 7. Security & Safety
- Preflight checks: paused module, oracle health, rate limit headroom, caps.
- Show **finality** (e.g., “safe”/confirmations) on balances & peg.
- Never store secrets; no custom signing beyond wallet provider.

## 8. Performance
- Stale-while-revalidate cache; exponential backoff for RPC/indexer.
- Batch RPC where available; websocket subscriptions for peg/reserves deltas.

## 9. Telemetry (optional)
- Page views & swap funnel (anonymized), error taxonomy (xref: COMMON_ERRORS.md). Opt-out toggle.

## 10. Testing
- Mock SDK/indexer; snapshot UI states for healthy/paused/stale scenarios.
