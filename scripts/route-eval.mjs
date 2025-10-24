#!/usr/bin/env node
// Evaluate route policy against a hypothetical quote set.
// Usage: node scripts/route-eval.mjs converter/schemas/router.schema.json tests/vectors/routes.sample.json quotes.json
import fs from "node:fs";
import Ajv from "ajv";

const [,, schemaPath, routesPath, quotesPath] = process.argv;
if (!schemaPath || !routesPath) {
console.error("Usage: node scripts/route-eval.mjs <schema.json> <routes.json> [quotes.json]");
process.exit(1);
}
const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
const routes = JSON.parse(fs.readFileSync(routesPath, "utf8"));
const quotes = quotesPath && fs.existsSync(quotesPath)
? JSON.parse(fs.readFileSync(quotesPath, "utf8"))
: { quotes: [] };

// quotes format: { quotes: [{ adapter:"univ3-0.05", symbolFrom:"WETH", symbolTo:"USDC", priceOut: "1000.0", slippageBps: 42, liquidityUSD: "75000" }, ...] }

const ajv = new Ajv({ allErrors: true, strict: false });
const validate = ajv.compile(schema);
if (!validate(routes)) {
console.error("Routes JSON invalid:", validate.errors);
process.exit(2);
}

function pickBestRoute(routes, quotes) {
const Q = quotes.quotes || [];
const out = [];
for (const r of routes.routes) {
const q = Q.filter(x =>
x.adapter === r.adapter &&
String(x.symbolFrom || "").toUpperCase() === String(r.symbolFrom || "").toUpperCase() &&
String(x.symbolTo || "").toUpperCase() === String(r.symbolTo || "").toUpperCase()
);
for (const cand of q) {
const liqOk = BigInt(cand.liquidityUSD || "0") >= BigInt(r.minLiquidityUSD);
const slipOk = (cand.slippageBps || 0) <= r.maxSlippageBps;
const wlOk = r.whitelisted === true;
const ok = liqOk && slipOk && wlOk;
out.push({
route: r.adapter,
pair: ${r.symbolFrom||"?"}/${r.symbolTo||"?"},
liqOk, slipOk, wlOk, ok,
score: ok ? (1e12 / (1 + (cand.slippageBps||0))) : 0
});
}
}
out.sort((a,b)=>b.score-a.score);
return out;
}

const ranking = pickBestRoute(routes, quotes);
console.log(JSON.stringify(ranking, null, 2));
