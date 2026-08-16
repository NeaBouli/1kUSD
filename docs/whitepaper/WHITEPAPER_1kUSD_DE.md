# 1kUSD Konzept- und Implementierungsspezifikation

Version: Remediation-Entwurf, 2026-08-16

> Dieses Dokument beschreibt Produktziel und Architektur. Es ist kein Nachweis
> für Produktivbetrieb, Audit-Zertifizierung, Reserven, Liquidität oder einen
> garantierten Peg.

## Zusammenfassung

1kUSD soll ein vollständig besicherter, USD-orientierter Token mit beidseitiger
Konvertierung über ein Peg Stability Module werden. Das Modell vermeidet
Nutzer-CDP-Schulden und Liquidationspositionen. Seine Sicherheit hängt von
Collateralqualität, Accounting, Oracles, Limits, Governance, Liquidität, Betrieb
und unabhängig geprüfter Software ab.

## Kernmechanismus

Freigegebenes Collateral gelangt in einen Vault. Nach Asset-, Preis-, Limit-,
Gebühren-, Deadline- und Pauseprüfungen mintet das PSM den Nettobetrag 1kUSD. Bei
der Rückgabe werden 1kUSD verbrannt und Nettocollateral freigegeben. Gebühren
folgen einer ausdrücklich freigegebenen Reserve-/Treasury-Policy.

Erforderliche Invarianten umfassen Supply Conservation, Reservendeckung, atomare
Swaps, begrenzte Ausgabe, deterministisches Runden sowie Gebühren- und
Assetabgleich.

## Governance und Sicherheit

Das Produktionsziel verwendet Timelock-Multisig-Governance, begrenzte Parameter,
zweistufige Rollenübertragung und einen zeitlich begrenzten Guardian. Dieser darf
definierte Module pausieren, aber keine Gelder bewegen. Resume und Autorität nach
dem Sunset müssen einer einzigen geprüften Rollenmatrix folgen.

## Oracle

Produktionspreise benötigen unabhängige reale Feeds oder ein anderes ausdrücklich
freigegebenes Trust Model mit Freshness, Deviation, Quorum, Fallback, Monitoring
und Incident-Regeln. Der aktuelle Admin-Mock ist ausschließlich für Tests.

## Aktueller Implementierungsstand

Der EVM-Prototyp baut und besitzt eine substanzielle Foundry-Suite. Er enthält
jedoch acht Platzhaltertests, unvollständige Branch-Coverage, Mock-Oracle,
Timelock-/Fee-Stubs und Testnet-/Demo-Deployment. Der Safety-/Guardian-Lifecycle
ist testgehärtet; produktive Rollenübergabe und Deployment-E2E bleiben gegated.
Er ist kein Produktionssystem.

## Kaspa Toccata

Kaspa Toccata ist UTXO-/Covenant-nativ. Ein Kaspa-1kUSD muss Zustand als
Covenant-UTXOs oder freigegebenen Based-App-State modellieren, Nachfolgeroutputs
validieren, native Asset-Ausgabe definieren, heißen PSM-Zustand sharden,
Oraclereports prüfen und Indexer-/Reorg-Recovery unterstützen. Solidity liefert
ökonomische Spezifikation und Invarianten, keinen direkt portierbaren Runtimecode.

Der erste Meilenstein ist ein gepinnter, wertbegrenzter Prototyp auf Testnet-10
unter einem separat freigegebenen Ausführungsticket. Die Architektur ist in
ADR-042 akzeptiert; es wird kein Kaspa-Mainnet-Datum zugesagt.

## Releasevoraussetzungen

Kein Mainnetrelease ohne produktive Oracle-/Governance-/Fee-/Monitoring-Systeme,
vollständigen Deployment-E2E, freigegebene Coverage-/Static-Analysis-Gates, keine
offenen High/Medium-Findings, Legal-/Reservefreigabe, externes Audit und Bug Bounty.

Der [Masterplan](https://github.com/NeaBouli/1kUSD/blob/main/docs-internal/planning/MASTER_PLAN_2026.md)
definiert das ausführbare Programm.
