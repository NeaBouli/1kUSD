# 1kUSD SDK (TypeScript) — Specification

**Scope:** Browser/Node TS SDK for read/write interactions with 1kUSD protocol.  
**Status:** Spec (no code). **Language:** EN.

## 1. Package Layout
- @1kusd/sdk (core)
  - providers/, contracts/, rpc/, indexer/, governance/, safety/, tx/, events/
  - errors.ts, types.ts

## 2. Core APIs (high-level)
- Provider mgmt, token supply/balance, PSM swap helpers, Vault PoR views,
  Oracle snapshots, Safety state, Governance lists, Indexer query.

## 3. Tx Flow (xref: TX_BUILD_FLOWS.md)
- build → sign → simulate → broadcast → wait

## 4. Events (xref: EVENT_DECODING_SPEC.md)
- subscribe/unsubscribe; typed decoders

## 5. Errors (xref: COMMON_ERRORS.md)
- reject with KusdError(domain, code, message, cause)

## 6. Config
- rpcUrl, indexerUrl, chainId, confirmations, gasPolicy

## 7. Tests
- provider stubs, ABI fixtures, decoder snapshot tests
