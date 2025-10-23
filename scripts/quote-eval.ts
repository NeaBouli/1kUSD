// Evaluate PSM quotes per docs/PSM_QUOTE_MATH.md using BigInt
// Usage: npx ts-node scripts/quote-eval.ts tests/vectors/psm_quote_vectors.json
import fs from "node:fs";

type To1k = { D_in: number; feeBps: number; amountIn: string; expected: { fee: string; grossOut: string; netOut: string } };
type From1k = { D_out: number; feeBps: number; amountIn: string; expected: { grossOut: string; fee: string; netOut: string } };

function pow10(n: number): bigint { return BigInt(10) ** BigInt(n); }

function to1k(amountIn: bigint, D_in: number, feeBps: number, DU=18) {
const fee = (amountIn * BigInt(feeBps)) / 10000n;
const netIn = amountIn - fee;
const grossOut = (netIn * pow10(DU)) / pow10(D_in);
const netOut = grossOut;
return { fee, grossOut, netOut };
}

function from1k(amountIn1k: bigint, D_out: number, feeBps: number, DU=18) {
const grossOut = (amountIn1k * pow10(D_out)) / pow10(DU);
const fee = (grossOut * BigInt(feeBps)) / 10000n;
const netOut = grossOut - fee;
return { grossOut, fee, netOut };
}

function main() {
const f = process.argv[2];
if (!f) { console.error("Usage: npx ts-node scripts/quote-eval.ts <vectors.json>"); process.exit(1); }
const vec = JSON.parse(fs.readFileSync(f, "utf8"));
const results:any = { to1k: [], from1k: [] };

for (const c of vec.to1k as To1k[]) {
const r = to1k(BigInt(c.amountIn), c.D_in, c.feeBps, vec.meta.DU);
results.to1k.push({ case: c["case"], got: { fee: r.fee.toString(), grossOut: r.grossOut.toString(), netOut: r.netOut.toString() }, exp: c.expected });
}
for (const c of vec.from1k as From1k[]) {
const r = from1k(BigInt(c.amountIn), c.D_out, c.feeBps, vec.meta.DU);
results.from1k.push({ case: c["case"], got: { grossOut: r.grossOut.toString(), fee: r.fee.toString(), netOut: r.netOut.toString() }, exp: c.expected });
}

console.log(JSON.stringify(results, null, 2));
}
main();
