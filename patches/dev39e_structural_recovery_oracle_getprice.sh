#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-39E: Structural recovery for OracleAggregator.isOperational() + getPrice() =="

FILE="contracts/core/OracleAggregator.sol"
TMP="${FILE}.tmp"

awk '
# Entferne alle fehlerhaften Reste von isOperational() und getPrice()
/function isOperational/ { skip=1 }
/return _mockPrice\[asset\]/ { next }
/function setAdmin/ { skip=0 }
skip { next }

# Füge saubere Version vor setAdmin() ein
/^    function setAdmin/ {
    print "";
    print "    /// @inheritdoc IOracleAggregator";
    print "    function isOperational() external view override returns (bool) {";
    print "        return !safety.isPaused(MODULE_ID);";
    print "    }";
    print "";
    print "    /// @inheritdoc IOracleAggregator";
    print "    function getPrice(address asset)";
    print "        external";
    print "        view";
    print "        override";
    print "        returns (Price memory p)";
    print "    {";
    print "        return _mockPrice[asset];";
    print "    }";
    print "";
}
{ print }
' "$FILE" > "$TMP"

mv "$TMP" "$FILE"

forge build

mkdir -p logs
printf "%s DEV-39E structural recovery applied by Fix-Dev-39 [isOperational()+getPrice()] [full restore]\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
