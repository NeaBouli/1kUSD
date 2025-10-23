
Staging Bootstrap Runbook (Base Sepolia example)

Pre-checks

RPC health: curl -s https://sepolia.base.org

Fund deployer with test ETH + test USDC if needed.

Config

Review ops/configs/base.testnet.json (RPC, params)

Export RPC_URL and PRIVATE_KEY (never commit private keys)

Deploy (skeleton)

Ensure compile succeeds (forge build or npx hardhat compile)

Use scripts to deploy in order: Registry -> Safety -> Token -> Vault -> Oracle -> PSM -> Timelock

Address Book

Append deployed addresses to ops/addresses/address-book.sample.json or new file

Validate: npx ts-node scripts/validate-json.ts ops/schemas/address_book.schema.json ops/addresses/address-book.sample.json

Post-Checks

Read-only smoke via RPC_API: token name/symbol/decimals, PSM getters

Indexer: consume events for block range of deploy

Rollback

If any critical failure, halt further steps; do not mint or open PSM swaps.
