#!/usr/bin/env node
// Queue a governance proposal (placeholder flow; prints computed description-hash)
import fs from "node:fs";
import crypto from "node:crypto";

const file = process.argv[2];
if (!file) { console.error("Usage: node scripts/gov-queue.mjs <proposal.json>"); process.exit(1); }
const p = JSON.parse(fs.readFileSync(file,"utf8"));
const descHash = "0x" + crypto.createHash("sha256").update(p.description).digest("hex");
console.log(JSON.stringify({
action: "QUEUE",
title: p.title,
targets: p.targets.length,
descHash,
eta: p.eta || 0
}, null, 2));
