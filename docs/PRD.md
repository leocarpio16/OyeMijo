# PRD · Mijo

Versión 2.0 · 9 de noviembre de 2026 · Equipo Datisa
Tema del evento: "Adultos mayores: independientes, conectados y seguros"

> Estado de cada función: **Pendiente** · **En progreso** · **Hecha**. Solo se marca "Hecha" lo que compila y se probó.

---

## 1. Problema
Muchas personas mayores pasan el día solas. Si se caen, nadie se entera a tiempo. Si olvidan una medicina o no comen, nadie lo nota. Y la tecnología que tienen, Siri incluida, solo responde cuando le hablan.

Datos de apoyo (ver `docs/INVESTIGACION_GLOBAL.md`):
- Las caídas matan a ~842,000 personas al año; el 71% tiene 60+ (OMS 2026).
- 8 de cada 10 personas muy mayores que se cayeron no pudieron levantarse solas, y casi nunca usaron su alarma (BMJ 2008).
- La adherencia a tratamientos crónicos ronda el 50% (dato antiguo, usar con cautela).
- Solo 42.1% de las personas de 65+ en México usa internet; 56.1% de quienes no lo usan dice que no sabe cómo (INEGI).

## 2. Usuarios
- **Principal:** persona de 60+ con iPhone compatible con Apple Intelligence, que pasa mucho tiempo sola y prefiere hablar a escribir.
- **Secundario:** hijo o familiar que vive lejos y quiere saber que está bien sin llamar a cada rato. Es quien configura Mijo en una visita.

## 3. Solución en una frase
**Mijo es un nieto virtual en el iPhone: se lo pides con la voz y lo hace, te pregunta por ti aunque no le hables, cuida que comas y tomes tus medicinas, te acompaña si te caes y avisa a tu familia si algo no está bien.**

- *"Siri te responde cuando le hablas. Mijo te cuida aunque no le hables."*
- *"No reemplazamos a la familia: la acercamos."*

## 4. Funciones del MVP

### F0 · Agente por voz — Pendiente
- Entrada: "Oye Siri, habla con Mijo" (App Shortcut) o abrir la app. Mijo ya está escuchando; no hay que tocar nada.
- Escucha con Speech (es-MX, en el dispositivo), entiende y decide con **Foundation Models + herramientas** (tool calling), responde en voz con AVSpeechSynthesizer, en 1–2 frases cálidas.
- **Router antes de la IA:** si detecta emergencia ("me caí", "no me puedo levantar", "me siento mal", "ayuda") va directo a F3, sin IA. Motivo: los filtros de Foundation Models bloquean temas de lesiones y salud (probado el 9 nov), y una emergencia debe ser determinista.
- Herramientas: llamar/FaceTime a un familiar (con un toque de confirmación), crear recordatorio de medicina, consultar "¿ya me la tomé?", registrar comida, avisar a la familia, decir la dirección actual.
- Memoria personal: familiares (nombre, parentesco, teléfono), medicinas, ficha médica. Se inyecta en las instrucciones del modelo.
- Respaldo: si la voz falla, un botón grande y la opción de escribir.

### F1 · Mijo pregunta por ti (notificaciones con voz) — Pendiente
- Notificaciones locales a horas fijas: "¿Ya comió, doña Mari?", "¿Ya cenó?", "¿Ya tomó agua?".
- El sonido de la notificación **es la voz de Mijo** (frase convertida a audio en el teléfono) o una grabación del familiar.
- Responde **sin abrir la app** con botones en la notificación: [Sí] [Todavía no].
- "Todavía no" → vuelve a preguntar en 30 min. Sin respuesta → aviso a la familia (F4).

### F2 · Medicinas con verificación — Pendiente
- La familia da de alta medicina, dosis, horarios y foto de la pastilla.
- Recordatorio con voz y botones [Ya me la tomé] [Más tarde]. Medicinas críticas con **AlarmKit** (suena aunque el teléfono esté en silencio).
- Registro por día: tomada / pospuesta / sin confirmar.
- "Oye Siri, pregúntale a Mijo si ya me tomé la pastilla" → responde en voz.
- Sin confirmación en X minutos → aviso a la familia (F4).

