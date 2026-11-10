# ROADMAP · Mijo

Entrega: **martes 10 de noviembre, 15:00** en `HACKATHON-ENTREGABLES/Datisa/` (Codigo/ y Documentacion/ con Keynote).
Regla: al terminar cada bloque → compila (`./scripts/build.sh`), captura, explicación al equipo, commit.
Marca: [ ] pendiente · [x] hecho.

## Bloque 0 · Base (lunes 9, ~14:30–15:30)
- [x] Commit inicial (e843f52) y Bloque 0 (045f148)
- [x] Modelos SwiftData: `Familiar`, `Medicina`, `Toma`, `Comida`, `FichaMedica`, `Ajustes` (tema ntfy)
- [x] Pantalla raíz: un botón grande "Hablar con Mijo" + botón rojo "Necesito ayuda"
- [x] Datos de ejemplo realistas (doña Mari, su hijo Leo, Losartán 50 mg)
- **Listo cuando:** compila y se ve en el simulador

## Bloque 1 · Voz (lunes, ~15:30–17:30) — núcleo
- [x] Servicio de voz: hablar (AVSpeechSynthesizer es-MX) y escuchar (Speech, en el dispositivo) — compila; **sin probar con micrófono** (faltan los permisos)
- [x] Router de emergencia por palabras clave (por ahora contesta con frase fija + botón "Llamar a Leo"; el protocolo es el Bloque 4)
- [x] Agente: `LanguageModelSession` con instrucciones de "nieto" + herramientas `llamarFamiliar`, `crearRecordatorioMedicina`, `consultarMedicina`, `registrarComida` — **sin probar con la IA real**
- [ ] Herramientas `avisarFamilia` (va con ntfy, Bloque 3) y `decirDireccion` (va con CoreLocation, Bloque 4)
- [x] Manejo de `guardrailViolation` con frase fija
- [x] Pantallas "Mijo escuchando" y "Mijo le contesta" copiadas del diseño del equipo; botón de Inicio conectado
- [x] ⚙️ Usuario en Xcode: permisos de micrófono y reconocimiento de voz
- [x] Arreglos tras la 1.ª prueba de Leo: voz natural (sin voces "de efecto"), frases cortas ("Ok") sin IA, herramienta `marcarMedicinaTomada`, Mijo marca solo
- [x] Emergencia por voz: aviso automático por ntfy + llamada automática al familiar principal (adelanto de Bloques 3 y 4)
- **Listo cuando:** "Recuérdame la pastilla a las 9" crea el recordatorio y Mijo lo dice en voz

## Bloque 1b · Registro por voz (lunes, ~1 h, justo después del Bloque 1) — F6
- [ ] Mostrar el registro solo si no hay perfil (`Ajustes` vacío); quitar la carga automática de datos de ejemplo en el teléfono real
- [ ] Componente de paso: pregunta grande en serif + Mijo pequeño + micrófono + texto entendido + [Sí] [Otra vez]
- [ ] Paso nombre y paso persona de confianza (voz + selector de Contactos)
- [ ] Paso conectar a la familia: QR del tema de ntfy (CoreImage)
- [ ] Paso primera medicina por voz (Foundation Models `@Generable`) con respaldo de escribir
- [ ] Paso permisos ("Permitir todo") y pantalla "¡Listo!"
- **Listo cuando:** con la app recién instalada, se crea el perfil completo solo hablando y se llega a Inicio
- Diseño: pantallas A–H de "Oye Mijito – Pantallas", minimalista

