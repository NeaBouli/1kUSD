#!/usr/bin/env node
// Render release notes from template + changelog and write to stdout.
// Usage: node scripts/release-notes.mjs v1.2.3 [prevTag]
import fs from "node:fs";
import { spawnSync } from "node:child_process";

const version = process.argv[2];
const prev = process.argv[3] || "";
if (!version) { console.error("Usage: node scripts/release-notes.mjs <version> [prevTag]"); process.exit(1); }

const tpl = fs.readFileSync(".github/release/RELEASE_NOTES_TEMPLATE.md","utf8");
const child = spawnSync("node", ["scripts/changelog-section.mjs", prev], { encoding: "utf8" });
if (child.status !== 0) { console.error(child.stderr || "failed to render changelog"); process.exit(2); }
const changelog = child.stdout.trim();

const out = tpl
.replaceAll("{{VERSION}}", version.replace(/^v/,""))
.replace("{{CHANGELOG_SECTION}}", changelog);

console.log(out);
