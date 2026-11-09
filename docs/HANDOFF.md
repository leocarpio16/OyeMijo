# HANDOFF · lunes 9 nov 2026, ~17:05

## Dónde estamos
- **Bloque 0 terminado** (~1.5 h tarde vs ROADMAP por varias vueltas de diseño). Siguiente: **Bloque 1 · Voz**.
- Último commit: `045f148` Bloque 0. Antes: `e843f52` commit inicial.
- **Push pendiente:** el sistema de permisos bloquea `git push` desde Claude. Leo lo hace con `! git push -u origin main`.
- ¿Compila? Sí (`./scripts/build.sh --solo-build`). La app ya corre en el iPhone de Leo (Personal Team `R2822V9YZC`, bundle `comTodoBien.hackAthon`).

## Decisiones vigentes (no re-discutir)
- **Diseño = el del equipo "Oye Mijito – Pantallas"**: https://claude.ai/artifact/9TkGCckH36rwbxGNZHwsFq (tipo Design; las pantallas son `project/*.dc.html`: Main, Escuchando, Respuesta, Ayuda, Pastillas, Familia, etc.). Leerlas con Artifact `read` + `paths`. **No inventar estilos**: Leo rechazó ~8 propuestas propias por "verse hechas con IA".
- Fuentes: Avenir Next + New York (serif del sistema) en lugar de Figtree/Newsreader (no descargamos fuentes).
- Inicio: panel ámbar con Mijo, pastilla "Ayuda" arriba a la derecha (emergencia), "Buenas tardes," + nombre en serif, pastilla con la siguiente medicina, botón redondo ámbar "Toque y dígame qué necesita". Nada más.
- Dynamic Type de `.large` a `.xxxLarge` (en `hackAthonApp.swift`).
- Logo definitivo: `~/Downloads/WhatsApp Image 2026-11-09 at 15.11.38.jpeg` (fondo ámbar, gorra roja). Es el AppIcon y el asset `Mijo` (1600 px).
- El sistema de diseño de Arturo (azul, fondo gris) quedó **descartado** visualmente; su texto describe funciones fuera del PRD (iOS 27, anti-fraude, enseñar): que no entren al pitch.
- Lo demás del HANDOFF anterior sigue: Foundation Models + tool calling, emergencias sin IA, ntfy, iOS 26, sin cuenta de pago.

## Lo último que se hizo
- Modelos SwiftData en `Models/` (Familiar, Medicina, Toma, Comida, FichaMedica, Ajustes, Horario) + `SampleData` (Doña Mari, Leo/Carmen con teléfonos ficticios `55 0000 000x`, Losartán 50 mg 9:00/21:00, Metformina).
- `DesignSystem/`: `Theme` (tokens del diseño del equipo), `TalkButton`, `WhitePill`, `MijoAvatar` (para Escuchando/Respuesta).
- Se borraron (con permiso) los componentes de diseños descartados.

- **Nuevo (9 nov, 17:15): registro e "inicio de sesión" por voz (F6 del PRD, Bloque 1b del ROADMAP)**, minimalista. Sin cuentas: el perfil vive en el teléfono (Sign in with Apple no sirve con cuenta gratis; no hay servidor para SMS). "Conectar a la familia" = QR del tema ntfy. Fuera: intereses/talleres.

## Siguiente paso exacto
1. Leer `Escuchando.dc.html` y `Respuesta.dc.html` del artifact del equipo.
2. Bloque 1: servicio de voz (AVSpeechSynthesizer es-MX + Speech en el dispositivo), router de emergencia por palabras clave, agente `LanguageModelSession` con herramientas. El servicio de voz debe servir también para el registro (preguntar → escuchar → confirmar).
3. Pantallas "Mijo escuchando" y "Mijo responde" copiando el diseño; conectar `TalkButton` de Inicio.
4. Bloque 1b: registro por voz con las pantallas A–H del diseño (leer `Nombre`, `Contacto`, `Conectar`, `Medicina`, `Permisos`, `Listo`).

## Pendientes del usuario
- `! git push -u origin main`.
- Bloque 1: permisos de micrófono y reconocimiento de voz en Xcode (target → Info). Claude le pasa los pasos.
- Opcional: en Xcode → General → Display Name = `Mijo` (hoy aparece "hackAthon").
- Que Arturo o Sebastian instalen **ntfy**.

## Cuidado con
- Los nombres de capturas de macOS traen un espacio especial antes de "p.m.": copiarlas con glob a scratchpad antes de leerlas.
- Dribbble bloquea lectura automática: pedir capturas.
- El asset `MijoRecorte` (Mijo sin fondo) ya no se usa; se puede borrar si Leo aprueba.
- SourceKit marca errores falsos ("Cannot find 'Theme'"); manda `./scripts/build.sh`.
- Para reiniciar datos de ejemplo en el simulador: `xcrun simctl uninstall booted comTodoBien.hackAthon`.

## Archivos clave
- `CLAUDE.md`, `docs/PRD.md`, `docs/ROADMAP.md`, `scripts/build.sh`
- `hackAthon/hackAthon/ContentView.swift`, `hackAthonApp.swift`, `Models/`, `DesignSystem/`
