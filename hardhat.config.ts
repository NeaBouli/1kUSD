import { HardhatUserConfig } from "hardhat/config";
import * as dotenv from "dotenv";
dotenv.config();

const RPC_URL = process.env.RPC_URL || "http://localhost:8545";
const CHAIN_ID = Number(process.env.CHAIN_ID || 31337);
const PK = process.env.DEPLOYER_PRIVATE_KEY || "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"; // anvil

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: { enabled: true, runs: 200 }
    }
  },
  networks: {
    default: "local",
    local: {
      url: RPC_URL,
      chainId: CHAIN_ID,
      accounts: [PK]
    }
  }
};

export default config;
