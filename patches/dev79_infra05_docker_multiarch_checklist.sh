#!/usr/bin/env bash
set -euo pipefail

echo "== DEV79 INFRA05: write Docker/Multi-Arch checklist for 1kUSD =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DOC="docs/logs/DEV79_Infra_Docker_MultiArch_Checklist.md"
LOG_FILE="logs/project.log"

mkdir -p "$(dirname "$DOC")"

cat > "$DOC" <<'MD'
# DEV79 – Docker / Multi-Arch Checklist (Blueprint)

**Rolle:** DEV-7 (Infra / Docker / CI / Pages)  
**Scope:** Nur Dokumentation – keine direkten Änderungen an Dockerfiles, CI oder Registry.

Dieses Dokument skizziert, wie ein stabiler Docker-/Multi-Arch-Setup
für 1kUSD aussehen kann. Es dient als Grundlage für zukünftige,
kleine INFRA-Tickets und ersetzt keine bestehenden Builds.

---

## 1. Ziele

- Reproduzierbare Builds für:
  - Foundry / Tests
  - Docs / MkDocs-Build
  - (optional) Tooling wie Slither, Format/Lint
- Multi-Arch-Images (z.B. \`linux/amd64\`, \`linux/arm64\`) via Buildx.
- Saubere Trennung:
  - **Runtime-Images** (falls später Frontend/Services kommen),
  - **Dev/CI-Images** (Test- und Docs-Umgebung).

---

## 2. Docker-Basisprinzipien für 1kUSD

Empfohlene Leitlinien:

- **Pinned Versions**
  - Basis-Images mit festen Tags (z.B. \`ubuntu:22.04\`, \`node:20-bullseye\`,
    \`foundry\`-Version via \`foundryup\` Pin).
  - Dokumentation der aktuell getesteten Kombinationen hier im File.

- **Layering**
  - Ein zentrales „Dev-Image“ mit:
    - Foundry,
    - Python + \`pip\` (für MkDocs),
    - ggf. Node/Yarn, falls später notwendig.
  - Separate, schlanke Runtime-Images, falls benötigt (nicht Teil von DEV79).

- **Kontext-Minimierung**
  - Docker-Build-Kontext so klein wie möglich halten:
    - keine lokalen Artefakte (\`site/\`, \`cache/\`) in den Build-Kontext kippen.
  - \`.dockerignore\` konsequent pflegen (separates Ticket).

---

## 3. Multi-Arch-Strategie (Buildx Blueprint)

Empfohlenes Vorgehen (als Idee, nicht als aktiver Befehl):

- Nutzung von Docker Buildx mit vordefiniertem Builder:
  - \`docker buildx create --name 1kusd-builder --use\`
  - \`docker buildx inspect --bootstrap\`
- Multi-Arch-Cross-Builds:
  - Zielplattformen: \`linux/amd64\`, \`linux/arm64\`
  - klar dokumentieren, welche Plattformen offiziell unterstützt sind.
- Optional:
  - lokales Testen nur auf \`linux/amd64\`,
  - Multi-Arch-Push nur im CI, nicht lokal.

Konkrete Build-/Push-Kommandos sollten in einem eigenen INFRA-Ticket
definiert und in die CI-Workflows integriert werden.

---

## 4. CI-Integration (Entwurf)

Mögliche Struktur für spätere CI-Jobs (nur Beschreibung):

1. **Build-Job „docker-dev-image“**
   - Basiert auf einem \`Dockerfile.dev\`.
   - Installiert:
     - Foundry (gepinnt),
     - Python + MkDocs,
     - evtl. Node.
   - Baut Multi-Arch-Image und pusht zu einem Registry-Namespace wie:
     - \`ghcr.io/NeaBouli/1kusd-dev:<tag>\`

2. **Test-Job mit Docker-Reuse**
   - Nutzt das Dev-Image als Basis:
     - führt \`forge test\` innerhalb des Containers aus,
     - optional \`mkdocs build\`.
   - Vorteil: identische Umgebung lokal/CI.

3. **Release-Job (optional, später)**
   - Baut nur für Release-Tags,
   - versieht Images mit stabilen Tags (\`v0.51.0\`, \`v0.52.0\`).

Wichtig: Diese Punkte sind **TODOs** für zukünftige Tickets, kein Teil
von DEV79 selbst.

---

## 5. Registry & Tagging-Konzept (Vorschlag)

- **Registry:** bevorzugt GitHub Container Registry (\`ghcr.io\`).
- **Namensschema:**
  - \`ghcr.io/NeaBouli/1kusd-dev:<branch|tag>\`
- **Tags:**
  - \`main\` → \`latest\` bzw. \`main\`,
  - Feature-Branches → \`feature-<name>\`,
  - Releases → \`vX.Y.Z\`.

Tagging-Strategie sollte in einem separaten Governance-/Infra-Dokument
oder im Release-Guide ergänzt werden.

---

## 6. Mögliche nächste INFRA-Tickets

Einige sinnvolle, kleine Schritte:

- **INFRA-Next-Docker-01 – Dev-Image definieren**
  - \`Dockerfile.dev\` anlegen.
  - Foundry + MkDocs + Python installieren.
  - Lokal testen (nur \`docker build\`, kein Push).

- **INFRA-Next-Docker-02 – CI-Job für Dev-Image**
  - GitHub Action, die \`Dockerfile.dev\` baut.
  - Option: Push nach \`ghcr.io\` mit Branch-Tag.

- **INFRA-Next-Docker-03 – Tests im Container**
  - CI-Jobs, die das Dev-Image nutzen und \`forge test\` +
    optional \`mkdocs build\` ausführen.

- **INFRA-Next-Docker-04 – Multi-Arch-Ausbau**
  - Erweiterung der bestehenden Jobs auf \`linux/amd64\` + \`linux/arm64\`.
  - Dokumentation, auf welchen Plattformen 1kUSD offiziell unterstützt wird.

---

## 7. Zusammenfassung

- DEV79 INFRA05 nimmt **keine** Änderungen an Dockerfiles, CI oder Registry vor.
- Diese Checkliste beschreibt:
  - Zielbild für Docker/Multi-Arch,
  - sinnvolle nächste Schritte für kleine INFRA-Tickets,
  - ohne den Economic Layer v0.51.0 oder Strategy/PSM-Logik zu verändern.
- DEV-7 kann dieses Dokument als Ausgangspunkt nutzen, wenn
  Docker/Multi-Arch-Builds offiziell auf die Roadmap kommen.
MD

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-79] ${timestamp} Infra: added Docker/Multi-Arch checklist blueprint." >> "$LOG_FILE"

echo "✓ Docker/Multi-Arch checklist written to ${DOC}"
echo "✓ Log updated at ${LOG_FILE}"
echo "== DEV79 INFRA05: done =="
