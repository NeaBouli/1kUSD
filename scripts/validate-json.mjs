#!/usr/bin/env node
// Validate a JSON file against a JSON Schema using AJV.
// Usage: node scripts/validate-json.mjs <schema.json> <data.json>
import fs from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";
import Ajv from "ajv";

const [,, schemaPath, dataPath] = process.argv;
if (!schemaPath || !dataPath) {
console.error("Usage: node scripts/validate-json.mjs <schema.json> <data.json>");
process.exit(1);
}
const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
const data = JSON.parse(fs.readFileSync(dataPath, "utf8"));

const ajv = new Ajv({ allErrors: true, strict: false });
const validate = ajv.compile(schema);
const valid = validate(data);
if (!valid) {
console.error("Validation failed:", validate.errors);
process.exit(2);
}
console.log("Validation OK");
