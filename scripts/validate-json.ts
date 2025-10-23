// Validate JSON file against a JSON Schema (AJV v8)
// Usage: npx ts-node scripts/validate-json.ts <schema.json> <data.json>
import fs from "node:fs";
import Ajv from "ajv";

function main() {
const [schemaPath, dataPath] = process.argv.slice(2);
if (!schemaPath || !dataPath) {
console.error("Usage: npx ts-node scripts/validate-json.ts <schema.json> <data.json>");
process.exit(1);
}
const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
const data = JSON.parse(fs.readFileSync(dataPath, "utf8"));
const ajv = new Ajv({ allErrors: true, strict: false });
const validate = ajv.compile(schema);
const ok = validate(data);
if (!ok) {
console.error(JSON.stringify(validate.errors, null, 2));
process.exit(2);
}
console.log("OK");
}

main();
