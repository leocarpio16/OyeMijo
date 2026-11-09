# Banco de ideas — Oye Mijo

Registro de todo lo explorado, para el recuento final. Nada aquí está decidido.
Leyenda: 🟢 se hace en horas · 🟡 medio día · 🔴 arriesgado o no viable hoy.

## Restricciones conocidas
- Tenemos iPhone; **no** tenemos cuenta de Apple Developer de pago. Sin CloudKit ni push entre teléfonos: todo debe funcionar **en un solo teléfono, sin servidor**.
- iOS no deja enviar SMS ni llamar sin que la persona toque "Enviar"/"Llamar".
- Con cuenta gratuita la app se instala en el iPhone por 7 días (suficiente para la demo).
- ⚠️ Por verificar: si la cuenta gratuita permite **App Groups** (necesario para que widget y app compartan datos).

## Concepto
- **Oye Mijo = el nieto paciente que siempre está.** Cada función responde a algo que un abuelo le pediría a su nieto.
- Formato: **widgets + voz (Siri / App Intents)**, mínima interacción, letra y botones grandes, sin internet.
- Frase de pitch: *"No todos tienen un nieto cerca cuando lo necesitan. Oye Mijo sí está."*

## Ideas por pilar (sesión 1)
### Independientes
- 💊 "¿Ya me tomé la pastilla?" — widget con botón "Ya me la tomé", recordatorios con voz 🟢
- 📖 "¿Qué dice aquí?" — foto → leer en voz alta y explicar sencillo (Vision OCR) 🟡
- 📱 "¿Cómo le hago para…?" — guías paso a paso por voz; IA de Apple en el teléfono opcional 🟡🔴
- 🚶 Rutina de movimiento suave guiada por voz 🟢
### Conectados
- 📞 "Márcale a…" — fotos grandes de la familia, un toque para llamar 🟢
- 🎙️ "Cuéntame tu historia" — grabar anécdotas guiadas, transcribir, compartir 🟡
- 🖼️ Fotos con voz (quién es quién) 🟢
### Seguros
- 🛡️ "¿Esto es fraude?" — semáforo con reglas de modalidades reales (pensionazo, falso nieto, banco/NIP, premio) 🟡
- 🚨 Botón de ayuda → SMS con ubicación (requiere tocar "Enviar") 🟢
- ✅ "Estoy bien" diario 🟢 (sin servidor no puede avisar solo a la familia)
- 🩺 Ficha médica de emergencia 🟢
- 🔴 Detector de caídas con acelerómetro — no confiable, no para demo

## Respuesta a "¿y si se cae y no alcanza el teléfono?" (sesión 2)
1. Voz: "Oye Siri, ayuda con Oye Mijo" funciona con el teléfono bloqueado 🟢
2. Guiar la activación de **Emergencia SOS** y **Check In** de Mensajes (iOS ya avisan solos a la familia) 🟢
3. Señal de vida diaria que avise a la familia — requiere CloudKit (cuenta de pago) → solo demo simulada 🟡
4. Apple Watch (detección de caídas) como "siguiente paso" 🔴

## Enfoque en SOLEDAD (sesión 3)
Ver la sección en el chat del 9 nov; resumen:
- 🌅 Buenos días con voz de la familia (grabados en una visita, suenan cada mañana) 🟢
- 🖼️ Widget "portarretratos vivo": foto de un familiar distinto cada día + botón llamar 🟢
- ⏳ "Hace 9 días que no hablas con Arturo" — contador de último contacto 🟢
- 💌 "Mándale un abrazo" — 1 toque abre WhatsApp/Mensajes con mensaje listo 🟢
- ❓ Pregunta del día ("¿Cómo conociste a mi abuelo?") → grabar respuesta → compartir a la familia 🟡
- 👨‍👩‍👧 Modo familia en el teléfono del nieto: recordatorio local "Llama a la abuela" 🟢
- 📍 "¿Qué hay cerca para mí?" — MapKit: parroquias, parques, centros comunitarios, bibliotecas 🟡
- 📊 Termómetro de soledad: 3 preguntas semanales (escala UCLA-3) por voz → tendencia 🟢
- 🎂 Cumpleaños de la familia → "Hoy cumple Sofía, ¿le llamas?" 🟢
- 🤖 Plática con Oye Mijo (IA de Apple en el teléfono) como puente, no sustituto 🔴 (requiere iPhone 15 Pro o más nuevo)

