# Rate Limits — Specification (Shared by PSM & Modules)
**Scope:** Sliding-window gross-flow limiter to bound systemic risk.  
**Status:** Spec (no code). **Language:** EN.

## 1. Model
- Windowed limiter with parameters `{ windowSec, maxAmount }` in **normalized 18-decimals 1kUSD units**.
- Tracks **gross flow** per window **per module** (e.g., PSM id `"PSM"`); direction-agnostic by default.

## 2. API (concept)
- `consume(moduleId, amountNorm) -> bool` (revert on exceed)
- `getUsage(moduleId) -> { used, windowStart, windowEnd }`
- `setParams(moduleId, windowSec, maxAmount)` (DAO via Safety)
- Emits `RateLimitUpdated(moduleId, windowSec, maxAmount)`

## 3. Semantics
- Reset when `now ≥ windowStart + windowSec`.
- Partial-window accounting on boundary; ensure monotonicity.
- Integrate with **PSM preflight**; mint/redeem must both call `consume()`.

## 4. Testing
- Window rollover; exact-boundary acceptance; adversarial bursts; multi-module isolation.
