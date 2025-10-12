# 1kUSD SDK (Python) — Specification

**Scope:** Sync + Async client.  
**Status:** Spec (no code). **Language:** EN.

## 1. Structure
- kusd/: client.py, contracts/, indexer.py, psm.py, vault.py, oracle.py, safety.py, gov.py, events.py, errors.py, models.py

## 2. API Sketch
- swap_to_1kusd, get_balances, get_price, safety state, governance lists

## 3. Errors
- KusdError(domain, code, msg, cause)

## 4. Async
- AsyncKusd with httpx.AsyncClient + websockets
