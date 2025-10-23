# Admin/Wiring Notes — v0
**Status:** Info (no code). **Language:** EN.

- All core contracts accept an `admin` in constructor (placeholder).
- Target state: `admin` becomes `DAOTimelock` address post-deploy.
- Parameter changes MUST go through Timelock once available.
- Safety pause is allowed for admin in DEV35; governance sunset/policies to be wired later.

## Address Templates
- See `ops/config/addresses.*.json`. Staging/testnet/mainnet placeholders included.
- SDK/dApp must read from these files for canonical addresses.
