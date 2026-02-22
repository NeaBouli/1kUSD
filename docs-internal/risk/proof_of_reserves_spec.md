# 1kUSD Proof-of-Reserves Specification  
## Economic Layer v0.51.0

## 1. Overview

This document defines the Proof-of-Reserves (PoR) specification for the 1kUSD Economic Layer v0.51.0. It describes how liabilities and reserves MUST be exposed through an on-chain view contract and complemented by off-chain Merkle-based snapshots and public JSON reports.

The design is intended for an EVM-compatible environment (Kasplex-compatible, final deployment chain TBD), with primary collateral on Ethereum mainnet:

- USDT (ERC20)
- USDC (ERC20)

Optional "risk-on" collaterals (e.g., WBTC, WETH / ETH) MAY be supported and are explicitly modeled as such in this specification.

This document uses the terminology of RFC 2119. The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY" and "OPTIONAL" are to be interpreted as described in RFC 2119.

## 2. Objectives

The PoR system MUST achieve the following objectives:

1. **Real-time transparency (view layer)**  
   Provide on-chain, read-only views that expose current protocol liabilities and reserve balances in a machine-readable way.

2. **Periodic verifiable snapshots (Merkle layer)**  
   Provide 6-hour snapshots of reserves and liabilities, signed and organized via Merkle trees to allow independent verification.

3. **Public reporting (JSON layer)**  
   Provide public JSON reports that mirror the on-chain and snapshot data, suitable for explorers, dashboards, and auditors.

4. **Auditability and reproducibility**  
   Ensure that independent third parties can reconstruct, verify and reconcile PoR data from on-chain events and collateral sources.

Cross-chain PoR for non-EVM deployments and bridges is explicitly OUT OF SCOPE for this version and MUST be handled in separate specifications.

## 3. Scope

### 3.1 In-Scope Assets & Liabilities

- **Liabilities**  
  - Total circulating 1kUSD supply (on the EVM deployment).
  - MAY additionally include segregated internal balances (e.g., protocol-owned 1kUSD, if relevant).

- **Reserves**  
  - USDT (ERC20) balances held by protocol vault(s).
  - USDC (ERC20) balances held by protocol vault(s).
  - OPTIONAL: WBTC (ERC20) balances.
  - OPTIONAL: WETH / ETH (ERC20) balances.

### 3.2 Out-of-Scope

The following items are explicitly out of scope for this PoR version:

- Reserves or liabilities on non-EVM chains.
- Cross-chain bridge balances and wrapped assets.
- Non-ERC20 collateral types.
- Any off-balance-sheet arrangements or external guarantees.

These items MAY be introduced in future PoR extensions and MUST NOT be assumed to be covered by this specification.

## 4. High-Level Design

The PoR system consists of three layers:

1. **On-Chain View Contract (Real-Time Layer)**  
   - Exposes read-only functions returning:
     - total 1kUSD supply (liability),
     - per-collateral vault balances (reserves),
     - aggregate reserve value vs. liabilities.

2. **Off-Chain Merkle Snapshots (6-Hour Layer)**  
   - Every 6 hours, an off-chain process:
     - reads on-chain state and external references (where needed),
     - builds a Merkle tree capturing a PoR snapshot,
     - signs and publishes the root alongside metadata.

3. **Public JSON Reports (Explorer Layer)**  
   - For each snapshot:
     - a JSON document is published,
     - referencing the Merkle root, timestamp, and on-chain anchor (if any),
     - ready for indexing and display by dashboards and explorers.

The Indexer and Telemetry specifications described elsewhere SHOULD integrate with this PoR system to provide live and historical PoR views.

## 5. On-Chain View Contract Specification

### 5.1 Design Principles

The on-chain view contract:

- MUST be read-only (no state mutations).
- MUST NOT hold funds.
- MUST aggregate data from:
  - the 1kUSD stablecoin contract,
  - the protocol vaults for each supported collateral,
  - internal accounting structures as needed.
- SHOULD be callable without reverting under normal circumstances.
- SHOULD be stable in terms of ABI to minimize integration friction.

### 5.2 Core Functions (Example Interface)

The following interface is illustrative and MUST be refined at implementation time:

