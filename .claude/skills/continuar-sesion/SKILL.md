---
name: continuar-sesion
description: Prepara el traspaso a un chat nuevo cuando la conversación ya es larga, escribiendo docs/HANDOFF.md con el estado exacto del trabajo para que otra sesión continúe sin perder contexto. Úsala cuando el usuario diga "cambiemos de chat", "continuar en otro chat", "handoff", "guarda el contexto", "/continuar-sesion", al cerrar un bloque del ROADMAP, o por iniciativa propia cuando la conversación sea muy larga (muchos archivos leídos, investigaciones extensas, o el sistema avise de compactación). También úsala al INICIAR un chat nuevo en este proyecto para retomar desde docs/HANDOFF.md.
---

# Continuar sesión (traspaso entre chats)

Claude no puede cerrar el chat por sí mismo ni medir su contexto exacto. Esta skill hace lo que sí se puede: dejar todo listo para que el usuario abra un chat nuevo y continúe en segundos.

## Cuándo proponer el cambio de chat
Propónlo (no lo impongas) cuando se cumpla cualquiera:
- Se terminó un bloque del `docs/ROADMAP.md` (punto natural de corte).
- La conversación incluyó investigaciones largas, muchos archivos leídos o varios giros de idea.
- El sistema avisó que resumió/compactó la conversación.
- Las respuestas empiezan a olvidar decisiones ya tomadas.
Frase: "Este chat ya es largo. Te dejo el traspaso listo; abre un chat nuevo y escribe `/continuar-sesion`."

## Modo A · Cerrar (escribir el traspaso)
1. Revisa `git status`, `git log --oneline -5` y el ROADMAP.
2. Sobrescribe `docs/HANDOFF.md` con esta plantilla (máximo ~80 líneas, frases cortas):

```markdown
# HANDOFF · <fecha y hora>
## Dónde estamos
- Bloque actual del ROADMAP y % aproximado.
- Último commit: <hash> <mensaje>. Cambios sin commit: <lista o "ninguno">.
- ¿Compila? <sí/no + error>.
## Decisiones vigentes (no re-discutir)
- …
## Lo último que se hizo
- …
## Siguiente paso exacto
1. …
## Pendientes del usuario (cosas que solo él puede hacer en Xcode/iPhone)
- …
## Cuidado con
- Errores conocidos, límites descubiertos, cosas que NO funcionaron.
## Archivos clave
- …
```
3. Marca en `docs/ROADMAP.md` lo que ya esté hecho.
4. No hagas commit salvo que el usuario lo pida.
5. Dile al usuario: abre un chat nuevo en `~/Desktop/hackathon-ios` y escribe `/continuar-sesion`.

## Modo B · Retomar (al iniciar un chat nuevo)
1. Lee, en este orden: `CLAUDE.md`, `docs/HANDOFF.md`, `docs/ROADMAP.md`, `docs/PRD.md`. No leas las investigaciones completas salvo que haga falta.
2. Verifica el estado real: `git status`, `./scripts/build.sh --solo-build`.
3. Resume al usuario en 5 líneas: dónde estamos, qué sigue, qué necesitas de él.
4. Continúa con el "Siguiente paso exacto" tras su OK.
