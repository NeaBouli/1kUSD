#!/usr/bin/env node
import fs from "node:fs";
import Ajv from "ajv";
const schema = JSON.parse(fs.readFileSync("indexer/schemas/por_rollup.schema.json","utf8"));
const ajv = new Ajv({ allErrors:true, strict:false });
const validate = ajv.compile(schema);

const file = process.argv[2] || "tests/vectors/por_rollup.sample.json";
const data = JSON.parse(fs.readFileSync(file,"utf8"));

if (!validate(data)) {
console.error("PoR validation failed:", validate.errors);
process.exit(2);
}

// sanity: totals match asset sum
function sumUSD(assets){
return assets.reduce((a,x)=>a + BigInt(x.usdValueE8), 0n);
}
const sum = sumUSD(data.assets);
if (sum.toString() !== data.totals.balanceUSD_E8) {
console.error("Mismatch totals.balanceUSD_E8 vs sum(assets.usdValueE8)");
process.exit(3);
}

fs.mkdirSync("reports",{recursive:true});
fs.writeFileSync("reports/por_rollup_report.json", JSON.stringify({ ok:true, assets:data.assets.length, balanceUSD_E8:data.totals.balanceUSD_E8 }, null, 2));
console.log("PoR rollup OK:", file);