### F3 · Caídas: "Mijo, me caí" — Pendiente
- Entrada: voz (Siri o dentro de la app) o botón rojo "Necesito ayuda".
- **Protocolo fijo, sin IA:**
  1. "Aquí estoy. No se levante todavía. ¿Le duele algo?" (escucha "sí"/"no"; botones grandes de respaldo).
  2. **Sí le duele** → avisa a la familia por ntfy con ubicación, pantalla de emergencia con botones gigantes (familiar / 911), Mijo **lee en voz alta la dirección** y muestra la **ficha médica**.
  3. **No le duele** → guía para levantarse con seguridad, un paso a la vez ("Gire de lado… ¿listo?"). Al final: "¿Quiere que le avise a Leo?".
- Llamar siempre requiere un toque (límite de iOS; evita falsas alarmas).

### F4 · Avisos a la familia (ntfy) — Pendiente
- El teléfono publica eventos con un HTTP POST a ntfy.sh (servicio público, gratuito, sin cuenta): caída, medicina sin confirmar, comida sin confirmar.
- El familiar instala la app **ntfy** y se suscribe al tema de Mijo: recibe la alerta en su teléfono.
- Tema aleatorio y largo (funciona como contraseña). Respaldo si falla: mensaje prellenado con un toque.

### F5 · Configuración por la familia — Pendiente
- Pantalla oculta (mantener presionado). La familia registra familiares, medicinas, horarios de comidas, ficha médica, tema de ntfy y graba su voz.
- La persona mayor nunca ve ajustes.

## 5. Deseables (solo si sobra tiempo, en este orden)
1. Widget de pantalla de bloqueo / botón de Acción: "Hablar con Mijo".
2. Detección de caídas con Core Motion (caída libre + impacto + quietud) con Mijo abierto. No es de grado médico.
3. Aviso de calor con Open-Meteo (API pública gratuita, sin clave).
4. Frases variadas generadas por la IA para las notificaciones.

## 6. Fuera de alcance
- Escudo anti-fraude (la app no puede acceder a la llamada en curso).
- Guías largas paso a paso ("Enséñame"): agobian; el agente hace la tarea y deja una pista corta.
- Check-in de "señal de vida" como función propia.
- Clasificadores con Create ML.

## 7. Restricciones técnicas
- iOS 26.0+, iPhone 17 Pro (iOS 26.1) para la demo, Xcode 26.6.
- Sin cuenta de Apple Developer de pago: sin push propio ni CloudKit; instalación de 7 días.
- Solo frameworks de Apple + APIs públicas gratuitas (ntfy, Open-Meteo).
- iOS no permite llamar ni mandar mensajes sin un toque, ni controlar otras apps.
- Foundation Models: bloquea temas de lesiones/salud → emergencias sin IA.

## 8. Frameworks
SwiftUI · SwiftData · FoundationModels · Speech · AVFoundation (AVSpeechSynthesizer, AVAudioRecorder) · App Intents · UserNotifications · AlarmKit · CoreLocation · CoreMotion (deseable) · WidgetKit (deseable) · URLSession (ntfy).

## 9. Demo (camino feliz, ~2:30 min)
1. Notificación con voz: "¿Ya cenó, doña Mari?" → [Todavía no].
2. "Oye Siri, habla con Mijo" → "Recuérdame la pastilla de la presión a las 9" → Mijo la agenda y lo confirma en voz.
3. Llega el recordatorio → [Ya me la tomé] → "¿Ya me la tomé?" → "Sí, a las 9:02".
4. "Mijo, me caí" → protocolo → "Sí me duele" → al teléfono del compañero le llega la alerta de ntfy con la ubicación.

## 10. Riesgos
| Riesgo | Mitigación |
|---|---|
| El modelo entiende mal el español coloquial | Instrucciones con ejemplos mexicanos; probar en la primera hora; botón y texto de respaldo |
| Filtros de Foundation Models | Router previo; capturar `guardrailViolation` y responder con frase fija |
| ntfy no entrega en la sala | Probar temprano; respaldo con mensaje prellenado |
| Voz falla con ruido en la demo | Video de respaldo grabado antes |
| App Groups/widgets con cuenta gratis | Widgets son deseables; el núcleo no depende de ellos |
