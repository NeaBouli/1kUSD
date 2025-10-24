#!/usr/bin/env node
import fs from "node:fs";
import Ajv from "ajv";

const schema = JSON.parse(fs.readFileSync("indexer/schemas/health.schema.json","utf8"));
const ajv = new Ajv({ allErrors:true, strict:false });
const validate = ajv.compile(schema);

const file = process.argv[2] || "tests/vectors/health.sample.json";
const data = JSON.parse(fs.readFileSync(file, "utf8"));

if (!validate(data)) {
console.error("Health validation failed:", validate.errors);
process.exit(2);
}
const lines = [];
lines.push(STATUS: ${data.status});
lines.push(Components: ${data.components.map(c=>c.name+":"+c.status).join(", ")});
lines.push(Finality: conf=${data.finality.confirmations} lastIndexed=${data.finality.lastIndexed} lastFinalized=${data.finality.lastFinalized});
fs.mkdirSync("reports",{recursive:true});
fs.writeFileSync("reports/health_check.txt", lines.join("\n"));
console.log("Health OK:", file);
