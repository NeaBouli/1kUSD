# JSON Validation Notes
**Status:** Docs. **Language:** EN.

## Schemas
- Addresses: `ops/config/schema/addresses.schema.json`
- Params: `ops/config/schema/params.schema.json`

## How to validate (locally)
- VS Code: install a JSON schema extension; `$schema` is embedded in the JSON files.
- CLI (example): `npx ajv-cli validate -s ops/config/schema/addresses.schema.json -d ops/config/addresses.staging.json`

> We intentionally avoid hard dependencies in CI at this stage. When needed, add a dedicated workflow job using `ajv-cli` or `spectral`.
