#!/usr/bin/env node
// Extract changelog items since the previous tag (or all if none).
// Usage: node scripts/changelog-section.mjs [prevTag]
// Requires: git, docs/CHANGELOG.md
import fs from "node:fs";
import { execSync } from "node:child_process";

const prev = process.argv[2] || "";
let since = "";
try {
if (prev) since = execSync(git rev-list -n 1 ${prev}, { stdio: ["ignore","pipe","ignore"] }).toString().trim();
} catch {}
const md = fs.readFileSync("docs/CHANGELOG.md","utf8");
if (!since) {
console.log(md.trim());
process.exit(0);
}
// Fallback: if you want to diff by date/commit markers, customize here.
// For now, return the whole changelog (simple mode).
console.log(md.trim());
