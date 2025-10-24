
Indexing & Telemetry — Spec (v1)

Language: EN. Status: Normative.

Goals

Deterministic event→DTO mapping

Reorg-safe (finality watermark, idempotent upserts)

Transparent Proof-of-Reserves (PoR) rollup

Machine-checkable health endpoints

Finality & Reorgs

Track confirmations per chain; only mark rows finalized=true after threshold.

Store blockNumber, txHash, logIndex, chainId, ingestedAt.

On reorg: delete/replay rows with blockNumber >= reorgFrom.

Event → DTO Map (normative)

PSM.SwapTo1kUSD: { type:"psm.swap_to", user, tokenIn, amountIn, fee, netOut, ts, txHash }

PSM.SwapFrom1kUSD: { type:"psm.swap_from", user, tokenOut, amountIn, fee, netOut, ts, txHash }

Vault.Deposit: { type:"vault.deposit", asset, from, amount, blockNumber, txHash }

Vault.Withdraw: { type:"vault.withdraw", asset, to, amount, reason, blockNumber, txHash }

Vault.FeeSwept: { type:"vault.fee_swept", asset, amount, treasury }

Token.Transfer: { type:"token.transfer", from, to, value }

Safety.ModulePaused/Unpaused: { type:"safety.pause|resume", moduleId, actor, ts }

DTO Schema

JSON schema in indexer/schemas/event_dto.schema.json

All numeric amounts as strings (decimal-less integers)

PoR Rollup

Rollup spec in indexer/schemas/por_rollup.schema.json

Fields:

assets[]: { asset, symbol, decimals, balanceRaw, pendingFeesRaw, usdPriceE8, usdValueE8 }

totals: { balanceUSD_E8, liabilities1kUSD_E8, coverageRatioBps }

updatedAt, finalityMark ∈ {"unsafe","safe","final"}

Indexer MUST reconcile: Σ(balanceRaw) - Σ(pendingFeesRaw) ≥ liabilities (unit-consistent)

Health Endpoints

Schema: indexer/schemas/health.schema.json

Fields:

status ∈ {"ok","degraded","down"}

components[]: { name, status, details? }

finality: { confirmations, lastIndexed, lastFinalized }

versions: { indexer, api }

Checker: scripts/check-health.mjs

Idempotency

Upsert keyed by (chainId, txHash, logIndex); replays must not duplicate.

Outputs

reports/por_rollup_report.json (validated PoR sample)

reports/health_check.txt (human-readable)
