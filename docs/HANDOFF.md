# HANDOFF · lunes 9 nov 2026, 14:30

## Dónde estamos
- Fin de la fase de ideación. PRD v2.0 y ROADMAP escritos. **Siguiente: Bloque 0 del ROADMAP.**
- Último commit: ninguno (repo inicializado, remoto `origin` = github.com/leocarpio16/OyeMijo, privado). Hay archivos sin commit: todo el proyecto.
- ¿Compila? Sí (`./scripts/build.sh --solo-build`), app base con 3 pestañas provisionales y `DesignSystem/Theme.swift`.

## Decisiones vigentes (no re-discutir)
- Nombre: **Mijo**. Agente por voz con Foundation Models + tool calling.
- Funciones: F0 agente, F1 notificaciones con voz ("¿Ya cenó, doña Mari?") con botones, F2 medicinas con verificación, F3 caídas con **ruta fija sin IA**, F4 avisos a la familia por **ntfy.sh**, F5 configuración por la familia.
- Fuera: fraude, guías largas, check-in de señal de vida, Create ML.
- iOS 26.0+ (deployment target ya bajado a 26.0). iPhone 17 Pro con iOS 26.1. Xcode 26.6. **No actualizar dispositivos antes de la entrega.**
- Sin cuenta de Apple Developer de pago.
- El usuario aprueba commits y push. Entrega en `HACKATHON-ENTREGABLES/Datisa/` (solo tocar esa carpeta).

## Lo último que se hizo
- Prueba real de Foundation Models en la Mac (scratchpad): español OK; tool calling OK ("márcale a mi hija" → llamarFamiliar); **guardrails bloquean "me caí y me duele"** → por eso emergencias sin IA. Usar `swiftc -parse-as-library`, no `swift script` (las macros @Generable fallan en modo intérprete).
- Investigación global en `docs/INVESTIGACION_GLOBAL.md` (datos para pitch y datos a NO usar).
- Documentos del equipo en `docs/equipo/` (ficha v1.2 y su investigación).

## Siguiente paso exacto
1. Pedir al usuario OK para el **commit inicial** + push a OyeMijo.
2. Bloque 0: modelos SwiftData, pantalla raíz (botón "Hablar con Mijo" + "Necesito ayuda"), datos de ejemplo. Reemplazar las 3 pestañas provisionales de `ContentView.swift`.

## Pendientes del usuario
- Bloque 1: agregar permisos de micrófono y reconocimiento de voz (Info del target en Xcode).
- Bloque 6: firma con Apple ID (Personal Team), Modo desarrollador en el iPhone.
- Que Arturo o Sebastian instalen la app **ntfy** para probar avisos.

## Cuidado con
- El `.xcodeproj` lo toca solo el usuario (excepto el deployment target, ya aprobado).
- Compilar fuera del Escritorio (el script ya usa DerivedData en ~/Library) por errores de firma.
- Xcode puede hacer `git add` solo; revisar `git status` antes de commitear.

## Archivos clave
- `CLAUDE.md`, `docs/PRD.md`, `docs/ROADMAP.md`, `docs/IDEAS.md`, `scripts/build.sh`
- `hackAthon/hackAthon/ContentView.swift`, `hackAthon/hackAthon/DesignSystem/Theme.swift`
