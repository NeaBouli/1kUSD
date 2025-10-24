
PSM Revert Reasons — Normative Catalog (v1)

All errors are custom errors (Solidity) and ABI-stable.

UNSUPPORTED_ASSET — Asset not whitelisted by PSM and/or Vault.

PAUSED — Module paused by SafetyAutomata/DAO.

ORACLE_STALE — Oracle snapshot older than allowed maxAgeSec.

ORACLE_UNHEALTHY — Aggregation failed (no healthy sources).

DEVIATION_EXCEEDED — Source deviation beyond maxDeviationBps.

CAP_EXCEEDED — Safety cap headroom exceeded for asset/system.

INSUFFICIENT_LIQUIDITY — Vault cannot satisfy netOut + fee.

SLIPPAGE — netOut < minOut at execution time.

ACCESS_DENIED — Caller lacks required role.

ZERO_AMOUNT — amountIn or amountIn1k equals zero.

Mapping to flows:

Quotes never revert for oracle reasons (advisory); swaps do.

CEI order must ensure deposit-before-mint and burn-before-withdraw.
