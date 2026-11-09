---
name: hackathon-docs-pitch
description: Redacta y actualiza la documentación de entrega del hackathon (README, PRD, guion de pitch de 5 min, preguntas del jurado, checklist de entrega). Úsala cuando el usuario pida README, docs, pitch, presentación, preguntas del jurado, checklist o "preparar la entrega".
---

# Docs y pitch del hackathon

## Reglas generales
- Español, frases cortas, sin marketing ("revolucionario", "potenciado por IA", "sin fisuras": prohibido).
- **Solo documenta lo que existe en el código.** Antes de escribir, revisa los .swift. Lo que no existe va en "Siguientes pasos", nunca como función hecha.
- Mismo nombre de app y misma descripción de 1 frase en todos los documentos.

## Archivos (en docs/ salvo README)
- `README.md` (raíz): qué es (1 frase), problema, capturas, funciones reales, cómo correrla (`scripts/build.sh` o Xcode), tecnologías de Apple usadas, equipo, siguientes pasos.
- `docs/PRD.md`: problema, usuario, alcance del MVP, pantallas, fuera de alcance. Marca cada función como Hecha / En progreso / Siguiente paso.
- `docs/PITCH.md`: guion de 5:00 con tiempos:
  - 0:00–0:30 gancho (una persona y su problema concreto)
  - 0:30–1:00 problema y por qué importa
  - 1:00–3:30 demo en vivo (camino feliz, 1 sola historia)
  - 3:30–4:15 cómo está hecha (frameworks de Apple, decisión técnica clave)
  - 4:15–5:00 siguientes pasos y cierre
  Incluye quién habla en cada parte y un plan B si la demo falla (video o capturas).
- `docs/QA_JURADO.md`: 8 preguntas probables con respuestas de ~20 s (≈50 palabras). Incluir siempre: "¿usaron IA y cómo?", "¿qué fue lo más difícil?", "¿cómo escalaría?", "¿privacidad de datos?", "¿qué harían con una semana más?".
- `docs/CHECKLIST_ENTREGA.md`: build limpio, README completo, capturas, sin secretos (`grep -riE "api[_-]?key|secret|token|password"`), `git status` limpio, push hecho, link entregado antes de la hora.

## Uso de IA
Sé transparente: en README incluye una sección corta "Uso de IA" (qué se hizo con IA y qué a mano), si el evento lo permite.
