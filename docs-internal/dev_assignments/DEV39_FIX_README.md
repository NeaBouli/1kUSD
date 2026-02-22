# 🧩 DEV-39 – Fix-Assignment: OracleAggregator Syntax / Prank-Flow Integration

Projekt: 1kUSD  
Status: 🔴 Fehlerhaft (Compile-Error)  
Zuständig: Fix-Developer DEV-39  
Branch: feature/dev39_oracle_guardian_fix  
Pfad: ~/Desktop/1kUSD

Problem:
Error (9182): Function, variable, struct or modifier declaration expected.
--> contracts/core/OracleAggregator.sol:55:9:
|
55 |         return _mockPrice[asset];
|         ^^^^^^

Ursache:
return-Zeile steht außerhalb der Funktion getPrice() – fehlerhafte Klammerbalance.

Ziel:
Wiederherstellung korrekter Funktionsgrenzen, sodass:

function getPrice(address asset)
    external
    view
    override
    returns (Price memory p)
{
    return _mockPrice[asset];
}

innerhalb des Contract-Körpers korrekt eingebettet ist.

Schritte:
1. forge build  → Fehler prüfen
2. Patch ausführen (siehe Patch 2 unten)
3. forge build && forge test --match-path 'foundry/test/Guardian_OraclePropagation.t.sol' -vvvv

Erwartet:
✅ Build erfolgreich  
✅ Tests grün

