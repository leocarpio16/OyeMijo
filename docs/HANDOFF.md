# HANDOFF · lunes 9 nov 2026, ~21:30

## Dónde estamos
- Bloques 0–5 casi completos; Bloque 6 (iPhone real) y Bloque 7 (entrega) pendientes. ~75 % del plan.
- Último commit: `6823c33` Mijo abre apps y busca en YouTube. **Sin commit (24 archivos, pedir OK a Leo):** caída completa + ubicación, rediseño de la pantalla de emergencia, letra DM Sans, tarjetas derechas, `docs/PRUEBAS_IPHONE.md`.
- ¿Compila? Sí (`./scripts/build.sh --solo-build` → BUILD SUCCEEDED).
- GitHub OyeMijo: el remoto va atrasado (faltan pushes: `! git push`). **Datisa: no hacer push antes del martes 10 nov, 9:00** (aviso de Leo); luego `! ./scripts/entregar.sh`.
- **Nada probado aún en el iPhone.** Leo hará todas las pruebas al final con `docs/PRUEBAS_IPHONE.md`.

## Decisiones vigentes (no re-discutir)
- Diseño base = "Oye Mijito – Pantallas" del equipo (https://claude.ai/artifact/9TkGCckH36rwbxGNZHwsFq, `project/*.dc.html`). Sin adornos ni estilos inventados.
- **Letra: DM Sans en toda la app** (Leo, 21:20; rechazó Avenir + serifa y SF Pro). `.ttf` + OFL en `DesignSystem/Fonts/`, registrada en `Fuentes.swift` (sin Info.plist). Títulos `.display(_:)` (DM Sans 36pt, negrita); textos largos `weight: .semibold`. Ya no existe `.serif()`.
- **Tarjetas derechas, una sola** (sin tarjeta de atrás): `DesignSystem/WhiteCard.swift` (antes `TiltedCard`).
- Pantalla de emergencia: inspirada en las plantillas de Leo (`~/Downloads/template*App.webp`: mancha + ilustración, barra por segmentos, controles redondos) **con los colores del equipo** (rosa `helpGlow`, ámbar claro `answerGlow`, crema, café, rojo solo ayuda).
- Mijo = agente tipo Muse: lo pide con la voz y lo hace. Emergencias **sin IA** (EmergencyRouter → HelpView).
- Llamar y mandar WhatsApp siempre piden 1 toque (regla de iOS). El aviso ntfy sale solo.
- Caída: pregunta "¿Le duele algo?" (también si lo dijo por voz). No contesta 30 s → aviso urgente. "No me duele" → 6 pasos (cada uno espera "ya" o 15 s; ⏮ 🔊 ⏭); "no puedo" o 1 min callado al final → urgente.
- Permiso de ubicación: clave `NSLocationWhenInUseUsageDescription` en el .xcodeproj (con OK de Leo) y 3.er permiso en el registro.
- Sin cuentas; perfil local. Siempre modo claro. Dynamic Type `.large…xxxLarge`. App visible como **Mijo**.
- AlarmKit y "Enséñame" (guías) fuera.

## Lo último que se hizo (hoy, 20:30–21:30)
- Herramientas nuevas del agente (10 en total): `mandarWhatsApp`, `avisarFamilia`, `abrirApp`, `buscarEnYouTube`, `decirDireccion`.
- `Services/LocationService.swift`: GPS una vez (máx. 6 s) + dirección con `MKReverseGeocodingRequest`; ntfy con botón "Ver en el mapa".
- `Help/HelpModel.swift` + `HelpView.swift` rehechos (ramas me duele / no me duele, pasos, rediseño). `DesignSystem/BlobShape.swift` nuevo.
- Letra DM Sans y tarjetas derechas en toda la app. Capturas en `build/caida_*.png`, `build/fuente_*.png`, `build/tarjeta_*.png`.

## Siguiente paso exacto
1. Preguntar a Leo si hace el commit de todo lo pendiente (mensaje sugerido: "Caída completa con ubicación, rediseño de emergencia, DM Sans y tarjetas derechas").
2. **Siri con teléfono bloqueado** (propuesto, Leo no ha dicho sí aún): en `Intents/MijoIntents.swift`, que `MeCaiIntent` mande el ntfy urgente con ubicación **antes** de abrir la app (hoy `openAppWhenRun = true` pide desbloquear y Face ID puede fallar en el piso).
3. **F5 configuración familiar (~1 h)**: pantalla oculta (mantener presionado) para pastillas, ficha médica y familiares.
4. Martes temprano: Bloque 7 (README, PRD con lo que existe, pitch, preguntas, Keynote) y `./scripts/entregar.sh` antes de 14:30 (no antes de las 9:00).

## Pendientes del usuario
- Pruebas en el iPhone: **`docs/PRUEBAS_IPHONE.md`** (regresar con ✅/❌ y qué dijo Mijo en cada ❌). Borrar la app antes para que pida los 3 permisos.
- Voz natural: Ajustes → Accesibilidad → Contenido leído → Voces → Español (México) → Juan (Mejorada) o Paulina (Premium).
- Instalar **ntfy** en otro teléfono y escanear el QR del registro.
- `! git push` (OyeMijo). Datisa después de las 9:00 del martes.

## Cuidado con
- El simulador no sirve para voz, Siri, llamadas, GPS real ni sonido de avisos. Tiene un perfil "Sobas" con tema ntfy real: **no dejar correr la cuenta de 30 s en el simulador** (manda un aviso de verdad al equipo).
- Capturas de otras pantallas: cambiar temporalmente la raíz en `hackAthonApp.swift` (y `empezar()`/`contar()` en HelpModel), `./scripts/build.sh --captura`, restaurar y revisar con `git diff`. A veces la captura sale en blanco: repetir.
- `figure.roll` es una silla de ruedas, no usar. Ilustraciones de pasos: wind, figure.core.training, figure.flexibility, chair, figure.step.training, figure.seated.side, figure.stand.
- 10 herramientas en Foundation Models: si Mijo dice "no le entendí" más seguido o elige mal, recortar descripciones.
- Código llamado desde otros hilos (audio, Speech, notificaciones, Siri) va `nonisolated`/`@MainActor` explícito.
- Texto vacío "está contenido" en cualquier frase: revisar `!isEmpty`.
- SourceKit marca errores falsos (revisa como macOS); manda `./scripts/build.sh`.
- `git push` lo bloquea el sistema de permisos: Leo lo corre con `!`.

## Archivos clave
- `CLAUDE.md`, `docs/PRD.md`, `docs/ROADMAP.md`, `docs/PRUEBAS_IPHONE.md`, `docs/IDEAS.md`, `scripts/build.sh`, `scripts/entregar.sh`
- `hackAthon/hackAthon/`: `Services/` (MijoAgent, MijoTools, MijoActions, LocationService, NtfyService, EmergencyRouter, VoiceService…), `Help/`, `Conversation/`, `Pills/`, `Onboarding/`, `Intents/`, `DesignSystem/` (Theme, Fuentes, Fonts/, WhiteCard, BlobShape)
