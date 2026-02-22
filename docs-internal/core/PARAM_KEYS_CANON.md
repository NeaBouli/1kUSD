# Canonical Parameter Keys (bytes32) — v1

**Status:** Docs. **Audience:** Core devs, SDK authors, ops.  
**Goal:** Single source of truth for on-chain parameter keys and derivation rules.

## 1) Global Keys (fixed strings)
| Key Name | Seed String | Type | Notes |
|---|---|---|---|
| PARAM_PSM_FEE_BPS | "PARAM_PSM_FEE_BPS" | uint256 | Fee in basis points (0..10000) |
| PARAM_TREASURY_ADDRESS | "PARAM_TREASURY_ADDRESS" | address | Treasury receiver (Timelock-controlled) |
| PARAM_ORACLE_MAX_AGE_SEC | "PARAM_ORACLE_MAX_AGE_SEC" | uint256 | Max allowed staleness |
| PARAM_ORACLE_MAX_DEVIATION_BPS | "PARAM_ORACLE_MAX_DEVIATION_BPS" | uint256 | Max deviation across sources |
| PARAM_RATE_WINDOW_SEC | "PARAM_RATE_WINDOW_SEC" | uint256 | Sliding window for rate limits |
| PARAM_GUARDIAN_SUNSET_TS | "PARAM_GUARDIAN_SUNSET_TS" | uint256 | Guardian sunset timestamp |
| PARAM_DECIMALS_PAD_USD | "PARAM_DECIMALS_PAD_USD" | uint256 | USD normalization pad (e.g., 18) |

Derive bytes32 as: `keccak256(bytes(Seed String))`.

## 2) Asset-Scoped Keys (composite)
Use **ABI-encoded** derivation:
key = keccak256(abi.encodePacked("PARAM_CAP_PER_ASSET", asset));

sql
Code kopieren
| Key Family | Seed Prefix | Type | Example |
|---|---|---|---|
| CAP per asset | "PARAM_CAP_PER_ASSET" | uint256 | Max vault balance for asset |
| DECIMALS hint | "PARAM_DECIMALS_HINT" | uint256 | Advisory only (SDK fallback) |
| RATE max amount | "PARAM_RATE_MAX_AMOUNT" | uint256 | Max gross flow per window (token units) |
| PSM enabled | "PARAM_PSM_ASSET_ENABLED" | uint256/bool | 1 = enabled; 0 = disabled |

**Rule:** Always use `abi.encodePacked(prefix, asset)` with **lower-cased** EVM address (Solidity addresses are already canonical).

## 3) Module Addresses (wiring)
| Key Name | Seed String | Type |
|---|---|---|
| ADDR_PSM | "ADDR_PSM" | address |
| ADDR_VAULT | "ADDR_VAULT" | address |
| ADDR_ORACLE | "ADDR_ORACLE" | address |
| ADDR_TOKEN_1KUSD | "ADDR_TOKEN_1KUSD" | address |
| ADDR_SAFETY | "ADDR_SAFETY" | address |
| ADDR_REGISTRY | "ADDR_REGISTRY" | address |

## 4) Versioning & Backward Compatibility
- Adding new keys: **append-only**; never change existing seeds.
- Deprecation: keep old keys live; introduce `..._V2` seeds as needed.
- SDKs must expose `deriveCompositeKey(prefix, asset)` helper.

## 5) Testing Notes
- Fuzz: no collisions across key families for random addresses.
- Invariants: registry read returns default (0/address(0)) if unset.
