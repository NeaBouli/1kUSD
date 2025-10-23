// SDK example: load canonical addresses (Node.js)
import fs from "node:fs";
import path from "node:path";

export type AddressBook = { chainId: number; contracts: Record<string, string>; };

export function loadAddresses(root = process.cwd()): AddressBook {
  const cand = ["ops/config/addresses.staging.json","ops/config/addresses.testnet.json","ops/config/addresses.template.json"];
  for (const rel of cand) {
    const p = path.join(root, rel);
    if (fs.existsSync(p)) return JSON.parse(fs.readFileSync(p, "utf8")) as AddressBook;
  }
  throw new Error("No addresses.*.json found under ops/config/");
}
