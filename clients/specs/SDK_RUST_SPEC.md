# 1kUSD SDK (Rust) — Specification

**Scope:** Async Rust crate for services.  
**Status:** Spec (no code). **Language:** EN.

## 1. Crate Layout
- kusd-sdk: rpc, contracts, indexer, events, psm, vault, oracle, safety, gov, errors, models

## 2. Features
- ws, tls, abigen, offline

## 3. API Sketch
- Client::send_raw_tx, Client::call<T>

## 4. Errors
- thiserror enum: Network/Protocol/Oracle/Governance/Decode/Unknown

## 5. Streams
- Stream<Item=Result<DecodedEvent, Error>>; confirmations watermark
