#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Step 7: Lightweight View-Accessors =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

awk '
/function isHealthy\(\) external/ && /returns \(bool\)/ {
  # Ersetze die bisherige reine true-Rückgabe durch Cache-Check mit Default
  print "    /// @inheritdoc IOracleWatcher"
  print "    function isHealthy() external view returns (bool) {"
  print "        // Default to true until cache is explicitly updated in later steps."
  print "        if (!_health.cached) return true;"
  print "        return _health.status == Status.Healthy;"
  print "    }"
  skip=1
  next
}
skip==1 && /^    \}/ { skip=0; next }
{
  print
}
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# Hänge schlanke Getter unter die isHealthy()-Funktion
awk '
/function isHealthy\(\) external view returns \(bool\) \{/ { in_block=1 }
in_block && /^    \}/ { print; print ""; print "    /// @notice Returns the last known Status (Healthy/Paused/Stale)."; print "    function getStatus() external view returns (Status) {"; print "        return _health.status;"; print "    }"; print ""; print "    /// @notice Returns the unix timestamp of the last updateHealth/refreshState."; print "    function lastUpdate() external view returns (uint256) {"; print "        return _health.lastUpdate;"; print "    }"; print ""; print "    /// @notice Returns true if a health value has been cached."; print "    function hasCache() external view returns (bool) {"; print "        return _health.cached;"; print "    }"; in_block=0; next }
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

mkdir -p logs
printf "%s DEV-40 step7: add view accessors (getStatus/lastUpdate/hasCache) + neutral isHealthy cache check (no builds)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ DEV-40 Step 7 applied – view accessors added (no builds)."
