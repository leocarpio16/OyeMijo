# HANDOFF · lunes 9 nov 2026, ~19:40

## Dónde estamos
- **Bloque 1 · Voz: ~90 %.** Leo agregó los permisos y probó en su iPhone; se arreglaron los 3 problemas que encontró (ver abajo). Falta su 2.ª prueba.
- Último commit: `e91b844` (plan F6). **Cambios sin commit:** todo el Bloque 1 (`Services/`, `Conversation/`, componentes de `DesignSystem/`, `ContentView`, `Theme`, `hackAthonApp`, `.xcodeproj` con los 2 permisos, ROADMAP, HANDOFF).
- GitHub OyeMijo: hasta `149c2af` (falta `! git push` para `f33ad9e`, el script de entrega).
- **Entregables del evento:** `Datisa/` ya subido (commit `7093400` en 424144407-enviar-it/HACKATHON-ENTREGABLES). Copia local en `~/Desktop/HACKATHON-ENTREGABLES` (solo `Datisa/`). Para actualizar: `! ./scripts/entregar.sh` (sube lo que tenga commit en Mijo; la Keynote va a mano en `Datisa/Documentacion/`).
- ¿Compila? Sí, sin avisos.

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

## Bloque 1: qué hay (9 nov, 17:30)
- `Services/VoiceService.swift`: habla y escucha (es-MX). Si faltan los textos de permiso en el proyecto, `pedirPermisos()` regresa false en vez de tronar.
- `Services/EmergencyRouter.swift`: palabras clave → `.caida / .malestar / .ayuda`. Hoy la conversación contesta con frase fija + botón "Llamar a <principal>"; el Bloque 4 lo cambia por el protocolo.
- `Services/MijoActions.swift` (trabajo con SwiftData), `MijoTools.swift` (4 herramientas), `MijoAgent.swift` (sesión, frases fijas para filtro / IA no disponible).
- `Conversation/`: `ConversationModel` (escuchar → pensar → contestar), `ListeningView`, `AnswerView`, `ConversationView` (se abre desde el botón de Inicio; 2 s de silencio = "Ya terminé").
- `DesignSystem/`: `MijoHeader` (salió de ContentView), `RoundIconButton`, `PrimaryButton`, `WaveBars`, `.serif(_:)`.
- Fuera por ahora: `avisarFamilia` (Bloque 3) y `decirDireccion` (Bloque 4). Crear un recordatorio guarda la medicina, pero la notificación es del Bloque 2.

## 1.ª prueba de Leo (18:00) y arreglos
- Voz robótica → elegía "Shelley" (voz de efecto). Ahora: solo voces `com.apple.voice.*`, la de mejor calidad y, a igual calidad, de hombre.
- "Ok" → la IA inventó la hora de la pastilla. Ahora las frases cortas ("ok", "sí", "gracias", "hola") se contestan sin IA, y las instrucciones piden usar herramientas solo con una petición clara y hablar siempre de usted.
- "Me caí" pedía tocar un botón → ahora Mijo avisa solo por ntfy (prioridad urgente) y marca solo al familiar principal en cuanto termina de hablar. iOS siempre muestra un "Llamar" para confirmar: ninguna app puede marcar sin ese toque.
- "Llama a Leo" también marca solo. Nueva herramienta `marcarMedicinaTomada` ("ya me tomé la de la presión").
- El tema de ntfy se imprime en la consola de Xcode al abrir: `🔔 Tema de ntfy de la familia: mijo-…`.

## Plan nuevo (18:30, aprobado por Leo: "la veo muy inmadura")
Orden por lo que ve el jurado: 1) Ayuda → "¿Está bien?" ✅ · 2) "Sus pastillas de hoy" ✅ · 3) Mijo pregunta por ti ✅ (falta probar en iPhone) · 4) Registro por voz corto ✅ (Bienvenida → Nombre → Contacto → QR → Permisos → Listo) · 5) Siri · 6) Pulido (transiciones, vibración, "pensando", prueba en iPhone). Fuera: INE, Talleres, Intereses, app del familiar (`Fam*`).
- Hecho a las 18:40: `Help/` (HelpModel + HelpView), `Pills/PillsView`, `DesignSystem/TiltedCard`, `Medicina.horarioPorConfirmar()/tomadaHoy()`, `Horario(de:)/fechaDeHoy`. La emergencia salió de `ConversationModel`: ahora la conversación cambia a `HelpView` con `frase`.
- Commits: `18e8d05` (Ayuda + Pastillas), `4f363fb` (notificaciones). **Sin commit:** #4 registro (`Onboarding/`, `RootView`, `StepDots`, cambios en `MijoHeader`, `Persistence`, `MijoActions`).
- #4 (19:40): el registro crea `Ajustes` (tema ntfy corto `mijo-xxxx-xxxx-xxxx`) y un `Familiar` principal con `parentesco` vacío. Arreglado: un parentesco vacío hacía que "llama a X" coincidiera con cualquiera.
- #3 (19:15): `Models/Persistence` (base de datos única), `AppDelegate` (respuestas a notificaciones), `Services/NotificationService`, `VoiceRecorder` (voz de Mijo → Library/Sounds/*.caf), `FamilyAlerts` (pastilla/comida sin confirmar 30 min → ntfy; solo con la app abierta). Regla única de "Ahora": dosis sin tomar entre −2 h y +1 h (`Medicina.horarioPorConfirmar`).
- AlarmKit sigue fuera (2.º en el orden de sacrificio).

## Siguiente paso exacto
1. Leo prueba en el iPhone (borrar la app primero para ver el registro): registro completo → Inicio → "Recuérdame la pastilla de la presión a las 9 de la noche" → notificación con voz (mantener presionado a Mijo) → Ayuda.
2. #5 Siri: App Shortcuts "Habla con Mijo" y "Mijo, me caí" (App Intents).
3. #6 Pulido.

## Pendientes del usuario
- Voz más natural: en el iPhone, Ajustes → Accesibilidad → Contenido leído → Voces → Español (México) → descargar **Juan (Mejorada)** o **Paulina (Premium)**. La app la elige sola.
- Para el aviso: instalar **ntfy** en otro teléfono y suscribirse al tema que sale en la consola de Xcode.
- Opcional: en Xcode → General → Display Name = `Mijo` (hoy aparece "hackAthon").

## Cuidado con
- Los bloques que el sistema llama desde otros hilos (audio, Speech) van en funciones `nonisolated static` de `VoiceService`: el proyecto usa MainActor por defecto y, si se escriben dentro de un método normal, la app truena al escuchar.
- Para capturar una pantalla que no es Inicio: cambiar temporalmente la vista raíz en `hackAthonApp.swift`, `./scripts/build.sh --captura`, y restaurar.
- Los nombres de capturas de macOS traen un espacio especial antes de "p.m.": copiarlas con glob a scratchpad antes de leerlas.
- Dribbble bloquea lectura automática: pedir capturas.
- El asset `MijoRecorte` (Mijo sin fondo) ya no se usa; se puede borrar si Leo aprueba.
- SourceKit marca errores falsos ("Cannot find 'Theme'"); manda `./scripts/build.sh`.
- Para volver a ver el registro: borrar la app (simulador: `xcrun simctl uninstall booted comTodoBien.hackAthon`). Para saltarlo con doña Mari de ejemplo: mantener presionado a Mijo en Bienvenida.

## Archivos clave
- `CLAUDE.md`, `docs/PRD.md`, `docs/ROADMAP.md`, `scripts/build.sh`
- `hackAthon/hackAthon/ContentView.swift`, `hackAthonApp.swift`, `Models/`, `DesignSystem/`
