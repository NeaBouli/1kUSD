
Indexer Queries (Samples)

Latest reserves (REST)
GET /v1/reserves
Response:
{
"assets": [{"asset":"0x...","symbol":"USDC","decimals":6,"amount":"123"}],
"totalUSD":"123.45",
"updatedAt": 1690000000,
"finality":"safe"
}

PSM swaps (GraphQL)
query PsmSwaps($from:Int!, $to:Int!, $finality:String!) {
psmSwaps(where:{ timestamp_gte:$from, timestamp_lte:$to, finality:$finality }) {
txHash user asset amountIn amountOut fee blockNumber timestamp finality
}
}

Token holders (GraphQL)
query Holders($min:String!) {
tokenSupply {
holders(where:{ balance_gte:$min }) { address balance updatedAt }
totalSupply updatedAt
}
}

Events (REST)
GET /v1/events?name=Deposit&finality=safe&fromBlock=...
