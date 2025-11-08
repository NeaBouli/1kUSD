# DEV-28 – OracleWatcher (v0.34)

**Scope**
- Adds OracleWatcher for feed heartbeat monitoring  
- Tracks last update per feed  
- Detects stale or inactive feeds  
- DAO-configurable maxStale threshold and backup mapping  

**Tests**
✅ Timestamp tracking  
✅ Stale detection  
✅ Backup + config setters  
✅ DAO-only guard  

**Release:** v0.34 — OracleWatcher deployed with failover and heartbeat monitoring
