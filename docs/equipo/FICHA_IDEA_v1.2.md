# FICHA DE IDEA · Mijo

Versión 1.2 · 9 de noviembre de 2026
Problemática: "Adultos mayores: Independientes, conectados y seguros"

---

## Problema

Muchas personas mayores pasan la mayor parte del día solas. Nadie verifica que estén bien, que tomen sus medicinas ni que no las estén estafando, y cuando no saben hacer algo en su teléfono dependen de que alguien tenga tiempo de enseñarles. La tecnología que tienen en la mano, Siri incluida, solo responde cuando le hablan y hace las cosas por ellos en lugar de enseñarles.

## Usuario objetivo

- **Principal:** persona de 60 años o más, con iPhone 15 Pro o posterior (compatible con Apple Intelligence), que vive sola o pasa gran parte del día sola y se le facilita más hablar que escribir.
- **Secundario:** familiar o cuidador que vive en otro lado y quiere saber que su familiar está bien sin estar llamando a cada rato.
- **Sin familia cercana:** un contacto de confianza (vecino, amigo) y, en emergencia, el 911.
- **Persona para el pitch:** se define en la Fase 4.
- **Dispositivo de demo:** iPhone 17 Pro.

## Solución en una frase

**Mijo es un nieto virtual que vive dentro de Siri: te enseña a usar tu teléfono con paciencia, pregunta por ti, cuida que tomes tus medicinas, te protege de estafas y avisa a tu familia si algo no está bien.**

Frases de pitch:
- *"Siri te responde cuando le hablas. Mijo te cuida aunque no le hables."*
- *"Siri lo hace por ti. Mijo te enseña a hacerlo."*

## Funcionalidades core (MVP)

Mijo es un solo agente conversacional con capacidades. El agente es la plataforma y cada capacidad es una herramienta que el modelo puede usar.

0. **El agente Mijo, integrado a Siri.** "Oye Siri, dile a Mijo que…" con App Intents y App Shortcuts. Conversa por voz con Foundation Models y decide qué capacidad usar (tool calling). Llama o escribe a un familiar con un toque de confirmación.
1. **Enséñame (independencia).** "Mijo, ¿cómo le mando una foto a mi hija por WhatsApp?" Mijo identifica la tarea, la explica paso a paso con tarjetas grandes y voz pausada, repite las veces que haga falta y resuelve dudas. Los pasos salen de una biblioteca de guías escritas y verificadas por el equipo, no de lo que el modelo "se imagine". Si no tiene la guía, lo dice y ofrece pedir ayuda a la familia.
2. **Medicinas con verificación (independencia y seguridad).** Recordatorio, luego "¿ya se la tomó?". Registra la respuesta. Si no hay confirmación, la vista familiar lo marca.
3. **Escudo anti-fraude proactivo (seguridad).** En sus check-ins, Mijo pregunta: "¿Le llamó o le escribió alguien que no conoce? ¿Cómo le fue?". La persona cuenta lo que pasó. Mijo evalúa el riesgo con salida estructurada (nivel, señales de alerta, qué hacer), aconseja, ofrece llamar al familiar de verdad y avisa a la familia si el riesgo es alto.
4. **Auxilio (seguridad).** "Oye Siri, dile a Mijo que me siento mal." Pantalla de emergencia con botones gigantes (familiar o 911), Mijo lee en voz alta la dirección actual y avisa a la familia con la ubicación.

**Vista familiar (conectados):** la misma app en modo familiar. Muestra el resumen del día (medicinas, último check-in, alertas de fraude o auxilio) y marca cuando algo no se confirmó a tiempo. Es a donde llegan las capacidades 2, 3 y 4.

