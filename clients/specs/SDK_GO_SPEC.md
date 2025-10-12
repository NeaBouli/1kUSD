# 1kUSD SDK (Go) — Specification

**Scope:** Go client for services/agents.  
**Status:** Spec (no code). **Language:** EN.

## 1. Modules
- client, contracts, indexer, psm, vault, oracle, safety, gov, events, errors

## 2. Interfaces
- Context-aware RPC client (Call, SendRawTx, GetReceipt)

## 3. Patterns
- context timeouts, backoff retry for NETWORK/RETRYABLE,
  zero-copy hex, functional options

## 4. Event Streaming
- reorg-aware with checkpointing, typed payload structs

## 5. Errors
- Error{Domain, Code, Msg, Cause}; wrapping via %w
