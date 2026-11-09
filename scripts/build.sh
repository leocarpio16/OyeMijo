#!/bin/bash
# Compila la app y la corre en el simulador de iPhone.
# Uso: ./scripts/build.sh            → compila y corre
#      ./scripts/build.sh --solo-build → solo compila
#      ./scripts/build.sh --captura    → compila, corre y guarda captura en build/captura.png
set -euo pipefail

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
PROYECTO="$RAIZ/hackAthon/hackAthon.xcodeproj"
ESQUEMA="hackAthon"
# Fuera del Escritorio: iCloud/Finder agregan metadatos que rompen la firma.
DERIVED="$HOME/Library/Developer/Xcode/DerivedData/hackathon-ios"
LOG="$RAIZ/build.log"
mkdir -p "$RAIZ/build"

# iPhone disponible más reciente (última línea de la lista).
SIM=$(xcrun simctl list devices available | grep -E "^\s+iPhone" | tail -1 | sed -E 's/^ +//; s/ \(.*//')
if [ -z "$SIM" ]; then
  echo "No hay simuladores de iPhone. Instala la plataforma iOS en Xcode → Settings → Components."
  exit 1
fi
echo "▸ Simulador: $SIM"

echo "▸ Compilando…"
if ! xcodebuild -project "$PROYECTO" -scheme "$ESQUEMA" \
     -destination "platform=iOS Simulator,name=$SIM" \
     -derivedDataPath "$DERIVED" build > "$LOG" 2>&1; then
  grep -E "error:|failed" "$LOG" | sort -u | head -20 || true
  echo "✗ BUILD FAILED (log completo: build.log)"
  exit 1
fi
grep -E "warning:" "$LOG" | grep -v "appintents" | sort -u | head -10 || true
echo "✓ BUILD SUCCEEDED"

[ "${1:-}" = "--solo-build" ] && exit 0

APP=$(find "$DERIVED/Build/Products/Debug-iphonesimulator" -maxdepth 1 -name "*.app" | head -1)
BUNDLE=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP/Info.plist")

xcrun simctl boot "$SIM" 2>/dev/null || true
open -a Simulator
xcrun simctl install booted "$APP"
xcrun simctl launch --terminate-running-process booted "$BUNDLE" > /dev/null
echo "✓ Corriendo $BUNDLE en $SIM"

if [ "${1:-}" = "--captura" ]; then
  sleep 3
  xcrun simctl io booted screenshot "$RAIZ/build/captura.png" > /dev/null
  echo "✓ Captura: build/captura.png"
fi
