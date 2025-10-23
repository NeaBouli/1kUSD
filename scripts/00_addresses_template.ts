// Template for addresses JSON emission
import fs from "node:fs";
import path from "node:path";

type AddressBook = { chainId: number; contracts: Record<string,string>; };

const outDir = "ops/config";
const outFile = "addresses.template.json";

const data: AddressBook = {
  chainId: Number(process.env.CHAIN_ID || 31337),
  contracts: {
    "OneKUSD": "0x0000000000000000000000000000000000000000",
    "PegStabilityModule": "0x0000000000000000000000000000000000000000",
    "CollateralVault": "0x0000000000000000000000000000000000000000",
    "OracleAggregator": "0x0000000000000000000000000000000000000000",
    "SafetyAutomata": "0x0000000000000000000000000000000000000000",
    "ParameterRegistry": "0x0000000000000000000000000000000000000000"
  }
};

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, outFile), JSON.stringify(data, null, 2));
console.log(`Wrote ${path.join(outDir, outFile)}`);
