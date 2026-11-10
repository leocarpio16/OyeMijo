# Mijo · Lo que hicimos (base para la documentación)

Equipo Datisa: Sebastian Gonzalo Mera Montiel, Arturo Jaramillo Salmeron, Leo Yahir Carpio Angeles.
Tema del evento: "Adultos mayores: independientes, conectados y seguros".
Repositorio: github.com/leocarpio16/OyeMijo (privado, por invitación).
Estado al martes 10 nov, 13:00. Último commit: `496c17f`.

> Regla: aquí solo va lo que **existe en el código**. Al lado de cada función dice si ya se probó en el iPhone.
> ✅ probado en iPhone · 🖥️ probado solo en simulador/Mac · ⏳ sin probar todavía

---

## 1. Qué es Mijo (en una frase)
Un nieto virtual en el iPhone: se le pide con la voz y lo hace, pregunta por la persona aunque no le hable, cuida sus pastillas, la acompaña si se cae y avisa a su familia.

- *"Siri te responde cuando le hablas. Mijo te cuida aunque no le hables."*
- *"No reemplazamos a la familia: la acercamos."*

## 2. Necesidad que resuelve
- Muchas personas mayores pasan el día solas: si se caen, nadie se entera a tiempo.
- 8 de cada 10 personas muy mayores que se cayeron no pudieron levantarse solas y casi nunca usaron su alarma (BMJ 2008).
- Las caídas matan a ~842,000 personas al año; el 71 % tiene 60+ (OMS).
- Solo 42.1 % de las personas de 65+ en México usa internet; 56.1 % de quienes no lo usan dice que no sabe cómo (INEGI). Por eso Mijo se usa **hablando**, no tocando menús.

## 3. Funciones que existen

### 3.1 Caída: "Mijo, me caí" (la función principal de la demo)
Entra por voz ("me caí", "no me puedo levantar"…), por el botón rojo **Ayuda** de Inicio o por Siri. **No usa IA**: es un protocolo fijo para que responda siempre igual.

1. **"Doña Mari, ¿le duele algo?"** en voz y en pantalla, con una cuenta de **30 s**. Contesta con la voz o con botones gigantes.
2. **"No me duele"** →
   - aviso a la familia por ntfy (prioridad alta) con la **dirección** y botón **"Ver en el mapa"** (Google Maps, abre en Android y iPhone),
   - **6 pasos para levantarse**, uno por pantalla, leídos en voz. Cada paso espera "ya" (o 15 s). Botones ← repetir 🔊 y **Siguiente**,
   - etiqueta "Su familia ya sabe" en cuanto llega el aviso,
   - **"Ya me levanté"** → pantalla **"¡Muy bien!"** y un **segundo aviso** a la familia: "ya se levantó, dice que está bien",
   - "No puedo levantarme" (o 1 min callada al final) → aviso urgente.
3. **"Sí, me duele"**, o no contesta en 30 s → aviso **urgente** con dirección y mapa, Mijo **le dice en voz dónde está** ("Usted está en…", por si tiene que dársela al 911), **abre la llamada** al familiar y muestra la **ficha médica** para quien llegue a ayudar.
4. **911 siempre visible** arriba a la derecha.

Diseño: ilustración grande sobre una mancha suave con hojas, texto grande a la izquierda, avance por puntos, botones grandes abajo. Rosa = alerta, ámbar = calma, rojo solo para ayuda.
Estado: versión anterior ✅ en iPhone · rediseño, segundo aviso y mapa de Google 🖥️.

### 3.2 Avisos a la familia (ntfy)
- Mijo manda el aviso con un POST a **ntfy.sh** (servicio público y gratuito, sin cuenta). El familiar instala **ntfy** (Android o iPhone) y se suscribe al tema de Mijo.
- Eventos: caída (con y sin dolor), "ya se levantó", "no se puede levantar", pastilla o comida sin confirmar, y avisos por voz ("avísale a mi familia que ya llegué").
- El tema es aleatorio y largo: funciona como contraseña.
Estado: el primer aviso del registro llegó a otro teléfono ✅.

### 3.3 Modo familia dentro de Mijo (nuevo)
- En la Bienvenida, **"Soy familiar"** → se escribe el código de Mijo (el tema) → ese teléfono se vuelve el del nieto.
- Pantalla **"Avisos de Mijo"**: el aviso más nuevo en grande (rosa "Urgente" si no se levanta), **"Ver en el mapa"**, y la lista de avisos anteriores ("ya se levantó" con palomita verde). Cada aviso nuevo llega con notificación y sonido.
- **Límite:** solo funciona en iPhone y con la app abierta. Con la app cerrada se necesitaría un servidor de notificaciones de Apple; por eso se mantiene ntfy como respaldo.
Estado: 🖥️ (avisos reales de ntfy recibidos en el simulador).

### 3.4 Pídeselo con la voz (agente)
Mijo escucha (Speech, en el teléfono), entiende y lo hace:

