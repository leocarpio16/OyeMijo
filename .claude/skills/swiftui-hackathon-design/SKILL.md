---
name: swiftui-hackathon-design
description: Reglas de código SwiftUI y de diseño visual para la app del hackathon, para que el código sea simple y la app no parezca plantilla de IA. Úsala al crear o modificar cualquier vista o archivo .swift, al tocar DesignSystem/, o cuando el usuario pida "que se vea mejor", "pulir", "diseño" o "que no parezca hecha con IA".
---

# SwiftUI + diseño para el hackathon

## Reglas del evento (no negociables)
- Solo frameworks de Apple y APIs públicas gratuitas. Sin paquetes SPM/CocoaPods.
- Nada de Vision Pro ni Create ML / Co-ML.
- Antes de usar una API web, confirma que es gratuita y no requiere clave secreta en el repo.

## Reglas de código
- iOS 17+, SwiftUI, `@Observable` (no `ObservableObject` salvo necesidad).
- Un archivo por vista o modelo. Archivos de <150 líneas; si crece, extrae subvistas.
- Cambios pequeños: un archivo a la vez, compila después de cada uno (skill xcode-build-verify).
- Datos de ejemplo realistas y en español, ligados al tema de la app. Nunca "John Doe", "Lorem ipsum", "Item 1".
- Nombres en inglés para código, textos de UI en español.
- No reescribas código que el equipo escribió a mano sin preguntar.
- Incluye `#Preview` en cada vista.

## DesignSystem/
Todo color, tipografía y espaciado sale de `DesignSystem/` (ej. `Theme.swift`):
- 1 color de acento propio (no el azul por defecto), 1 neutro de fondo, 1 de texto secundario. Soporte de modo oscuro.
- Escala de espaciado fija (4, 8, 12, 16, 24, 32).
- Tipografía: estilos del sistema (`.title`, `.body`…) para Dynamic Type; como mucho un `.fontDesign(.rounded)` o `.serif` coherente en toda la app.

## Rasgos de "plantilla de IA" a evitar
- Degradados morado-azul o fondos con degradado sin motivo.
- Tarjetas con sombra en todo; prefiere secciones planas, separadores o `List` con estilo nativo.
- Un SF Symbol en cada línea; úsalos solo donde ayudan a escanear.
- Textos de relleno ("Bienvenido a tu app increíble", "Empieza tu viaje").
- Emojis como iconografía.
- Pantallas con 6 botones iguales; debe haber una acción principal clara.

## Cómo proponer cambios de diseño
1. Lista el problema concreto (archivo:línea).
2. Propón el cambio usando tokens de DesignSystem/.
3. Espera OK del usuario, aplica, compila y muestra captura.
