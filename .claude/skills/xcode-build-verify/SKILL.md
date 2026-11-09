---
name: xcode-build-verify
description: Compila la app iOS por terminal, la corre en el simulador, toma captura y traduce los errores de Swift a español sencillo. Úsala después de cada cambio en archivos .swift, cuando el usuario diga "compila", "córrela", "no compila", "qué significa este error" o antes de cualquier entrega.
---

# Compilar y verificar

## Entorno
- Siempre exporta `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` (la terminal apunta a Command Line Tools; no uses `sudo xcode-select`).
- Si existe `scripts/build.sh`, úsalo. Si no, usa los comandos de abajo.
- Nunca cambies el `.xcodeproj`, el Deployment Target ni la firma sin preguntar.

## Pasos
1. Descubre esquema y simulador:
   - `xcodebuild -list`
   - `xcrun simctl list devices available | grep iPhone` → elige el iPhone más nuevo.
2. Compila (salida corta):
   ```
   xcodebuild -scheme <Esquema> -destination 'platform=iOS Simulator,name=<iPhone>' \
     -derivedDataPath build build 2>&1 | grep -E "error:|warning:|BUILD" | head -40
   ```
3. Si compila, corre y captura:
   ```
   xcrun simctl boot "<iPhone>" 2>/dev/null; open -a Simulator
   xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/<App>.app
   xcrun simctl launch booted <bundle.id>
   xcrun simctl io booted screenshot <scratchpad>/captura.png
   ```
   Mira la captura antes de decir "funciona".

## Cómo reportar errores
Por cada error: archivo:línea, qué dice Swift (original), qué significa en español sencillo, y el arreglo mínimo. Si hay más de 5, arregla primero el primero: muchos son consecuencia de él.

Errores frecuentes para alguien que viene de Python:
- `Cannot find 'x' in scope` → variable/tipo no existe o está mal escrito (como NameError).
- `Type '...' does not conform to protocol 'View'` → el `body` devuelve algo que no es vista, o hay un error dentro que Swift reporta así.
- `Missing argument for parameter` → falta un argumento con etiqueta; en Swift las etiquetas son obligatorias.
- `Cannot assign to property: 'self' is immutable` → falta `@State` o la clase `@Observable`.
- `Value of optional type must be unwrapped` → el valor puede ser `nil` (como None); usa `if let` o `??`.

## Regla
No digas "listo" si no viste `BUILD SUCCEEDED` y la captura.
