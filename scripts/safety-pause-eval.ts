// Pause/Resume & Guardian sunset evaluator (vectors)
// Usage: npx ts-node scripts/safety-pause-eval.ts tests/vectors/safety_pause_vectors.json
import fs from "node:fs";

type Op = { t:number, action:string, actor?:string, shouldRevert?:boolean, error?:string };
type Case = { case:string, ops:Op };
type Vec = { meta:{sunsetTs:number}, cases:Case };

function evaluate(vecPath:string) {
const v:Vec = JSON.parse(fs.readFileSync(vecPath,"utf8"));
const SUNSET = v.meta.sunsetTs;
const out:any = [];
let paused = false;

for (const c of v.cases) {
paused = false;
const results:any = [];
for (const op of c.ops) {
if (op.action === "PAUSE") {
if (op.actor === "guardian" && op.t >= SUNSET) {
results.push({ t: op.t, action: op.action, reverted: true, error: "GUARDIAN_EXPIRED" });
} else {
paused = true;
results.push({ t: op.t, action: op.action, ok: true });
}
} else if (op.action === "RESUME") {
// Only DAO can resume in this model
if (op.actor !== "dao") {
results.push({ t: op.t, action: op.action, reverted: true, error: "ACCESS_DENIED" });
} else {
paused = false;
results.push({ t: op.t, action: op.action, ok: true });
}
} else if (op.action === "TRY_OP") {
if (paused) results.push({ t: op.t, action: op.action, reverted: true, error: "PAUSED" });
else results.push({ t: op.t, action: op.action, ok: true });
}
}
out.push({ case: c.case, results });
}
console.log(JSON.stringify(out,null,2));
}

const p = process.argv[2] || "tests/vectors/safety_pause_vectors.json";
evaluate(p);
