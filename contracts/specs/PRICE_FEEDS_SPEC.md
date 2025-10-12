# Price Feed Adapters — Specification

**Scope:** Defines the adapter contract/API requirements for integrating different price sources into the OracleAggregator.  
**Status:** Spec (no code). **Language:** EN.

---

## 1. Common Interface (Concept)
Each adapter must expose a **uniform** read API:

- `get() -> { answer:int256, decimals:uint8, timestamp:uint256, sourceId:bytes32, finalityTag:string }`
- `description() -> string`
- `version() -> uint256`

**Constraints**
- `answer` scaled by `decimals`.
- `timestamp` = last update in seconds.
- `finalityTag ∈ {"safe","recent","pending"}`.

## 2. Chainlink Adapter
- Reads `latestRoundData()`; maps to common fields.
- Valid if `answeredInRound >= roundId`, `price > 0`, and `timestamp` > 0.
- Decimal passthrough from feed config.

## 3. Pyth Adapter
- Reads current price (and confidence if available).
- Convert confidence to a soft check (advisory) or widen `maxDeviationBps` if confidence low (policy option).
- Finality derived from update mechanism; tag at least `"recent"`.

## 4. DEX-TWAP Adapter
- Uses sliding window (e.g., 10–30 min) over an AMM pair (stablecoin vs 1kUSD or vs USD reference).
- Guards: min liquidity thresholds, reserve sanity checks, manipulation-resistant window.
- Decimals come from token pair; normalize accordingly.

## 5. Manual Sentinel (Optional)
- DAO-set fallback for emergencies.
- Only used when `allowSingleSource(asset)=true` and other feeds unhealthy.
- Strict rate limits, explicit activation event.

## 6. Health & Self-Checks
Adapters should surface **adapter-level** health flags (optional) and throw if upstream is clearly stale or broken.

## 7. Security
- No external state mutation; pure/view where possible.
- Protect against reentrancy (generally read-only).
- Validate token addresses for DEX adapters; ensure non-zero reserves.

## 8. Events (Optional/Local)
- `AdapterFault(sourceId, reason, ts)` for monitoring (adapter-local, not required by aggregator).

## 9. Testing Guidance
- Simulate outliers; verify aggregator median trimming.
- Vary decimals and timestamps; ensure proper normalization.
- Ensure finality tags propagate to aggregator snapshots.
