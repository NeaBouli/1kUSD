#!/usr/bin/env node
import fs from "node:fs";
import Ajv from "ajv";

const schema = JSON.parse(fs.readFileSync("oracles/schemas/adapter.schema.json","utf8"));
const ajv = new Ajv({ allErrors:true, strict:false });
const validate = ajv.compile(schema);

const file = process.argv[2] || "oracles/catalog/1.json";
const cat = JSON.parse(fs.readFileSync(file,"utf8"));

let ok = true;
for (const [i, a] of (cat.adapters||[]).entries()) {
const valid = validate(a);
if (!valid) {
ok = false;
console.error(Adapter[${i}] invalid:, validate.errors);
}
}
if (!ok) process.exit(2);
console.log("Catalog OK:", file);
