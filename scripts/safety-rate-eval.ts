// Sliding-window rate limit evaluator (vectors)
// Usage: npx ts-node scripts/safety-rate-eval.ts tests/vectors/safety_rate_limit_vectors.json
import fs from "node:fs";

type Op = { t:number, amount:string };
type Vec = { meta:{ windowSec:number, maxAmount:string }, cases:{ case:string, ops:Op, expectRevertAt:number }[] };

function evaluate(vecPath:string) {
const v:Vec = JSON.parse(fs.readFileSync(vecPath,"utf8"));
const W = v.meta.windowSec;
const CAP = BigInt(v.meta.maxAmount);
const out:any = [];

for (const c of v.cases) {
const ops = c.ops.map(o => ({ t:o.t, amount: BigInt(o.amount) })).sort((a,b)=>a.t-b.t);
let ok = true; let revertAt = -1;
const window:Op = [];
for (let i=0;i<ops.length;i++){
const cur = ops[i];
// drop outside window
while (window.length && cur.t - window[0].t > W) window.shift();
let sum = 0n; for (const x of window) sum += BigInt((x as any).amount);
if (sum + cur.amount > CAP) { ok = false; revertAt = i; break; }
window.push(cur as any);
}
out.push({ case: c.case, expectRevertAt: c.expectRevertAt, gotRevertAt: revertAt, pass: (revertAt===c.expectRevertAt) });
}
console.log(JSON.stringify(out,null,2));
}

const p = process.argv[2] || "tests/vectors/safety_rate_limit_vectors.json";
evaluate(p);
