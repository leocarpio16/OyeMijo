---
name: explain-my-code
description: Explica el código Swift/SwiftUI del proyecto en español sencillo, comparando con Python, para que el usuario pueda defenderlo ante el jurado. Úsala cuando pregunte "qué hace esto", "explícame este archivo", "cómo funciona X", "qué digo si me preguntan por Y", y siempre después de crear o cambiar un archivo .swift.
---

# Explicar mi código

El usuario tiene nivel básico de Swift y viene de Python. Tiene que poder responder preguntas del jurado sobre código que escribió con IA.

## Formato
1. **Para qué sirve el archivo** (1 frase).
2. **Recorrido por bloques**, no línea por línea si es obvio: cita el bloque, explica en 1–2 frases.
3. **Equivalente en Python** cuando ayude (ej. `struct` ≈ `@dataclass`, `@Observable class` ≈ objeto cuyos cambios redibujan la pantalla, `enum` con `case` ≈ `Enum`, `guard let` ≈ `if x is None: return`).
4. **Qué podría preguntar el jurado** sobre este archivo y la respuesta en 20 segundos.
5. **Prueba rápida**: una pregunta para que el usuario verifique que entendió.

## Reglas
- Frases cortas. Nada de jerga sin explicar (si dices "binding", explícalo).
- No inventes comportamiento: lee el archivo antes de explicar.
- Si algo del código es frágil o es atajo de hackathon, dilo con honestidad: el jurado lo valora más que fingir.

## Glosario base SwiftUI
- `View` / `body`: la pantalla se describe como función de los datos; se redibuja sola cuando cambian.
- `@State`: dato local de una vista que, al cambiar, la redibuja.
- `@Observable`: clase de datos compartida entre vistas.
- `@Binding`: referencia a un dato de otra vista para poder modificarlo.
- `NavigationStack`, `List`, `ForEach`, `VStack/HStack`: navegación, listas y apilado vertical/horizontal.