```solidity
interface IProofOfReservesView {
    function totalLiabilities1kUSD() external view returns (uint256);
    function totalReservesByAsset(address asset) external view returns (uint256);
    function listedReserveAssets() external view returns (address[] memory);
    function aggregateReserveValueInUSD() external view returns (uint256);
    function reserveRatioBps() external view returns (uint256);
}
Expected semantics:

totalLiabilities1kUSD()

MUST return the total circulating 1kUSD supply that the PoR is meant to back (excluding any explicitly excluded internal balances, if defined).

totalReservesByAsset(asset)

MUST return the aggregate balance of the ERC20 asset held by the protocol's vaults and counted as reserves.

listedReserveAssets()

MUST return the list of collateral asset addresses that the view contract considers in its reserve calculations.

aggregateReserveValueInUSD()

SHOULD calculate the total reserve value using a conservative pricing source (e.g., the same oracle stack used by the Economic Layer).

MUST treat risk-on assets (WBTC, WETH) in a conservative manner, or MAY exclude them if they fall outside risk thresholds.

reserveRatioBps()

SHOULD return the ratio of aggregate reserve value to total liabilities in basis points (1e4 scale).

MAY cap values at a reasonable maximum (e.g., 20000 = 200%) to prevent overflow-like artifacts in dashboards.

5.3 Invariants
The PoR view contract MUST enforce or reflect the following invariants:

Under normal operation, aggregateReserveValueInUSD() >= totalLiabilities1kUSD() SHOULD hold.

If reserve value drops below liabilities, this MUST be observable via:

a reserveRatioBps() below 10000 (100%),

and MAY trigger additional flags or events in higher-level monitoring.

The view contract MUST be designed to gracefully handle oracle failures (e.g., returning stale or bounded values but not reverting catastrophically) where possible, while still surfacing clear signals to monitoring systems.

6. Off-Chain Merkle Snapshots
6.1 Frequency and Timing
Snapshots MUST be taken at least every 6 hours.

The snapshot scheduler SHOULD align with predictable UTC boundaries (e.g., 00:00, 06:00, 12:00, 18:00 UTC).

Additional ad-hoc snapshots MAY be taken around significant events (e.g., major depeg incidents, emergency actions).

6.2 Snapshot Contents
Each snapshot MUST capture:

Timestamp (UTC).

Block number (or block hash) on the EVM chain.

Total 1kUSD liabilities.

Per-collateral reserve balances:

USDT

USDC

OPTIONAL: WBTC

OPTIONAL: WETH / ETH

Derived values:

aggregate reserve value in USD,

reserve ratio.

Optional derived metrics (e.g., share of each collateral, risk buckets).

All these fields MUST be encoded into a structured format suitable for Merkle-tree leaves (e.g., canonical RLP or JSON-serialized blobs).

6.3 Merkle Tree & Root
A Merkle tree MUST be constructed over the snapshot dataset.

The Merkle root MUST be:

logged in a persistent, append-only ledger (e.g., IPFS, Git-based log, or chain event),

associated with:

snapshot timestamp,

block reference,

version tag.

Where possible, the Merkle root SHOULD be anchored on-chain via an event or a dedicated PoR anchor contract.

6.4 Signatures
The entity (or entities) generating the snapshot MUST sign:

the snapshot metadata (timestamp, block, version),

the Merkle root.

Signatures SHOULD be verifiable using a public key or address controlled by:

the Operator / Risk Council, or

a dedicated PoR signer role.

Multi-signer schemes MAY be introduced later to improve decentralization.

7. Public JSON Reports
7.1 JSON Structure
For each snapshot, a JSON document SHOULD be published with at least the following fields:

json
Code kopieren
{
  "version": "0.51.0-por",
  "timestamp_utc": "YYYY-MM-DDTHH:MM:SSZ",
  "chain": "evm-tbd",
  "block_number": 0,
  "liabilities_1kusd": "0",
  "reserves": {
    "USDT": { "asset": "<erc20_address>", "balance": "0" },
    "USDC": { "asset": "<erc20_address>", "balance": "0" },
    "WBTC": { "asset": "<erc20_address>", "balance": "0", "optional": true },
    "WETH": { "asset": "<erc20_address>", "balance": "0", "optional": true }
  },
  "aggregate_reserve_value_usd": "0",
  "reserve_ratio_bps": 0,
  "merkle_root": "0x...",
  "signature": "0x...",
  "por_anchor_tx": "0x..."
}
Arrays or alternative structures MAY be used as long as they remain unambiguous and documented.

7.2 Publication & Retention
JSON reports SHOULD be stored in:

a publicly accessible location (e.g., IPFS, object storage, or Git-based repository),

with stable URLs or identifiers for historical access.

Retention SHOULD be long-term (years), especially for snapshots around major events.

Dashboards, explorers, and indexers MAY fetch these reports to reconstruct historical PoR timelines.

8. Security & Threat Model
8.1 Potential Attack Vectors
The PoR system MUST consider the following threats:

View Contract Manipulation

Incorrect integration or misconfiguration leading to under-reporting of liabilities or over-reporting of reserves.

Oracle Manipulation

Adversaries manipulating prices to temporarily inflate reserve valuations.

Snapshot / Merkle Fraud

Incorrect or dishonest snapshot generation, misreporting balances or ignoring liabilities.

Key Compromise

PoR signing keys being compromised, allowing forged snapshots or JSON reports.

8.2 Mitigations
Mitigations SHOULD include:

Cross-checks between:

PoR view contract output,

direct vault balances,

independent external explorers.

Conservative oracle usage:

using lower-bound prices for risk-on assets,

treating oracle failures explicitly.

Multi-party oversight:

Operator, Risk Council, and possibly external auditors reviewing PoR processes.

Key management:

hardware-backed keys where possible,

key rotation policies,

clear procedures if PoR keys are suspected to be compromised.

9. Operational Process
The PoR operational process SHOULD follow these steps:

At each 6-hour interval:

Read on-chain state and oracle prices.

Compute liabilities and reserves.

Build the Merkle tree and compute the root.

Generate the JSON report.

Sign the snapshot.

Publish artifacts:

Anchor the Merkle root on-chain (if supported).

Upload the JSON report to the public storage location.

Log or index the snapshot for dashboards and monitoring.

Monitoring:

Check for anomalies in reserve ratios.

Trigger alerts if reserve ratio falls below defined thresholds.

Coordinate with Guardian / Risk Council if anomalies persist.

10. Integration with Indexer & Telemetry
Indexers and telemetry systems SHOULD:

Ingest on-chain PoR view contract data.

Ingest Merkle and JSON snapshot data.

Compute and display:

historical reserve ratios,

collateral distribution,

deviation between real-time and snapshot data.

Alerting systems (Prometheus/Grafana-style) MAY be configured to:

Raise alerts when:

reserve ratio drops below configured levels,

snapshots are delayed beyond the expected 6-hour window,

discrepancies between sources exceed tolerance thresholds.

11. Future Extensions
Future PoR versions MAY:

Incorporate cross-chain PoR for bridged 1kUSD instances.

Integrate more decentralized oracle sources.

Introduce multi-signer or DAO-controlled PoR signers.

Provide zero-knowledge proofs for additional privacy-preserving guarantees.

These extensions MUST be specified separately and MUST NOT be assumed covered by the v0.51.0 PoR design.

