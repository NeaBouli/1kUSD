
Indexer Event Notes (PSM/Vault/Token)

Status: Docs. Audience: Indexer devs, analytics.

Topics strategy

Always index events with (user, asset) as topics where applicable.

PSM:

SwapTo1kUSD: topics[0]=sig, topics[1]=user, topics[2]=tokenIn.

SwapFrom1kUSD: topics[0]=sig, topics[1]=user, topics[2]=tokenOut.

Vault:

Deposit/Withdraw: topics[1]=asset, topics[2]=from|to.

Reconciliation

1kUSD supply delta equals:

+minted on SwapTo1kUSD

-amountIn (burn) implied by SwapFrom1kUSD (from token Transfer if emitted).

Vault balances should reconcile as:

asset += amountIn on Deposit

asset -= amount on Withdraw

Fee flow:

PSM FeeAccrued(asset, amount) must eventually match Vault FeeSwept(asset, to, amount).

Finality & reorgs

Consumers must wait N confirmations (chain-dependent) before labeling events as final.

Reconcile by block number + tx hash; rebuild on reorg.

ABI & schema

Canonical ABI files:

abi/psm.events.json

abi/vault.events.json

abi/token.events.json

Include these ABIs verbatim in indexer deployments for consistent decoding.

Edge cases

Fee-on-transfer tokens must be rejected at ingress; indexers may still see Transfer deltas.

Zero-amount events should not be emitted; treat as anomaly if observed.

Performance notes

Prefer Bloom filter pre-checks on topics for large datasets.

Batch process blocks; commit checkpoints (block number, last tx processed).