---

## Lluvia de ideas masiva (sesión 4, basada en la investigación global)
Cada idea dice en qué evidencia se apoya. [RCT] = ensayo/metaanálisis · [Obs] = observacional · [Prog] = programa real sin evaluación rigurosa.

### A. Señal de vida y "nadie se entera" (Japón: 21,856 halladas 8+ días después; 80% de caídos no se levanta solo)
1. ☀️ **"¿Cómo amaneció?"** — widget de 1 toque o voz cada mañana; si no responde a cierta hora, recordatorio insistente y luego pantalla "Avisar a mi hijo" con mensaje listo. [Prog: Snug Safety, "Are You Dead?" China] 🟢
2. ☕ **Señal pasiva tipo i-pot** — la señal se da sola con algo que ya hace: desbloquear el teléfono, contestar un recordatorio de medicina, abrir el widget. "Hoy ya diste señal 3 veces". [Prog: Zojirushi i-pot Japón] 🟡
3. 📮 **"Correo sin recoger" digital** — si pasan X horas sin ninguna interacción, la próxima vez que abra pide confirmar que está bien y ofrece avisar. (Sin servidor no avisa sola: se dice con honestidad) 🟢
4. 🆘 **Asistente de Emergencia SOS y Check In** — guía en 3 pasos para activar lo que iOS ya trae y SÍ avisa solo. [Apple] 🟢
5. 🗣️ **"Oye Siri, me caí, Oye Mijo"** — App Shortcut que funciona bloqueado; llama al contacto de confianza. 🟢
6. 🏷️ **Ficha "Si me encuentran"** — datos médicos y contactos visibles en la pantalla de bloqueo (widget). 🟢

### B. Conexión real (lo que SÍ funciona: llamadas empáticas RCT −1.1 UCLA; video > teléfono; individual > grupal; reencuadre cognitivo es lo más fuerte)
7. 📞 **"Llamadas del domingo" (modelo Sunshine Calls)** — en el teléfono del nieto/voluntario: recordatorio + guion corto de llamada empática ("pregúntale por…"). [RCT Kahlon 2021] 🟢
8. 🎥 **FaceTime de un toque desde la foto** — video tiene mejor efecto que solo voz. [MA Fu 2022: −0.54 video] 🟢
9. 🖼️ **Portarretratos vivo** (widget) — foto del día + llamar. 🟢
10. 🌅 **Buenos días con voz de la familia** — grabaciones reales que suenan cada mañana. 🟢
11. ⏳ **"Hace 9 días que no hablas con Arturo"** — contador cariñoso. 🟢
12. 💌 **"Mándale un abrazo"** — 1 toque abre WhatsApp/Mensajes con texto listo. 🟢
13. 🧠 **"Pensamientos que pesan"** — micro-ejercicios de reencuadre por voz: cuando dice "nadie me llama", Oye Mijo responde con evidencia ("Lupita te llamó el martes") y sugiere acción. [MA Masi 2011 / Fu 2022: lo que más funciona] 🟡
14. 🎙️ **Pregunta del día / libro de recuerdos** — reminiscencia + rol con propósito (contar historias). [Obs] 🟡
15. 👵 **"Enséñale a tu nieto"** — recetas, dichos, oficios grabados por voz para la familia: rol de quien enseña, no de quien recibe ayuda. 🟡
16. 📍 **¿Qué hay cerca para mí?** — MapKit: parroquias, parques, centros comunitarios, bibliotecas (sin rutas con cuenta gratis: abrir Mapas). 🟡
17. 🎂 **Fechas que importan** — "Hoy cumple Sofía, ¿le llamas?". 🟢
18. 📊 **Termómetro de soledad UCLA-3** mensual por voz, con gráfica antes/después. [UCLA-3 validada en español] 🟢

