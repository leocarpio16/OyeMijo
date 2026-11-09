#!/bin/bash
# Copia la última versión con commit de Mijo a la carpeta Datisa/ del
# repositorio de entregables del evento y la sube.
#   Datisa/Codigo/         ← proyecto de Xcode + scripts
#   Datisa/Documentacion/  ← docs/ (sin HANDOFF) + Keynote cuando exista
# Uso: ./scripts/entregar.sh           → copia, hace commit y push
#      ./scripts/entregar.sh --sin-push → copia y hace commit, sin subir
# Solo toca la carpeta Datisa/ (regla del evento: nada de otros equipos).
set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
ENTREGABLES="$HOME/Desktop/HACKATHON-ENTREGABLES"
URL="https://github.com/424144407-enviar-it/HACKATHON-ENTREGABLES.git"
EQUIPO="Datisa"

# 1. Copia local del repo del evento, solo con nuestra carpeta.
if [ ! -d "$ENTREGABLES/.git" ]; then
  echo "▸ Descargando el repo de entregables (solo $EQUIPO/)…"
  git clone --quiet --filter=blob:none --sparse "$URL" "$ENTREGABLES"
  git -C "$ENTREGABLES" sparse-checkout set "$EQUIPO"
fi
echo "▸ Trayendo lo último de los demás equipos…"
git -C "$ENTREGABLES" pull --quiet --rebase

# 2. Exporta lo que tiene commit en Mijo (nada de build/, ni archivos personales).
if [ -n "$(git -C "$RAIZ" status --porcelain)" ]; then
  echo "⚠︎ Hay cambios sin commit en Mijo: se sube solo lo que ya tiene commit."
fi
EXPORT="$(mktemp -d)"
trap 'rm -rf "$EXPORT"' EXIT
git -C "$RAIZ" archive HEAD | tar -x -C "$EXPORT"
VERSION="$(git -C "$RAIZ" log -1 --format='%h %s')"

# 3. Código.
DESTINO="$ENTREGABLES/$EQUIPO"
mkdir -p "$DESTINO/Codigo" "$DESTINO/Documentacion"
rsync -a --delete --exclude README.md "$EXPORT/hackAthon" "$EXPORT/scripts" "$DESTINO/Codigo/"
cat > "$DESTINO/Codigo/README.md" <<EOF
# Mijo · código

App iOS (Swift + SwiftUI, iOS 26) del equipo Datisa.
Repositorio de trabajo: https://github.com/leocarpio16/OyeMijo
Versión: \`$VERSION\`

## Cómo abrirla
1. Abrir \`hackAthon/hackAthon.xcodeproj\` en Xcode 26.
2. Elegir un iPhone con iOS 26 (Foundation Models necesita Apple Intelligence activado).
3. En Signing & Capabilities, poner su propio equipo de desarrollo y correr (⌘R).

Sin dependencias externas. Desde terminal: \`./scripts/build.sh\`.
EOF

# 4. Documentación (la Keynote se agrega a mano en Documentacion/ y se conserva).
rsync -a --exclude HANDOFF.md "$EXPORT/docs/" "$DESTINO/Documentacion/"

# 5. Commit y push.
cd "$ENTREGABLES"
git add -A "$EQUIPO"
if git diff --cached --quiet; then
  echo "✓ Nada nuevo que subir: $EQUIPO/ ya tiene \"$VERSION\"."
  exit 0
fi
git commit --quiet -m "Datisa: Mijo ($VERSION)"
echo "✓ Commit en entregables: Datisa: Mijo ($VERSION)"
if [ "${1:-}" = "--sin-push" ]; then
  echo "▸ Falta subir: git -C \"$ENTREGABLES\" push"
  exit 0
fi
git push --quiet
echo "✓ Subido a $URL ($EQUIPO/)"