**Canal a la familia:** [ntfy](https://ntfy.sh), servicio de notificaciones gratuito y de código abierto. El teléfono del abuelo publica eventos con un HTTP POST y la vista familiar los lee. No requiere cuenta, servidor propio ni cuenta de desarrollador pagada. Respaldo si falla en la prueba: mensaje prellenado con un toque.

## Funcionalidades deseables (solo si sobra tiempo, en este orden)

1. **Detección de caídas** con Core Motion (acelerómetro y giroscopio), programada desde cero con un algoritmo de umbrales: caída libre, impacto, quietud. Mijo pregunta "¿Está bien?" y, si no hay respuesta en 30 segundos, avisa a la familia. Funciona con Mijo abierto o en un "modo paseo" donde Mijo comparte la ubicación con la familia (eso hace legítimo mantenerse activo en segundo plano y el teléfono va en el bolsillo, que es donde la detección funciona).
2. **"Te acompaño":** una Live Activity en la Dynamic Island y la pantalla bloqueada que muestra el paso actual de la guía mientras la persona está en WhatsApp, con botón "Siguiente".
3. Widget en pantalla de bloqueo o botón de Acción para hablar con Mijo.
4. Filtro de SMS de desconocidos con un clasificador entrenado en Create ML.
5. Juegos o ejercicios cognitivos.

## Visión a futuro (solo para el pitch, no se construye)

- Comunidad verificada de personas mayores y directorio de centros culturales.
- Credenciales (INAPAM, IMSS) en Apple Wallet.
- Mijo en Apple Watch con la detección de caídas nativa de Apple.
- Detección de caídas entrenada con Create ML (Activity Classifier) en lugar de umbrales.

## Componente de IA/ML y su justificación

| Pieza | Para qué | Por qué esta y no otra |
|---|---|---|
| **Foundation Models** (modelo de Apple en el dispositivo, permitido por los organizadores) | Entender el español coloquial, decidir qué capacidad usar (tool calling), elegir la guía correcta de "Enséñame" y explicarla con otras palabras, y evaluar el riesgo de fraude con salida estructurada (`@Generable`). | Las conversaciones sobre salud y dinero **nunca salen del teléfono**. No cuesta por uso, funciona sin internet, soporta español y se integra de forma nativa con App Intents. Un LLM en la nube costaría dinero, dependería de internet y mandaría datos sensibles a terceros. |
| **Guías verificadas como herramienta del modelo** | Que los pasos para enseñar sean correctos. | Un modelo de 3 mil millones de parámetros no conoce con precisión la interfaz actual de WhatsApp o de Ajustes. La IA entiende y explica, el contenido verificado garantiza que no invente pasos. Es la respuesta a "¿y si la IA se equivoca?". |
| **Speech** y **AVSpeechSynthesizer** | Escuchar y hablar. | Nativos, sin costo y en el dispositivo. |

## Limitantes (lo que Mijo NO hace)

- No llama ni manda mensajes sin un toque de confirmación (límite de iOS que además evita falsas alarmas).
- No ve ni toca la pantalla de otras apps: enseña con pasos, no controla WhatsApp por la persona.
- No puede ver la lista de apps instaladas (iOS no lo permite). Solo puede revisar apps específicas declaradas de antemano, como WhatsApp.
- No sabe automáticamente quién llamó. Por eso pregunta.
- No escucha en segundo plano. Se entra por Siri.
- Si se construye la detección de caídas: solo con Mijo abierto o en modo paseo, con el teléfono en el cuerpo. No es de grado médico.
- No es un dispositivo médico ni da diagnósticos.
- No sustituye el contacto humano. Su objetivo es acercar a la familia.

## Riesgos y mitigación

| Riesgo | Mitigación |
|---|---|
| El modelo en el dispositivo entiende mal el español coloquial. | Probarlo en la primera hora. Prompts con ejemplos mexicanos y respuestas cortas. |
| El modelo inventa pasos al enseñar. | Solo enseña desde guías verificadas. Sin guía, lo dice. |
| ntfy no entrega bien en iOS. | La vista familiar lee el tema directamente (no depende de push). Probar en la primera hora. Respaldo: mensaje prellenado. |
| La integración con Siri AI requiere iOS 27.3 beta. | App Shortcuts con frases, que funcionan en versiones estables. |
| La demo de voz falla en una sala ruidosa. | Video de respaldo y opción de escribir. |
| Privacidad: el tema de ntfy funciona como contraseña. | Nombre de tema aleatorio y largo. En producción: servidor propio o CloudKit. |
| Alcance contra 10 horas. | El roadmap define el recorte. Orden de sacrificio: deseables, luego Auxilio, luego la cantidad de guías. |

## Cambios de v1.1 a v1.2

1. **Nueva capacidad core "Enséñame"**, pedida por el equipo y respaldada por el dato de INEGI (56.1% de quienes no usan internet dicen que es porque no saben cómo).
2. **Foundation Models confirmado** por los organizadores.
3. **Canal a la familia decidido: ntfy** (gratis, código abierto, sin cuenta).
4. **Detección de caídas pasa de "fuera de alcance" a deseable #1**, programada desde cero con Core Motion y con límites claros.
5. **Dispositivo objetivo fijado:** iPhone 15 Pro o posterior. Demo en iPhone 17 Pro.

## Decisiones pendientes del equipo

1. Roles: quién hace qué (nombres y fortalezas).
2. Horario: cómo se reparten las ~10 horas hoy y mañana.
3. Entorno: versión de Xcode y de iOS en el iPhone 17 Pro (¿estable 27.2 o beta 27.3?).
