# Parameter Registry — Specification

**Scope:** Canonical catalog of runtime parameters and their application points. Provides a single source of truth for Safety/DAO changes and indexer visibility.
**Status:** Spec (no code). **Language:** EN.

---

## 1. Purpose
- Map **well-known parameter names** to setter calls routed through Safety or modules.
- Aid indexers and UIs by publishing a typed config state with versioning.
- Enforce **write policy**: only Timelock/Executor can mutate.

## 2. Data Model (Concept)
- `Param{ name:string, type:enum, value:bytes, updatedAt:uint256, appliedBy:address }`
- Namespaced keys (examples):
  - `psm.feeBps` → uint256
  - `psm.cap.USDC` → uint256
  - `psm.rate.windowSec` / `psm.rate.maxAmount`
  - `oracle.guard.USDC.maxAgeSec` / `.maxDeviationBps`
  - `safety.guardian.sunsetTs`
  - `vault.buffer.USDC`

## 3. Interfaces
- `get(name) -> Param`
- `list(prefix?) -> Param[]`
- `set(name, valueBytes)` — **Timelock-only**, internally dispatches to Safety/Module setter (or emits instruction event).
- `version() -> uint256` — increments on any `set`.

## 4. Events
- `ParameterChanged(name (indexed) string, value bytes, ts uint256)`
- Optional: `ParameterApplyFailed(name, reason)` if downstream revert; requires retry path.

## 5. Policy
- All risk-affecting parameters must be present here; no undocumented side channels.
- Increases that **loosen** risk (caps↑, rate limits↑) may require **longer** delay than decreases (policy option via Timelock).

## 6. Testing
- Differential tests: registry `set()` vs direct Safety setters → same observable runtime.
- Race conditions: ensure reads during transition are coherent (apply or revert as a whole).
