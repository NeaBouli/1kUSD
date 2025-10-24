#!/usr/bin/env node
// Cross-check PSM quotes vs. canonical math (stand-in for exec path math).
// Usage: node scripts/psm-crosscheck.mjs tests/vectors/psm_quote_vectors.json
import fs from "node:fs";

function pow10(n){ return BigInt(10) ** BigInt(n); }

function to1k(amountIn, D_in, feeBps, DU=18){
amountIn = BigInt(amountIn); D_in = Number(D_in); feeBps = Number(feeBps);
const fee = (amountIn * BigInt(feeBps)) / 10000n;
const netIn = amountIn - fee;
const grossOut = (netIn * pow10(DU)) / pow10(D_in);
const netOut = grossOut;
return { fee, grossOut, netOut };
}

function from1k(amountIn1k, D_out, feeBps, DU=18){
amountIn1k = BigInt(amountIn1k); D_out = Number(D_out); feeBps = Number(feeBps);
const grossOut = (amountIn1k * pow10(D_out)) / pow10(DU);
const fee = (grossOut * BigInt(feeBps)) / 10000n;
const netOut = grossOut - fee;
return { grossOut, fee, netOut };
}

function diff(expected, got) {
const d = {};
for (const k of Object.keys(expected)) {
const e = BigInt(expected[k]);
const g = BigInt(got[k]);
d[k] = { exp: e.toString(), got: g.toString(), ok: e===g };
}
d.ok = Object.values(d).every(v => typeof v === "object" ? v.ok !== undefined ? v.ok : true : true);
return d;
}

function main(){
const vecPath = process.argv[2] || "tests/vectors/psm_quote_vectors.json";
const vec = JSON.parse(fs.readFileSync(vecPath, "utf8"));
const DU = vec.meta?.DU ?? 18;
const report = { to1k: [], from1k: [], summary: {} };

for (const c of (vec.to1k || [])) {
const got = to1k(c.amountIn, c.D_in, c.feeBps, DU);
const cmp = diff(c.expected, { fee: got.fee, grossOut: got.grossOut, netOut: got.netOut });
report.to1k.push({ case: c.case, ...cmp });
}
for (const c of (vec.from1k || [])) {
const got = from1k(c.amountIn, c.D_out, c.feeBps, DU);
const cmp = diff(c.expected, { grossOut: got.grossOut, fee: got.fee, netOut: got.netOut });
report.from1k.push({ case: c.case, ...cmp });
}

const all = [...report.to1k, ...report.from1k];
const pass = all.filter(x => x.ok).length;
report.summary = { total: all.length, pass, fail: all.length - pass, timestamp: new Date().toISOString() };

// Write machine report
fs.mkdirSync("reports", { recursive: true });
fs.writeFileSync("reports/psm_quote_exec_report.json", JSON.stringify(report, null, 2));

// Write human summary
const lines = [];
lines.push(PSM Quote/Exec Cross-Check — ${report.summary.timestamp});
lines.push(Total: ${report.summary.total} | Pass: ${report.summary.pass} | Fail: ${report.summary.fail});
for (const row of all) {
if (!row.ok) lines.push(FAIL: ${row.case});
}
fs.writeFileSync("reports/psm_quote_exec_summary.txt", lines.join("\n"));

console.log("Wrote reports/psm_quote_exec_report.json and reports/psm_quote_exec_summary.txt");
}
main();
