# Pruebas en el iPhone · Mijo

Para Leo, en el **iPhone 17 Pro** (el simulador no sirve para voz, Siri, llamadas, ubicación real ni sonido de avisos).
Anota junto a cada prueba: ✅ funciona · ❌ falla (qué pasó y **qué dijo Mijo**).

## 0 · Antes de empezar
- [ ] Voz natural: Ajustes → Accesibilidad → Contenido leído → Voces → Español (México) → Juan (Mejorada) o Paulina (Premium).
- [ ] Instalar **ntfy** en otro teléfono (Arturo o Sebastian).
- [ ] Borrar la app del iPhone e instalar desde Xcode (para empezar con el registro limpio).

## 1 · Registro por voz
- [ ] Nombre por voz → persona de confianza desde Contactos → QR: escanearlo con ntfy en el otro teléfono (debe llegar el primer aviso).
- [ ] Permisos: **3** (micrófono, avisos, **ubicación**). "Permitir todo" pide los tres y sigue.
- [ ] Llega a "¡Listo!" y luego a Inicio.

## 2 · Medicinas y avisos con voz
- [ ] "Recuérdame la pastilla de la presión a las 9 de la noche" → Mijo lo confirma en voz.
- [ ] Mantener presionado a Mijo en Inicio y bloquear el teléfono → en 5 s llega la pregunta **con la voz de Mijo**. Tocar "Ya me la tomé".
- [ ] "¿Ya me tomé la pastilla?" → contesta lo correcto.

## 3 · Mijo hace cosas (nuevo)
- [ ] "Mijo, mándale un WhatsApp a [persona de confianza] que ya comí" → abre **ese** chat con el texto escrito; falta tocar Enviar.
- [ ] "Mijo, avísale a mi familia que ya llegué a la casa" → llega a ntfy "Mensaje de …" **sin tocar nada**.
- [ ] "Mijo, ábreme YouTube" → dice una pista corta y abre YouTube.
- [ ] "Mijo, ponme canciones de Pedro Infante" → abre YouTube con la búsqueda.
- [ ] "Mijo, ábreme Netflix" (si no está instalado, debe abrir la página web).
- [ ] "Mijo, ¿dónde estoy?" → dice la dirección.
- [ ] Revisar que no confunda herramientas (WhatsApp vs. avisar a la familia) y que no diga "no le entendí" más seguido que antes (ahora tiene 10 herramientas).

## 4 · Caída completa (nuevo)
Con el otro teléfono con ntfy a la mano.
- [ ] Botón Ayuda → "¿Está bien?" → "Sí, estoy bien" → se cierra sin avisar a nadie.
- [ ] "Mijo, me caí" → pregunta **"¿Le duele algo?"** (antes avisaba directo).
- [ ] Rama **no me duele**: decir "no me duele" → aviso ntfy "se cayó · dice que no le duele" con **dirección y botón "Ver en el mapa"** → Mijo lee el paso 1 y espera.
- [ ] En cada paso: decir "ya" → pasa al siguiente; "repite" → lo dice otra vez; callarse → a los 15 s pasa solo. Probar también ⏮ 🔊 ⏭.
- [ ] Al final "¿Ya se pudo levantar?" → decir "ya" → se cierra.
- [ ] Misma rama, pero decir "no puedo" (en cualquier paso) → aviso **urgente** "no se puede levantar" + llamada al familiar.
- [ ] Misma rama, quedarse callado en todo → al final, 1 min después, aviso urgente solo.
- [ ] Rama **me duele**: decir "sí, me duele" → aviso urgente con dirección y mapa → Mijo dice "Usted está en …" → abre la llamada.
- [ ] No contestar nada 30 s → pide ayuda solo.
- [ ] Revisar en el otro teléfono que el botón "Ver en el mapa" abre el punto correcto.

## 5 · Siri
- [ ] "Oye Siri, habla con Mijo" → abre Mijo escuchando.
- [ ] "Oye Siri, Mijo, me caí" → abre la pregunta de caída.
- [ ] "Oye Siri, pregúntale a Mijo si ya me tomé la pastilla".

## Al terminar
- Pasarle a Claude la lista con ✅/❌ y lo que dijo Mijo en cada ❌.
- `! git push` (repo OyeMijo). **Datisa: no antes del martes 10 nov a las 9:00**; luego `! ./scripts/entregar.sh`.