### C. Anti-fraude (soledad = mejor predictor de caer; lo que funciona es intervenir en el momento, como el cajero del banco UK; campañas genéricas NO funcionan)
19. 🛑 **"Antes de pagar, pregúntale a Oye Mijo"** — botón/voz: "me están pidiendo dinero". La app hace 3 preguntas (¿urgencia? ¿secreto? ¿piden transferencia/tarjeta?) → semáforo y "Llama primero a tu hija" con un toque. [Prog: UK Banking Protocol] 🟡
20. 🔑 **Palabra secreta familiar** — se guarda en la app; si "tu nieto" llama pidiendo dinero, Oye Mijo recuerda: "Pídele la palabra secreta". Defensa contra voz clonada (3 s de audio bastan). [Prog: Starling Bank] 🟢
21. 📋 **Catálogo de estafas reales con voz** — pensionazo, falso nieto, falso banco/NIP, premio, falso policía; cada una con "cómo suena" y "qué hacer". 🟢
22. 📱 **Revisar un SMS/WhatsApp sospechoso** — pegar o compartir el texto a la app (Share Extension) → reglas detectan urgencia, links, montos, "no le digas a nadie". 🟡
23. 🔇 **Asistente para activar "Silenciar desconocidos"/Filtrado de llamadas** — guía a funciones de iOS. 🟢
24. ⚠️ **Sin acceso familiar a cuentas** — principio de diseño: la familia recibe avisos, nunca dinero ni contraseñas (los agresores a menudo están en casa — Condusef). 🟢

### D. Independencia y salud (adherencia ~50%; polifarmacia 37–40%; apps solas tienen evidencia mixta → combinar)
25. 💊 **Widget "Ya me la tomé"** + recordatorio con voz de un familiar ("Mamá, tu pastilla de la presión"). 🟢
26. 📷 **Foto de cada pastilla** — para no confundirlas (problemas de vista). 🟢
27. 🔊 **¿Qué dice aquí?** — Vision OCR + lectura en voz alta de cajas, recibos, cartas. 🟡
28. 🌡️ **Alerta de calor** — WeatherKit requiere cuenta de pago ❌ → alternativa: recordatorio de agua y frescura en temporada de calor con consejos (73% de muertes por calor en México 2023 fueron 65+). 🟢
29. 🚶 **Movimiento suave guiado** — prevención de caídas (ejercicio de equilibrio es la intervención con más evidencia). 🟢
30. 👂 **Todo con texto grande + vibración + voz** — >25% de 60+ con pérdida auditiva. Principio de diseño. 🟢

### E. Diseño (botones ≥13 mm ≈ 60–80 pt; voz falla 1 de cada 4 veces; Assistive Access no evaluado en mayores)
31. Una sola acción principal por pantalla; botones de 70 pt.
32. Voz siempre con botón de respaldo y confirmación hablada ("Le estoy llamando a Lupita").
33. Configuración la hace la familia en una visita ("modo configurar"); el adulto mayor nunca ve ajustes.
34. Sin cuentas, sin internet, sin contraseñas.
35. Tono de nieto: "usted"/"tú" configurable, frases cortas, nada de jerga.

### F. Para el pitch
- Hueco real: **México no tiene un programa nacional de acompañamiento telefónico** (no se encontró en INAPAM) — Oye Mijo lo pone en el bolsillo de la familia.
- Mensaje: "No reemplazamos a la familia: la acercamos."

---

## Sesión 5 — Decisiones del equipo y diferenciación con Siri
- ❌ **Se descarta el bloque de fraude (C)**: la app no puede acceder a la llamada en curso.
- 🎯 **Target**: personas con poder adquisitivo que tienen iPhone (y probablemente hijos ocupados o lejos que pagarían por tranquilidad).
- ✅ **Foco**: caídas + aislamiento.

