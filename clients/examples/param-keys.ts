// Canonical parameter keys — TypeScript helpers (docs-first)

export const GLOBAL_KEYS = {
  PARAM_PSM_FEE_BPS:         "PARAM_PSM_FEE_BPS",
  PARAM_TREASURY_ADDRESS:    "PARAM_TREASURY_ADDRESS",
  PARAM_ORACLE_MAX_AGE_SEC:  "PARAM_ORACLE_MAX_AGE_SEC",
  PARAM_ORACLE_MAX_DEV_BPS:  "PARAM_ORACLE_MAX_DEVIATION_BPS",
  PARAM_RATE_WINDOW_SEC:     "PARAM_RATE_WINDOW_SEC",
  PARAM_GUARDIAN_SUNSET_TS:  "PARAM_GUARDIAN_SUNSET_TS",
  PARAM_DECIMALS_PAD_USD:    "PARAM_DECIMALS_PAD_USD",
} as const;

export const PREFIX = {
  CAP_PER_ASSET:        "PARAM_CAP_PER_ASSET",
  DECIMALS_HINT:        "PARAM_DECIMALS_HINT",
  RATE_MAX_AMOUNT:      "PARAM_RATE_MAX_AMOUNT",
  PSM_ASSET_ENABLED:    "PARAM_PSM_ASSET_ENABLED",
} as const;

// bytes32 derivation (keccak256) for Node/browser
// NOTE: This uses a small inline keccak to stay self-contained.
// For production, prefer a battle-tested lib (e.g., viem or ethers/utils).
import { keccak_256 } from "@noble/hashes/sha3";
function toBytes(str: string): Uint8Array { return new TextEncoder().encode(str); }
function hex(bytes: Uint8Array): string { return "0x" + Array.from(bytes).map(b=>b.toString(16).padStart(2,"0")).join(""); }

export function keyOf(seed: string): `0x${string}` {
  return hex(keccak_256(toBytes(seed))) as `0x${string}`;
}

export function compositeKey(prefix: string, asset: string): `0x${string}` {
  // abi.encodePacked(prefix, asset) approximation: lowercase hex address without checksum tweaks
  const clean = asset.toLowerCase();
  const bytes = new Uint8Array([
    ...toBytes(prefix),
    ...toBytes(clean)
  ]);
  return hex(keccak_256(bytes)) as `0x${string}`;
}
