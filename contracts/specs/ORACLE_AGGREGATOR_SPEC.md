# OracleAggregator — Functional Specification

**Scope:** Price aggregation for USD-pegged stablecoins and reference USD feeds; health & deviation guards for dependent modules (PSM/Converter).  
**Status:** Spec (no code). **Language:** EN.

---

## 1. Goals
- Aggregate multiple **independent** price feeds per asset into a robust **median** (or trimmed-mean) price.
- Expose **health**, **staleness**, and **deviation** status per asset.
- Provide **finality-aware** snapshots to avoid reorg-induced inconsistencies.
- Be **read-only** for dependent modules; no asset custody.

## 2. Inputs & Adapters
- Accepts adapters implementing a common interface (see `PRICE_FEEDS_SPEC.md`):
  - **Chainlink** aggregators
  - **Pyth** price feeds
  - **DEX-TWAP** (on-chain AMM windowed price)
  - **Manual Sentinel** (DAO-set fallback, heavily restricted; optional)

Adapters report:
- `answer` (int256), `decimals` (uint8), `timestamp` (uint256), `sourceId` (bytes32), `finalityTag` (`"safe" | "recent" | "pending"`).

## 3. Normalization & Snapshot
- Convert all answers to a unified fixed-point with 18 decimals:  
  `norm = answer * 10^(18 - decimals)`.
- Build a **snapshot** per asset containing `{values[], timestamps[], sources[], finalityTags[]}` at call time.
- Reject sources where `now - timestamp > maxAgeSec(asset)` or where `finalityTag` worse than configured minimum (e.g., require `"safe"` for mint paths).

## 4. Aggregation
- Default **median** of valid `values[]`.
- If ≥ 5 sources: **trimmed-mean** (drop highest & lowest 20%, average remainder).
- If only 1 valid source: use it **only** when `allowSingleSource(asset)=true` (governance-controlled) else mark **unhealthy**.

Output tuple:
- `(price:int256, decimals:uint8=18, healthy:bool, deviationBps:uint256, lastUpdate:uint256)`

`deviationBps` measures distance to $1 for USD-pegged assets or to a governance baseline.

## 5. Guards & Health
- **Staleness:** `now - lastUpdate ≤ maxAgeSec(asset)`.
- **Deviation:** `abs(price - $1) / $1 * 10000 ≤ maxDeviationBps(asset)` for USD-pegs.
- **Source quorum:** `count(validSources) ≥ minQuorum(asset)` unless `allowSingleSource`.
- **Health = true** iff all applicable guards pass.

## 6. Finality Awareness
- Consider chain-specific finality (e.g., `safe` head).  
- Aggregator must be able to restrict reads to finalized blocks (implementation detail via `blockTag` param or using node defaults).
- Expose `finalityTag` with each snapshot for consumers.

## 7. Views (Read-Only)
- `getPrice(asset) -> (price, decimals, healthy, lastUpdate)`
- `getDetailed(asset) -> { price, decimals, healthy, deviationBps, sources:[{id,answer,decimals,timestamp,finalityTag}] }`
- `getGuards(asset) -> { maxDeviationBps, maxAgeSec, minQuorum, allowSingleSource }`
- `isHealthy(asset) -> bool`

## 8. Admin (DAO/Timelock)
- `setGuards(asset, {maxDeviationBps, maxAgeSec, minQuorum, allowSingleSource})`
- `addFeed(asset, adapterAddr, weight?)`
- `removeFeed(asset, adapterAddr)`
- **Note:** parameter changes ideally routed through Safety-Automata to ensure consistent audit trail.

## 9. Events (must match ONCHAIN_EVENTS.md)
- `FeedUpdated(asset (indexed) address, price int256, decimals uint8, ts uint256)`
- `OracleHealthChanged(asset (indexed) address, healthy bool, reason string, ts uint256)`
- `DeviationGuardSet(asset (indexed) address, maxBps uint256, ts uint256)`
- `StalenessGuardSet(asset (indexed) address, maxAgeSec uint256, ts uint256)`

## 10. Errors
- `NO_VALID_SOURCES`
- `STALE_SNAPSHOT`
- `DEVIATION_EXCEEDED`
- `QUORUM_NOT_MET`
- `ASSET_UNKNOWN`

## 11. Testing Guidance
- Mixed-source snapshots with different timestamps/finality; check guard behavior.
- Median vs trimmed-mean under outliers.
- Single source toggle behavior.
- Edge rounding for 6/8/18 decimals.
