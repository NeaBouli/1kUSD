#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Step 9: Logic Implementation – updateHealth() =="

FILE="contracts/oracle/OracleWatcher.sol"
TMP="${FILE}.tmp"

awk '
/\/\/ Placeholder: will query oracle\.isOperational\(\)/ {
  print "        bool operational = true;"
  print "        bool paused = false;"
  print ""
  print "        // External calls wrapped in try/catch to avoid hard reverts."
  print "        try oracle.isOperational() returns (bool ok) {"
  print "            operational = ok;"
  print "        } catch {}"
  print ""
  print "        (bool success, bytes memory data) = safetyAutomata.staticcall("
  print "            abi.encodeWithSignature(\"isPaused(uint8)\", 1)"
  print "        );"
  print "        if (success && data.length >= 32) {"
  print "            paused = abi.decode(data, (bool));"
  print "        }"
  print ""
  print "        if (paused) {"
  print "            _health.status = Status.Paused;"
  print "        } else if (!operational) {"
  print "            _health.status = Status.Stale;"
  print "        } else {"
  print "            _health.status = Status.Healthy;"
  print "        }"
  print ""
  print "        _health.lastUpdate = block.timestamp;"
  print "        _health.cached = true;"
  print "        emit HealthUpdated(_health.status, _health.lastUpdate);"
  next
}
/\/\/ Placeholder: may be used by off-chain agents or DAO/ {
  print "        updateHealth();"
  next
}
{ print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# Append Event definition if missing
grep -q "event HealthUpdated" "$FILE" || echo "    event HealthUpdated(Status status, uint256 timestamp);" >> "$FILE"

mkdir -p logs
printf "%s DEV-40 step9: implemented updateHealth() + refreshState() logic + HealthUpdated event\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ DEV-40 Step 9 applied – logic for updateHealth/refreshState implemented."
