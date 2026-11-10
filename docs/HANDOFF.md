# HANDOFF · lunes 9 nov 2026, ~20:30

## Dónde estamos
- Plan "que no se vea inmadura" (aprobado 18:30): #1 Ayuda ✅ · #2 Pastillas ✅ · #3 Mijo pregunta por ti ✅ · #4 Registro por voz ✅ · #5 Siri ✅ · #6 Pulido ✅ (1.ª pasada). **Nada probado aún en el iPhone** (Leo lo hará y avisará qué falla).
- Último commit: `cf78c4b` Siri. **Sin commit:** pulido #6 (`DesignSystem/Haptics.swift` nuevo; cambios en ContentView, ConversationModel/View, ListeningView, botones, WaveBars, HelpModel, PillsView, hackAthonApp, ROADMAP, HANDOFF). Preguntar a Leo antes de hacer el commit.
- **No hacer push a Datisa antes del martes 10 nov, 9:00** (aviso de Leo). Pulido con commit `88687ba`. `mandarWhatsApp` con commit `1749c1e`. `avisarFamilia` hecho, sin commit.
- GitHub OyeMijo: hasta `149c2af` (faltan pushes: `! git push`). Entregables `Datisa/`: 1.ª copia subida (`7093400`); actualizar con `! ./scripts/entregar.sh`.
- ¿Compila? Sí, sin avisos.

## Decisiones vigentes (no re-discutir)
- **Diseño = "Oye Mijito – Pantallas"** del equipo: https://claude.ai/artifact/9TkGCckH36rwbxGNZHwsFq (leer `project/*.dc.html` con Artifact `read` + `paths`). No inventar estilos ni adornos (Leo rechazó ~8 propuestas propias).
- Fuentes: Avenir Next + New York (`.serif(_:)`). Todo token en `DesignSystem/Theme.swift`.
- Mijo es **agente tipo Muse**: lo pide con la voz y Mijo lo hace (IDEAS, Sesión 8). Todo en el teléfono.
- Emergencias **sin IA** (EmergencyRouter → HelpView); llamar siempre pide 1 toque de iOS.
- Sin cuentas: perfil local creado por el registro. Ya no se cargan datos de ejemplo solos (demo: mantener presionado a Mijo en Bienvenida).
- App visible como **Mijo** (Display Name, con permiso de Leo). Frases de Siri en `Intents/AppShortcuts.xcstrings` (es, es-419); proyecto en inglés.
- "Ahora" de una pastilla = sin tomar entre −2 h y +1 h (`Medicina.horarioPorConfirmar`).
- Siempre modo claro. Dynamic Type `.large…xxxLarge`.
- "Enséñame" (guías paso a paso) **fuera** del PRD. Pendiente que Leo decida si Netflix = abrir app + pista corta (recomendado) o guía.
- AlarmKit fuera (orden de sacrificio).

## Lo último que se hizo (hoy, 18:30–20:30)
- `Help/` "¿Está bien?" (30 s, voz, ntfy urgente, llamada automática, ficha médica). `Pills/` "Sus pastillas de hoy".
- Notificaciones con la voz de Mijo (`NotificationService`, `VoiceRecorder` → Library/Sounds, `AppDelegate`, `Persistence`), `FamilyAlerts` (sin confirmar 30 min → ntfy, solo con la app abierta).
- `Onboarding/` (Bienvenida, Nombre, Contacto, Conectar QR, Permisos, Listo) + `RootView`.
- `Intents/` Siri: habla con Mijo, Mijo me caí, ¿ya me tomé la pastilla?
- Pulido: modo claro, silencio 8 s, transiciones, barras "pensando", vibración, estados vacíos, revisado a XXXL.

## Siguiente paso exacto (orden aprobado por Leo, 20:25)
2. **Mijo "hace cosas" (~1.5 h)**, herramientas nuevas en `Services/MijoTools.swift` + `MijoActions.swift`:
   - ✅ `mandarWhatsApp` (`AccionDeMijo.mandarMensaje`, se abre solo al terminar de hablar, como la llamada).
   - ✅ `avisarFamilia` (ntfy prioridad alta, "Mensaje de <nombre>"). Instrucciones: si nombra a alguien → WhatsApp; "a mi familia/a todos" → ntfy.
   - `abrirApp(nombre)` → Netflix/YouTube/WhatsApp/Música/Mapas por URL; `buscarEnYouTube(texto)`; Mijo dice una pista corta.
   - Agregar a las instrucciones del agente y a la tarjeta de respuesta.
3. **Caída completa (~1 h)**: "¿Le duele algo?" → sí: ntfy con ubicación + dirección en voz (CoreLocation, pedir permiso de ubicación: requiere clave en el .xcodeproj → preguntar) · no: pasos para levantarse. Herramienta `decirDireccion`.
4. **F5 configuración familiar (~1 h)**: pantalla oculta (mantener presionado) para pastillas, ficha médica y familiares.
5. Martes temprano: Bloque 7 (README, PRD con lo que existe, pitch, preguntas, Keynote) y `./scripts/entregar.sh` antes de 14:30.

## Pendientes del usuario
- Probar en el **iPhone** (no en simulador): borrar la app → registro → "Recuérdame la pastilla de la presión a las 9 de la noche" → mantener presionado a Mijo y bloquear (notificación con voz) → Ayuda → 3 frases de Siri. Reportar qué falla y qué dice Mijo.
- Voz más natural: Ajustes → Accesibilidad → Contenido leído → Voces → Español (México) → Juan (Mejorada) o Paulina (Premium).
- Instalar **ntfy** en otro teléfono y escanear el QR del registro.
- `! git push` y, al final, `! ./scripts/entregar.sh`.

## Cuidado con
- El simulador **no sirve** para voz, Siri, llamadas ni sonido de notificaciones. Tiene un perfil "Sobas" del equipo.
- Código que el sistema llama desde otros hilos (audio, Speech, notificaciones, Siri) va en funciones `nonisolated`/`@MainActor` explícitas: el proyecto usa MainActor por defecto y si no, truena.
- Un texto vacío "está contenido" en cualquier frase: revisar `!isEmpty` al comparar (ya pasó con `parentesco`).
- iOS no ejecuta código de una app cerrada a cierta hora: los avisos de "sin confirmar" salen al abrir la app.
- Capturas de otras pantallas: cambiar temporalmente la raíz en `hackAthonApp.swift`, `./scripts/build.sh --captura`, restaurar. Simulador apagado → `simctl ui` falla.
- `git push` lo bloquea el sistema de permisos: Leo lo corre con `!`.
- SourceKit marca errores falsos; manda `./scripts/build.sh`.

## Archivos clave
- `CLAUDE.md`, `docs/PRD.md`, `docs/ROADMAP.md`, `docs/IDEAS.md` (Sesión 8), `scripts/build.sh`, `scripts/entregar.sh`
- `hackAthon/hackAthon/`: `RootView`, `ContentView`, `Services/` (VoiceService, EmergencyRouter, MijoAgent, MijoTools, MijoActions, NtfyService, NotificationService, VoiceRecorder, FamilyAlerts), `Conversation/`, `Help/`, `Pills/`, `Onboarding/`, `Intents/`, `DesignSystem/`, `Models/`
