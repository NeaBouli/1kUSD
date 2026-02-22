# Oracle Aggregation Guards (Spec v0.1)

**Goal:** Aggregate multiple oracle feeds and filter outliers.

## Features
- DAO registers multiple `OracleAdapter` sources
- Median of all valid prices is returned
- Guards reject feeds older than 24h
- Emits `Aggregated(price, validSources)`

## Security
- DAO-only for feed management
- Reverts if no valid feed available
- Uses try/catch for source safety
