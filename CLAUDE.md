# Hackathon iOS — contexto para Claude

## Proyecto
- App iOS en Swift + SwiftUI, equipo de 3. Claude programa; el equipo diseña, revisa y presenta.
- Equipo: Sebastian Gonzalo Mera Montiel, Arturo Jaramillo Salmeron, Leo Yahir Carpio Angeles.
- Tema del evento: "Adultos mayores: independientes, conectados y seguros" (autonomía, comunicación, seguridad y calidad de vida).
- Idea: **Mijo**, nieto virtual por voz (agente con Foundation Models) para caídas, medicinas, comidas y avisos a la familia por ntfy. Fuente de verdad: `docs/PRD.md`; plan: `docs/ROADMAP.md`.
- **Al iniciar un chat nuevo:** lee `docs/HANDOFF.md` (skill `continuar-sesion`). Al cerrar un bloque o si el chat es largo, actualízalo.
- Repo: github.com/leocarpio16/OyeMijo (privado, solo por invitación).
- Documentación de entrega: archivo **Keynote** con título, propósito, necesidad que resuelve, integrantes, tecnologías y repositorios necesarios.
- Entrega: GitHub (código + docs) a las **15:00** del 2026-11-10. Pitch 5 min + 3 min de preguntas.
- El usuario tiene Swift básico y viene de Python: explica cada cambio en español sencillo (skill explain-my-code).

## Estructura
```
hackathon-ios/
├── CLAUDE.md
├── .claude/skills/        skills del proyecto
├── hackAthon/
│   ├── hackAthon.xcodeproj
│   └── hackAthon/         código de la app (.swift, Assets)
│       └── DesignSystem/  colores, espaciado, tipografía (cuando exista)
├── docs/                  PRD, PITCH, QA_JURADO, CHECKLIST_ENTREGA
└── scripts/build.sh
```
El proyecto usa carpetas sincronizadas: un .swift nuevo dentro de `hackAthon/hackAthon/` entra al target sin tocar el .xcodeproj.

## Comandos
- Compilar y correr: `./scripts/build.sh`
- Solo compilar: `./scripts/build.sh --solo-build`
- Compilar, correr y capturar: `./scripts/build.sh --captura` → `build/captura.png`
- La terminal apunta a Command Line Tools: siempre `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` (el script ya lo hace).

## Reglas de código
- iOS 26.0+ (decisión del equipo, 9 nov): se pueden usar Foundation Models, AlarmKit y demás APIs de iOS 26. SwiftUI, `@Observable`.
- Dispositivo de demo: iPhone 17 Pro. Las emergencias (caída, "me siento mal") van por ruta fija sin IA: los filtros de Foundation Models bloquean temas de lesiones/salud.
- Sin dependencias externas (ni SPM ni CocoaPods).
- Cambios pequeños, un archivo a la vez; compilar después de cada cambio.
- Colores, espaciado y tipografía solo desde DesignSystem/.
- Datos de ejemplo realistas y en español; nada de "John Doe" ni "Lorem ipsum".
- No reescribir código que el equipo haya escrito a mano sin preguntar.

## Reglas del evento
- Solo frameworks de Apple y APIs públicas gratuitas.
- Nada de Vision Pro ni Create ML / Co-ML.
- Ningún secreto (API keys, tokens) en el repo.

## Límites
- No cambiar el .xcodeproj, Deployment Target ni firma sin preguntar.
- No instalar dependencias. No borrar archivos.
- No hacer commit ni push sin que el usuario lo pida.
- Documentar solo lo que existe; lo demás va como "siguiente paso".
