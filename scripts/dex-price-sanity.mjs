#!/usr/bin/env node
// Compare DEX price vs oracle median with deviation cap.
// Usage: node scripts/dex-price-sanity.mjs tests/vectors/dex_price_sanity_vectors.json
import fs from "node:fs";

const file = process.argv[2] || "tests/vectors/dex_price_sanity_vectors.json";
const data = JSON.parse(fs.readFileSync(file, "utf8"));
const cap = Number(data.meta?.maxDeviationBps ?? 300);

function bpsDeviation(aE8, bE8) {
const a = BigInt(aE8), b = BigInt(bE8);
if (a === 0n) return Infinity;
const diff = a > b ? (a - b) : (b - a);
return Number((diff * 10000n) / a);
}

const results = [];
for (const c of data.cases) {
const dev = bpsDeviation(c.oraclePriceE8, c.dexPriceE8);
const ok = dev <= cap;
results.push({ pair: c.pair, deviationBps: dev, ok, expect: c.expect });
}

fs.mkdirSync("reports", { recursive: true });
fs.writeFileSync("reports/dex_price_sanity_report.json", JSON.stringify({ capBps: cap, results }, null, 2));

const fails = results.filter(r => (r.expect === "ok" && !r.ok) || (r.expect === "deviation" && r.ok));
const lines = [
DEX Price Sanity — cap=${cap}bps,
...results.map(r => ${r.pair} dev=${r.deviationBps}bps ok=${r.ok} expect=${r.expect}),
Summary: total=${results.length} fails=${fails.length}
];
fs.writeFileSync("reports/dex_price_sanity_summary.txt", lines.join("\n"));
console.log("Wrote reports/dex_price_sanity_report.json and dex_price_sanity_summary.txt");
