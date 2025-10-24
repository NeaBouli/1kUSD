#!/usr/bin/env node
// Execute a queued proposal (placeholder; prints execution plan)
import fs from "node:fs";

const file = process.argv[2];
if (!file) { console.error("Usage: node scripts/gov-exec.mjs <proposal.json>"); process.exit(1); }
const p = JSON.parse(fs.readFileSync(file,"utf8"));

const steps = p.targets.map((t, i) => ({
target: t,
value: p.values[i] || "0",
signature: p.signatures[i] || "",
calldata: p.calldatas[i] || "0x"
}));

console.log(JSON.stringify({
action: "EXECUTE",
title: p.title,
steps
}, null, 2));
