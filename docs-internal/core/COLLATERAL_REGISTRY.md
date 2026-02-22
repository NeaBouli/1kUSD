
Collateral Registry — Spec (v1)

Purpose

Canonical whitelist check for protocol modules (PSM, AutoConverter, Vault)

Advisory cache of decimals and off-chain metadata pointer (hash)

Requirements

isSupported(asset) MUST be true for assets usable in PSM/Vault paths

Decimals cache used as optimization; modules must handle mismatches safely

Metadata JSON conforms to schemas/asset_metadata.schema.json; keccak256 hash may be stored on-chain

Eventing

AssetListed(asset, listed) on add/remove

AssetMetadataUpdated(asset, metaHash) on metadata change

Interfaces

On-chain: contracts/interfaces/ICollateralRegistry.sol

Off-chain JSON samples: tests/vectors/collateral_assets.sample.json