| Le dices | Mijo hace |
|---|---|
| "Recuérdame la pastilla de la presión a las 9 de la noche" | Guarda el recordatorio y lo confirma. Si no dice mañana/noche, pregunta |
| "¿Ya me tomé la pastilla?" | Dice si ya está anotada; si no, pregunta "¿Ya se la tomó?" |
| "Ya me la tomé" | La anota |
| "Dile a Pedro que ya comí" / "mándale un WhatsApp a…" | Busca a la persona (familiares de Mijo y **contactos del teléfono**) y abre WhatsApp con el mensaje escrito: falta 1 toque en Enviar |
| "Avísale a mi familia que ya llegué" | Manda el aviso por ntfy sin tocar nada |
| "Llama a mi hija" | Abre la llamada (iOS pide 1 toque) |
| "Ábreme YouTube / Netflix / WhatsApp…" | Abre la app y dice una pista corta ("Toque el video que quiera ver") |
| "Ponme canciones de Pedro Infante" | Abre YouTube con la búsqueda |
| "¿Dónde estoy?" | Dice la dirección |
| "Ya comí" / "todavía no ceno" | Lo anota |
| Plática libre ("¿cómo estás?") | Contesta la IA (Foundation Models), en 1–2 frases |

**Cómo decide (importante para el jurado):**
1. **Emergencias primero, sin IA** (`EmergencyRouter`): los filtros de Foundation Models bloquean temas de lesiones y salud, y una emergencia tiene que ser determinista.
2. **Peticiones comunes por palabras clave, sin IA** (`ComandosDeVoz`): en las pruebas del iPhone, la IA con 10 herramientas las confundía (abría WhatsApp al pedir YouTube) y se quedaba pensando. Ahora responden al momento y siempre igual.
3. **La IA solo para platicar**, con 3 herramientas (llamar, crear recordatorio, consultar pastillas) y un límite de 12 s.
Estado: abrir WhatsApp y YouTube ✅ · comandos sin IA y contactos ⏳.

### 3.5 Mijo pregunta por ti (notificaciones con voz)
- Notificaciones a horas fijas: pastillas y comidas ("¿Ya cenó, doña Mari?").
- El **sonido de la notificación es la voz de Mijo**: la frase se convierte en audio en el teléfono.
- Se responde **sin abrir la app**, con botones: [Ya me la tomé] [Más tarde] / [Sí] [Todavía no]. "Más tarde" vuelve a preguntar en 30 min.
- Pastilla o comida sin confirmar → aviso a la familia (se revisa con la app abierta: límite de iOS).
- Demo: mantener presionado a Mijo en Inicio → la pregunta llega en 5 s.
Estado: ⏳ en iPhone (el audio se probó en la Mac).

### 3.6 Sus pastillas de hoy
Pantalla con cada toma: Tomada / Ahora / Sin confirmar / Después, botón "Ya me la tomé" y "Escuchar". Si no tiene pastillas: "Agregar mis pastillas".

### 3.7 Registro por voz (primera vez)
Sin cuentas ni contraseñas: el perfil vive en el teléfono.
1. "¿Cómo le gusta que le diga?" (voz o teclado).
2. Persona de confianza desde Contactos.
3. Conectar a la familia: **código QR** del tema de ntfy + el tema escrito; manda un primer aviso.
4. Permisos: micrófono, avisos y ubicación con "Permitir todo".
5. "¡Listo, Doña Mari!" → Inicio.
Estado: ✅ en iPhone.

### 3.8 Siri (App Shortcuts)
"Oye Siri, habla con Mijo", "Oye Siri, Mijo, me caí", "Oye Siri, pregúntale a Mijo si ya me tomé la pastilla".
Estado: ❌ Siri entiende "mi hijo" en vez de "Mijo". **Solución para la demo:** atajo personal en la app Atajos con el nombre "Oye mi hijo".

## 4. Diseño
- Basado en "Oye Mijito – Pantallas" del equipo: fondo crema, panel ámbar con Mijo, texto café, pastillas blancas, rojo solo para emergencias.
- Letra **DM Sans** (licencia OFL, incluida en el repo).
- Texto grande (20–40 pt), crece con Dynamic Type hasta XXXL, contraste ≥ 4.5:1, siempre modo claro, vibración en botones y alertas.
- La pantalla de caída se inspiró en plantillas de onboarding (ilustración grande, texto a la izquierda, botones redondos), con los colores del equipo.

## 5. Tecnologías (solo Apple + APIs públicas gratuitas)
| Tecnología | Para qué |
|---|---|
| Swift + SwiftUI | Toda la app (iOS 26) |
| SwiftData | Perfil, familiares, pastillas, tomas, comidas, ficha médica (todo en el teléfono) |
| Foundation Models | IA dentro del iPhone, sin internet, para platicar y algunas herramientas |
| Speech | Escuchar en español de México, en el dispositivo |
| AVFoundation | Voz de Mijo (AVSpeechSynthesizer) y audio de las notificaciones |
| App Intents | Atajos de Siri |
| UserNotifications | Preguntas con botones y voz; avisos del modo familia |
| CoreLocation + MapKit | Ubicación y dirección en una caída |
| Contacts / ContactsUI | Elegir a la persona de confianza; buscar a quién llamar o escribir |
| CoreImage | Código QR para conectar a la familia |
| URLSession + **ntfy.sh** | Avisos a la familia (API pública gratuita, sin clave) |

