import fs from "node:fs";
import { aggregateOracle } from "../ts/src/index.js";

const vec = JSON.parse(fs.readFileSync("tests/vectors/oracle_guard_vectors.json","utf8"));
const case0 = vec.cases[0];

const out = aggregateOracle(
case0.sources,
{
mode: (case0.mode || "MEDIAN"),
trim: case0.trim,
decimalsOut: vec.meta.decimalsOut,
now: case0.now,
maxAgeSec: vec.meta.maxAgeSec,
maxDeviationBps: vec.meta.maxDeviationBps
}
);

console.log(JSON.stringify(out, null, 2));
