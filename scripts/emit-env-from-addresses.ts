// Emit .env snippet from address book for a given chainId
// Usage: node scripts/emit-env-from-addresses.ts ops/addresses/address-book.sample.json 31337 > .env.addresses
import fs from "node:fs";

function main() {
const [bookPath, chainIdStr] = process.argv.slice(2);
if (!bookPath || !chainIdStr) {
console.error("Usage: node scripts/emit-env-from-addresses.ts <address-book.json> <chainId>");
process.exit(1);
}
const chainId = Number(chainIdStr);
const book = JSON.parse(fs.readFileSync(bookPath, "utf8"));
const chain = (book.chains as any[]).find(c => c.chainId === chainId);
if (!chain) { console.error("Chain not found in address book"); process.exit(2); }
const map: Record<string,string> = {};
for (const c of chain.contracts) {
const key = ADDR_${String(c.name).toUpperCase()};
map[key] = c.address;
}
const lines = Object.entries(map).map(([k,v]) => ${k}=${v});
console.log(lines.join("\n"));
}

main();