## Bloque 2 · Notificaciones con voz y medicinas (lunes, ~17:30–19:30)
- [x] Pantalla "Sus pastillas de hoy" (diseño `Pastillas`): Tomada / Ahora / Sin confirmar / Después, "Ya me la tomé", "Escuchar". Se abre desde la pastilla de Inicio
- [x] Generar audio de la frase (voz de Mijo) en Library/Sounds y usarlo como sonido (probado en Mac: .caf 16 bits, 4.5 s)
- [x] Categorías con botones: [Sí] [Todavía no] / [Ya me la tomé] [Más tarde]
- [x] Respuestas registradas sin abrir la app; reintento a los 30 min · **sin probar en iPhone**
- [x] Demo: mantener presionado a Mijo en Inicio → pregunta de la pastilla en 5 s
- [ ] AlarmKit para medicinas críticas
- **Listo cuando:** en el simulador llega "¿Ya cenó, doña Mari?" con voz y el botón queda registrado

## Bloque 3 · Familia por ntfy (lunes, ~19:30–20:30)
- [x] `NtfyService`: POST con título, mensaje y prioridad (JSON; probado con ntfy.sh → 200) · falta ubicación
- [x] Eventos: caída, medicina sin confirmar, comida sin confirmar (los dos últimos se revisan con la app abierta: límite de iOS)
- [ ] Probar con la app ntfy en el teléfono de Arturo o Sebastian
- **Listo cuando:** el aviso llega a otro teléfono

## Bloque 4 · Caídas (lunes, ~20:30–22:00)
- [x] Protocolo fijo con voz y botones gigantes de respaldo: pantalla "¿Está bien?" (diseño `Ayuda`), cuenta de 30 s, escucha "estoy bien"/"no"/"ayuda", ntfy urgente + llamada automática, ficha médica. Botón Ayuda de Inicio y "me caí" por voz llegan aquí
- [ ] Rama "me duele": ntfy + pantalla de emergencia + dirección en voz (CoreLocation) + ficha médica
- [ ] Rama "no me duele": pasos para levantarse
- **Listo cuando:** el camino completo funciona sin tocar más de 2 veces

## Bloque 5 · Siri y configuración (martes 10, ~8:00–10:00)
- [ ] App Shortcuts: "Habla con Mijo", "Mijo, me caí", "Pregúntale a Mijo si ya me tomé la pastilla"
- [ ] Pantalla oculta de configuración (familia), grabar voz del familiar
- **Listo cuando:** "Oye Siri, habla con Mijo" abre Mijo escuchando en el iPhone

## Bloque 6 · iPhone real y pulido (martes, ~10:00–12:00)
- [ ] ⚙️ Usuario: firma con Apple ID, Modo desarrollador en el iPhone, instalar
- [ ] Probar todo en el iPhone 17 Pro (voz, llamadas, ntfy, Siri)
- [ ] Pulido visual: botones ≥ 70 pt, Dynamic Type, alto contraste, sin rasgos de plantilla
- [ ] Deseables si hay tiempo (orden del PRD)

## Bloque 7 · Entrega (martes, ~12:00–14:30)
- [ ] README, PRD actualizado con lo que realmente existe
- [ ] Keynote: título, propósito, necesidad, integrantes, tecnologías, repositorios
- [ ] Guion de pitch 5 min + 8 preguntas del jurado
- [ ] Video de respaldo de la demo
- [ ] Revisar secretos, `git status` limpio
- [ ] Entrega final: `./scripts/entregar.sh` (copia a `Datisa/Codigo` y `Datisa/Documentacion` y sube) **antes de las 14:30** · 1.ª copia subida el 9 nov

## Orden de sacrificio si hay retraso
1. Deseables → 2. AlarmKit → 3. Grabación de voz del familiar → 4. Rama "no me duele" detallada → 5. Herramientas extra del agente → 6. Pasos opcionales del registro por voz (QR de familia y primera medicina; nombre y persona de confianza se quedan).
**Nunca se sacrifica:** voz + agente, notificación con respuesta, medicinas, protocolo de caída, aviso por ntfy.

## Roles sugeridos
- **Claude:** código, compilación, explicación de cada archivo.
- **Leo:** decisiones, pruebas en el iPhone, pasos en Xcode.
- **Arturo y Sebastian:** pruebas de ntfy en sus teléfonos, Keynote, pitch, video de respaldo, preguntas del jurado.
