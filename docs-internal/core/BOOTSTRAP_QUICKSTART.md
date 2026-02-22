
Localnet Bootstrap Quickstart

Start local chain

./ops/localnet/start-anvil.sh

Compile

forge build (or) npx hardhat compile

Seed & addresses

./ops/localnet/seed-accounts.sh

./ops/localnet/deploy-skeleton.sh

node scripts/emit-env-from-addresses.ts ops/addresses/address-book.local.json 31337 > .env.addresses

Stop local chain

./ops/localnet/stop-anvil.sh
