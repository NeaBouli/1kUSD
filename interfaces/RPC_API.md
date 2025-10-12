# Public Node / RPC API (Spec Only)

JSON-RPC/WebSocket read-only & submission endpoints. No secrets. Shapes only.

## Tx / Simulation
- chain_sendRawTransaction(rawTx: hex) -> txHash: hex
- chain_estimateGas(tx: object) -> gas: uint256
- chain_call(tx: object, blockTag: "latest" | "pending" | hexHeight) -> result: hex

## State & Balance
- chain_getBalance(address: hex, blockTag: string) -> uint256
- chain_getTokenBalance(token: hex, holder: hex, blockTag: string) -> uint256
- chain_getSupply(token: hex, blockTag: string) -> uint256

## Blocks & Logs
- chain_getBlockByNumber(numberOrTag: string|hex, includeTxs: bool) -> Block
- chain_getBlockByHash(hash: hex, includeTxs: bool) -> Block
- chain_getTransactionReceipt(txHash: hex) -> Receipt
- chain_getLogs(filter: {fromBlock,toBlock,address?,topics?[]}) -> Log[]
- subscribe:newHeads (WS)
- subscribe:logs (WS, with filter)

## Protocol Introspection (1kUSD)
- 1kusd_getPeg() -> { priceUSD, deviationBps, healthy }
- 1kusd_getReserves() -> { assets: [{asset,address,amount,decimals}], totalUSD, lastUpdate }
- 1kusd_getPSMParams() -> { feeBps, caps: [{asset,address,cap}], rateLimit:{windowSec,maxAmount} }
- 1kusd_getSafetyState() -> { pausedModules[], caps, rateLimits }
- 1kusd_getOracleState(asset) -> { price, decimals, healthy, lastUpdate }

## Governance (read-only)
- gov_listProposals(status?) -> Proposal[]
- gov_getProposal(id) -> Proposal
- gov_getVotes(proposalId, voter?) -> Vote[]
- gov_timelock() -> { minDelaySec, queue[] }