### ¿En qué se diferencia de Siri?
- Siri **espera** a que le hables; Oye Mijo **toma la iniciativa** (saluda, pregunta, recuerda).
- Siri **olvida**; Oye Mijo **recuerda** (si dio señal hoy, a quién no ha llamado, cómo ha estado).
- Siri es **igual para todos**; Oye Mijo es **personal** (voces y fotos de SU familia, SU rutina).
- Siri **obedece un comando**; Oye Mijo **acompaña un proceso** (después de una caída guía paso a paso).
- Siri **no involucra a la familia**; Oye Mijo **la acerca** (configuración, voces, recordatorios al hijo).
- **No compite con Siri: la usa como puerta.** Las funciones de Oye Mijo se activan con "Oye Siri…" (App Intents).
- Frase: *"Siri es el oído. Oye Mijo es el nieto que se preocupa."*

### MVP sintetizado propuesto (4 piezas)
1. 🌅 **Buenos días + señal de vida** — voz grabada por la familia, respuesta "Estoy bien" por voz o 1 toque (widget), escalamiento si no responde.
2. 🆘 **Protocolo "Me caí"** — "Oye Siri, me caí" → Oye Mijo habla con calma, guía, llama en cadena (hijo → otro familiar → 911), muestra ficha médica. + asistente para activar SOS / Check In / detección de caídas del Watch.
3. 🖼️ **Portarretratos + "hace N días"** — widget de familia con llamada/FaceTime de 1 toque y contador de último contacto.
4. 👨‍👩‍👧 **Modo familia (configurar en una visita)** — el hijo graba voces, elige fotos, contactos y horarios; el adulto mayor nunca ve ajustes.
- Opcionales: pasos del día (CoreMotion) como señal pasiva; UCLA-3 mensual para medir impacto; pregunta del día.

---

## Sesión 6 — Enfoque final: SALUD Y SEGURIDAD
- ✅ Tres pilares: **caídas**, **seguimiento de medicinas**, **acceso a su familia**.
- ❌ Se excluye "Buenos días + señal de vida".
- Plan de implementación propuesto en el chat del 9 nov (widgets + App Intents/Siri + notificaciones con acción + SwiftData).

---

## Sesión 7 — Nuevo giro: "como un nieto"
- ❌ Llamar a la familia como función central (ya se puede sin Oye Mijo).
- ✅ Dos ejes: **(1) ayudar si se cae** y **(2) acercarlo a la tecnología como lo haría un nieto paciente**.
- Propuesta: "Enséñame" (guías por voz paso a paso, práctica sin miedo, "¿qué es esto?" con captura) + "Me caí" (acompañamiento para levantarse con seguridad, decidir si pedir ayuda, ficha médica). Puente: las primeras lecciones enseñan a activar SOS, ficha médica y detección de caídas.
- Medicinas: pendiente decidir si se quedan.

---

## Sesión 8 — Oye Mijo como AGENTE (tipo Muse de Meta), mínima interacción
- El usuario no sigue guías: **lo pide con la voz y Oye Mijo lo hace**, y explica en una frase.
- iPhone del equipo: **17 Pro** → tiene Apple Intelligence → **Foundation Models (IA de Apple en el teléfono)** disponible.
- Prueba real en la Mac (9 nov): el modelo funciona en español y **sí llama herramientas** ("márcale a mi hija" → llamarFamiliar(Hija); "recuérdame la pastilla a las 9" → crearRecordatorio(21:00)).
- ⚠️ Hallazgo: los **filtros de seguridad del modelo bloquean** temas de caídas y salud ("me caí y me duele la cadera" → guardrailViolation). → Las emergencias van por una **ruta fija sin IA** (palabras clave + protocolo), que además es más segura.
- Diferencia con Muse: Muse corre en la nube con tus contraseñas; **Oye Mijo corre 100% en el teléfono**, nada sale del iPhone.