Sin dependencias externas (ni SPM ni CocoaPods). Ningún secreto en el repo.

## 6. Arquitectura (para explicar el código)
```
Voz → EmergencyRouter ──(emergencia)──▶ HelpModel/HelpView (protocolo fijo, sin IA)
          │
          ▼
     ComandosDeVoz ──(petición conocida)──▶ MijoActions (hace el trabajo)
          │
          ▼
     MijoAgent (Foundation Models, 3 herramientas) ──▶ MijoActions
                                                         │
                                  NtfyService ◀──────────┘ (avisos)
                                       │
                        app ntfy / FamilyView (teléfono del familiar)
```
Carpetas de `hackAthon/hackAthon/`: `Conversation/` (escuchar y contestar), `Help/` (caída), `Family/` (modo familia), `Pills/`, `Onboarding/`, `Intents/` (Siri), `Services/` (voz, agente, comandos, ntfy, ubicación, contactos, notificaciones), `Models/` (SwiftData), `DesignSystem/` (colores, letra, componentes).

## 7. Límites honestos (por si pregunta el jurado)
- **Llamar y mandar WhatsApp siempre piden 1 toque**: iOS no deja que una app lo haga sola. El aviso por ntfy sí sale solo.
- **No detecta caídas solo**: la persona lo dice o toca Ayuda. La detección con sensores es siguiente paso.
- Sin cuenta de Apple Developer de pago: sin servidor de notificaciones propio, por eso ntfy; la app instalada dura 7 días.
- Foundation Models necesita un iPhone con Apple Intelligence.
- Revisar pastillas o comidas sin confirmar solo funciona con la app abierta.
- Los pasos para levantarse son orientativos, no consejo médico.

## 8. Siguientes pasos (no existen todavía)
1. Modo familia con la app cerrada (servidor de notificaciones).
2. Configuración por la familia: pantalla para pastillas, horarios, ficha médica y familiares.
3. Detección automática de caídas con sensores (Core Motion / Apple Watch).
4. AlarmKit para pastillas críticas (suena aunque esté en silencio).
5. La voz de un familiar grabada en los recordatorios.
6. Nombre alternativo para Siri ("Mi hijo").

## 9. Guion de demo sugerido (caída primero)
1. **Caída (2 min):** "Mijo, me caí" → "No me duele" → al teléfono del familiar le llega el aviso con mapa → 2 pasos con "ya" → "Ya me levanté" → llega "ya se levantó". Luego, rápido, la rama "Sí, me duele": aviso urgente, dirección en voz y llamada.
2. **Pastillas (40 s):** "Recuérdame la pastilla de la presión a las 9 de la noche" → "¿Ya me tomé la pastilla?".
3. **Mijo hace cosas (40 s):** "Dile a [contacto] que ya comí" (WhatsApp listo) → "Ponme canciones de Pedro Infante" (YouTube).

## 10. Historial de trabajo (commits)
| Commit | Cuándo | Qué |
|---|---|---|
| e843f52 | 9 nov 15:01 | Proyecto base, PRD, ROADMAP e investigación |
| 045f148 | 9 nov 17:10 | Modelos SwiftData, datos de ejemplo e Inicio |
| 149c2af | 9 nov 17:46 | Voz, agente y emergencias |
| 18e8d05 | 9 nov 19:08 | "¿Está bien?" y "Sus pastillas de hoy" |
| 4f363fb | 9 nov 19:26 | Notificaciones con la voz de Mijo |
| 239b9ac | 9 nov 19:46 | Registro por voz |
| cf78c4b | 9 nov 20:03 | Atajos de Siri |
| 88687ba | 9 nov 20:22 | Pulido: modo claro, silencio, transiciones, vibración |
| 1749c1e | 9 nov 20:31 | WhatsApp con el mensaje listo |
| e417445 | 9 nov 20:33 | Aviso a toda la familia por ntfy |
| 6823c33 | 9 nov 20:49 | Abrir apps y buscar en YouTube |
| 9dc5eec | 10 nov 10:52 | Caída completa con ubicación, DM Sans, tarjetas |
| f8cc2f6 | 10 nov 12:52 | Comandos de voz sin IA, caída rediseñada, contactos |
| 496c17f | 10 nov 12:57 | Modo familia |

## 11. Para el Keynote (lo que pide la entrega)
- **Título:** Mijo, tu nieto en el teléfono.
- **Propósito:** que las personas mayores vivan solas con más seguridad y su familia se entere a tiempo.
- **Necesidad:** sección 2.
- **Integrantes:** Sebastian Gonzalo Mera Montiel, Arturo Jaramillo Salmeron, Leo Yahir Carpio Angeles.
- **Tecnologías:** sección 5.
- **Repositorios:** github.com/leocarpio16/OyeMijo (app iOS, documentación en `docs/`).
