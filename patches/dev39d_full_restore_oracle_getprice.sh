#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-39D: Full restore of OracleAggregator.getPrice() =="

FILE="contracts/core/OracleAggregator.sol"
TMP="${FILE}.tmp"

awk '
# Entferne die fehlerhaften Return-Zeilen
/return _mockPrice\[asset\]/ { next }

# Nach isOperational() suchen, danach korrekten getPrice() einsetzen
/^    function isOperational/ {
    print;
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
    next;
}

{ print }
' "$FILE" > "$TMP"

mv "$TMP" "$FILE"

forge build

mkdir -p logs
printf "%s DEV-39D full restore applied by Fix-Dev-39 [getPrice()] [structural restore]\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
