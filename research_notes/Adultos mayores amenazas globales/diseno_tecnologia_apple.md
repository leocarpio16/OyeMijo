# Adultos mayores, diseño y tecnología Apple para "Oye Mijo" (sin cuenta de pago, sin servidor)

> Notas de investigación (9 nov 2026). Convención: todo hallazgo lleva URL. Lo que NO se pudo verificar en esta sesión está en *Inferences* o *Gaps*, marcado como "no re-verificado", con la URL de Apple donde comprobarlo y cómo probarlo en Xcode.

---

## A1. Brecha digital: uso de smartphone e internet en personas de 65+

### Takeaway
La mayoría de los adultos mayores en países ricos ya tiene smartphone (EE. UU. ~76–79 % en 65+), pero en México solo el 42.1 % de las personas de 65+ usó internet en 2024. Ese grupo es el menos conectado en todos los países, y la brecha crece mucho a partir de los 75 años.

### Cited Findings
- **México (ENDUTIH 2024, INEGI):** el 42.1 % de las personas de 65+ usa internet. La serie 2021→2024 es 28.3 → 33.2 → 39.2 → 42.1 %. El grupo de 55–64 años llega a 71.0 % — [INEGI, presentación ENDUTIH 2024](https://inegi.org.mx/contenidos/programas/endutih/2024/doc/presentacion_endutih2024.pdf); [INEGI, comunicado ENDUTIH 2024](https://www.inegi.org.mx/contenidos/saladeprensa/boletines/2025/endutih/ENDUTIH_24_RR.pdf)
- **México (ENDUTIH 2025, publicada en 2026):** INEGI cambia el desglose a 65–74 años (57.8 %) y 75+ (30.3 %). No es directamente comparable con el 42.1 % de 2024 — [INEGI, presentación ENDUTIH 2025](https://www.inegi.org.mx/contenidos/programas/endutih/2025/doc/presentacion_endutih2025.pdf)
- **EE. UU. (Pew):** según la ficha de Pew, el 76 % de los adultos de 65+ tiene smartphone y el 94 % tiene celular. Otra versión de la tabla de Pew, con gráfico de 2024, dice 79 % (smartphone) y 96 % (celular). Las cifras difieren según la versión de la ficha, que ya se actualizó con una encuesta de feb–jun 2025 — [Pew Research, Mobile Fact Sheet](https://www.pewresearch.org/internet/fact-sheet/mobile/)
- **EE. UU., tendencia:** en 2021 el 61 % de los 65+ tenía smartphone; en 2012 era solo el 13 % (dato de Pew reportado por un medio secundario) — [McKnight's, citando a Pew](https://www.qgdigitalpublishing.com/article/Share+of+older+tech+users+soared+over+a+decade/4226157/740037/article.html)
- **Global (ITU Facts and Figures 2024):** 5,500 millones de personas en línea en 2024. El 79 % de las personas de 15–24 años usa internet, 13 puntos porcentuales más que los grupos de mayor edad — [ITU, Facts and Figures 2024](https://www.itu.int/itu-d/reports/statistics/facts-figures-2024); [ITU, comunicado de prensa](https://www.itu.int/en/mediacentre/Pages/PR-2024-11-27-facts-and-figures.aspx)
- **ITU 2025:** los adultos mayores, sobre todo los de 75+, son el grupo menos conectado — [ITU, Global Connectivity Report 2025, cap. 2](https://www.itu.int/itu-d/reports/statistics/2025/11/17/gcr-2025-chapter-2)
- **UE (Eurostat):** en 2024, el 93 % de las personas de 16–74 años usó internet en los últimos 3 meses. Ese mismo año, solo el 45 % de las de 65–74 usó al menos un dispositivo conectado, frente al 84 % de las de 16–24 (datos de Eurostat reportados por Euronews). En 2021, el 61 % de las personas de 65–74 había usado internet en los últimos 3 meses, frente al 98 % de las de 16–24 — [Eurostat, Statistics Explained](https://ec.europa.eu/eurostat/statistics-explained/index.php/Digital_economy_and_society_statistics_-_households_and_individuals); [Euronews 2025](https://www.euronews.com/my-europe/2025/09/03/what-internet-connected-devices-do-eu-citizens-use-the-most); [Eurostat news 2021](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/edn-20210517-1)

### Inferences
- Para el público de "Oye Mijo" en México, la mitad o más de los usuarios de 65+ tendrán poca experiencia previa con internet, y entre los de 75+ hay aún menos usuarios. Por eso conviene que el uso funcione sin aprender nada: voz, widgets de una sola acción, y que un familiar ("mijo") lo configure.
- La ITU sitúa a los grupos mayores unos 13 pp por debajo del 79 % de los jóvenes. Eso equivale a cerca del 66 % global para mayores de 24 años, pero es aritmética propia, no una cifra publicada para 65+.

### Gaps
- No encontré la cifra exacta de la ITU para 65+, ni el dato de Eurostat 2024 para 65–74 en "uso de internet" (tabla `isoc_ci_ifp_iu`, que no se pudo abrir).
- No se investigaron Japón ni Corea (MIC Communications Usage Trend Survey y NIA Korea Digital Divide Report son las fuentes a revisar). Tampoco otros países de Latinoamérica.
- La cifra exacta de Pew para 2024 vs. 2025 debe confirmarse directamente en la ficha.

---

## A2. Barreras de los adultos mayores y evidencia sobre asistentes de voz

### Takeaway
La voz ayuda porque no exige ver la pantalla ni usar las manos, pero falla mucho con adultos mayores: hubo errores en cerca de 1 de cada 4 interacciones, y estos no disminuyen con la práctica. El diseño debe asumir errores de reconocimiento y ofrecer siempre una vía de respaldo de un toque, además de confirmar lo que se entendió.

### Cited Findings
- **Estudio en casa de 1 mes (15 adultos mayores; Mahmood et al., ACM TACCESS 2026 / arXiv 2403.02421):**
  - El 24.76 % de las interacciones tuvo errores.
  - El tipo más común fue el error de intención del asistente (32.3 % de los errores), seguido del reconocimiento de voz (24.4 %) y del error humano (11.4 %).
  - Solo el 25.47 % de los errores se resolvió en el reintento inmediato.
  - La tasa de error no bajó en las 4 semanas.

  — [arXiv 2403.02421](https://arxiv.org/html/2403.02421v3)
- **Kim y Choudhury (Computers in Human Behavior, 2021, longitudinal):** los usuarios con experiencia desarrollaron una "respuesta resiliente" ante los errores funcionales, lo que favorece que sigan usando el asistente — [PDF del estudio](https://mycourses.aalto.fi/pluginfile.php/1528210/course/section/196004/Exploring%20older%20adults%E2%80%99%20perception%20and%20use%20of%20smart%20speaker-based%20voice%20assistants_%20A%20longitudinal%20study.pdf)
- **Kim (JMIR mHealth and uHealth, 2021):** los asistentes de voz en altavoces inteligentes prometen apoyo al envejecimiento gracias a la interacción sin manos y sin mirar la pantalla, pero se sabe poco de cómo los adultos mayores perciben ese beneficio — [JMIR mHealth 2021;9(1):e20427](https://mhealth.jmir.org/article/export/end/mhealth_v9i1e20427)
- **Jansons et al. (BMC Geriatrics, 2022), ejercicio guiado por Alexa:**
  - Barreras: errores de reconocimiento de voz y falta de retroalimentación.
  - Facilitadores: disfrute, facilidad de uso y conexión social.

  — [BMC Geriatrics](https://bmcgeriatr.biomedcentral.com/counter/pdf/10.1186/s12877-022-02963-2.pdf)
- **W3C WAI-AGE:** el declive de visión, oído, destreza y cognición es la base de las necesidades de los usuarios mayores. La artritis y los problemas de destreza justifican ofrecer formas de uso alternativas — [W3C WAI-AGE, Needs for Older Users](https://www.w3.org/WAI/WAI-AGE/conclude.html)
- **Apple ML Research:** muchos usuarios, sobre todo adultos mayores con cambios de capacidad, no conocen las funciones de accesibilidad o no saben qué combinación usar — [Apple ML Research, Recommending accessibility](https://machinelearning.apple.com/research/recommending-accessibility)

### Inferences
- Patrón recomendado para Oye Mijo:
  1. Confirmar en voz alta lo entendido ("¿Llamo a Juan?").
  2. Ofrecer un botón grande de "Sí/No" como respaldo.
  3. Nunca ejecutar acciones irreversibles (llamar, enviar o pagar) solo por voz sin confirmación.
- Como los errores no bajan con la práctica, el valor no puede depender de que el usuario "aprenda a hablarle". Las frases deben ser cortas, fijas y aparecer impresas en el widget (por ejemplo, "Oye Siri, Oye Mijo llama a mi hija").

### Gaps
- No encontré estudios revisados por pares sobre asistentes de voz con adultos mayores **hispanohablantes o con acento mexicano**, ni tasas de error de Siri en español (es-MX). Es un hueco relevante para la presentación.
- No encontré estudios cuantitativos sobre el "miedo a equivocarse" o el miedo a fraudes como barrera. Ese tema probablemente lo cubren otros investigadores (amenazas globales).

---

## A3. Modos simplificados: Apple Assistive Access y launchers de Android

### Takeaway
Assistive Access (iOS 17+) está pensado oficialmente para discapacidad cognitiva, no para adultos mayores en general. Requiere que alguien lo configure y supervise, y no encontré ninguna evaluación revisada por pares con adultos mayores. Los launchers simplificados de Android cumplen mal con las necesidades de este grupo.

### Cited Findings
- Apple describe Assistive Access como función para personas con discapacidad cognitiva. Los adultos mayores no son una categoría oficial y solo aparecen en los foros — [AgeInPlaceTech](https://www.ageinplacetech.com/node/5287)
- **Reseña práctica (Yahoo/Tom's Guide):**
  - El modo está pensado para que lo use, o al menos lo supervise, alguien que domine el iPhone normal.
  - Hay que salir del modo para tareas básicas: actualizar o descargar apps, o unirse a una red Wi-Fi.

  — [Yahoo News, reseña de Assistive Access](https://malaysia.news.yahoo.com/tried-apple-alternative-iphone-interface-120135229.html)
- Una evaluación heurística de launchers para smartphone concluyó que su interfaz cumple de forma limitada con las necesidades y capacidades de los adultos mayores (aparece citada en los resultados de búsqueda; no recuperé la URL primaria; ver Gaps).

### Inferences
- Para el pitch, Oye Mijo puede posicionarse como algo que complementa al iPhone normal en lugar de reemplazarlo: widgets y voz encima del sistema estándar, sin el costo de configurar Assistive Access. Además, en Assistive Access solo corren apps aprobadas por el cuidador, y las apps de terceros se ven en su forma completa salvo que adopten el soporte específico (no re-verificado; ver B7).

### Gaps
- No hay evaluaciones de Assistive Access con adultos mayores en CHI, ASSETS ni JMIR Aging (búsqueda limitada). Se sugiere buscar en Google Scholar "Assistive Access" + "older adults".
- No se recuperó la referencia primaria del estudio heurístico de launchers de Android, ni evaluaciones del "Modo sencillo" de Samsung.

---

## A4. Guías de diseño: W3C, Apple HIG, tamaño de objetivos táctiles, tipografía y contraste

### Takeaway
La evidencia empírica sugiere objetivos táctiles de ≥ 9–10 mm para adultos mayores; idealmente unos 13 mm o más, que en un iPhone equivalen aproximadamente a 60–80 pt. Esto supera con creces el mínimo de 44 pt de Apple. Las WCAG cubren la mayoría de las necesidades de los usuarios mayores, con la audición como laguna notable.

### Cited Findings
- **Estudio de selección táctil (20 mayores vs. 16 jóvenes, Android):**
  - Los mayores fueron más lentos (947 vs. 713 ms) y cometieron más errores (32.17 % vs. 9.17 %).
  - Con objetivos de 4.88 mm, el error fue de 62.4 % en mayores vs. 24.9 % en jóvenes.
  - Los errores bajaron significativamente a partir de 9.22 mm.

  La cifra proviene de una reseña secundaria y hay que confirmarla en el artículo original — [Reseña: "Effects of Aging on Small Target Selection with Touch Input"](https://a11y-paradise.onrender.com/reviews/69cd49cca2b3ddc6f03b373e)
- **Estudio de 2014 con botones numéricos:** reducir el botón a ≤ 10 mm aumenta el tiempo y los errores, y el efecto es mayor en adultos mayores — [CiNii](https://cir.nii.ac.jp/crid/1872835442836460416)
- **Universidad de Washington (ASSETS 2019):** los mayores de 60 eligieron mejor que los jóvenes su tamaño óptimo de objetivo. La mediana de su objetivo mínimo usable fue de unos 13 mm, frente a 4 mm en los jóvenes — [Wobbrock et al., ASSETS'19](https://faculty.washington.edu/wobbrock/pubs/assets-19.06.pdf)
- **iConference 2017:** objetivos de 32 px funcionaron mejor para apuntar; los de 64 px ayudaron en tareas de arrastre ("steering") — [MDSOAR](https://mdsoar.org/handle/11603/19868)
- **W3C WAI-AGE:** las guías WAI cubren la mayoría de los requisitos de los usuarios mayores con deterioro por edad. Las lagunas fueron la pérdida auditiva y la velocidad de descarga. El proyecto terminó en 2010 — [W3C, Web Accessibility for Older Users: A Literature Review](https://www.w3.org/WAI/older-users/literature/); [W3C WAI-AGE conclusiones](https://www.w3.org/WAI/WAI-AGE/conclude.html)

### Inferences
- Valores recomendados para Oye Mijo:

  | Elemento | Valor |
  |---|---|
  | Botones principales | ≥ 60–80 pt de alto (≈ 10–13 mm en iPhone de ~460 ppi) |
  | Separación entre objetivos | ≥ 8 pt |
  | Acciones por pantalla | 1–3 |
  | Texto | Dynamic Type (que respete el tamaño elegido por el usuario) |
  | Contraste | AA de WCAG como mínimo (4.5:1) |
  | Íconos | Siempre con etiqueta de texto |

- La conversión de mm a pt es propia y aproximada (1 pt ≈ 1/163 in en pantallas @1x lógicas; 10 mm ≈ 64 pt).
- "Enseñar una vez" frente a "no aprender nada": dado que los errores de voz no bajan con la práctica (A2) y que Assistive Access requiere supervisión (A3), conviene un modelo "lo configura mijo una vez; el adulto mayor no aprende nada". La evidencia es indirecta.

### Gaps
- No se recuperó en esta sesión la página de Apple HIG Accessibility. El mínimo de 44×44 pt y Dynamic Type vienen de conocimiento previo, no re-verificado; comprobar en https://developer.apple.com/design/human-interface-guidelines/accessibility
- No encontré guías actuales de W3C específicas para mayores posteriores a 2017, ni estudios de tamaño de fuente mínimo para adultos mayores en móvil.

---

## B1. Limitaciones del Apple ID gratuito (Personal Team)

### Takeaway
Con un Apple ID gratuito se puede instalar en un iPhone real.

| Funciona | No funciona |
|---|---|
| Background Modes | Push Notifications |
| App Groups (probablemente; ver conflicto) | Network Extensions y Personal VPN |
| MapKit sin rutas | Rutas de MapKit |

- Los perfiles caducan a los 7 días.
- El límite es de unas 3 apps instaladas por dispositivo y 10 App IDs.
- Si App Groups aparece disponible depende de la versión del cuadro de Apple; hay que verificarlo en Xcode en 2 minutos.

### Cited Findings
- **Definición:** la página oficial de capacidades de Apple tiene tres columnas: ADP (pago), ADEP (Enterprise) y "Apple Developer", que es una cuenta gratuita que aceptó el Apple Developer Agreement y no puede distribuir apps — [Apple, Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios)
- **MapKit:** sin membresía se puede usar MapKit pero **no se pueden ofrecer rutas** (routing directions) — [Apple, Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios)
- **Critical Alerts:** no aparece en la lista de capacidades de iOS. Es un entitlement que se solicita a Apple caso por caso, así que no está disponible en un Personal Team (inferencia sobre la solicitud: ver Gaps) — [Apple, Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios)
- **Lectura del cuadro de Apple (vía un issue en GitHub):**

  | Capacidad | Disponible con cuenta gratuita |
  |---|---|
  | Background Modes | Sí |
  | App Groups | Sí |
  | Network Extensions | No |
  | Personal VPN | No |
  | Push Notifications | No |

  Límites según la misma fuente:
  - Perfiles, App IDs y dispositivos caducan a los 7 días ("Provisioning profiles … will expire 7 days from issuance").
  - 10 App IDs y 3 dispositivos por cuenta gratuita.
  - 3 apps instaladas a la vez (dato de la FAQ de SideStore, no de Apple).

  — [GitHub djosh34/t3-optimizations #3](https://github.com/djosh34/t3-optimizations/issues/3)
- **Conflicto sobre App Groups:** otro proyecto reporta que un Personal Team **no pudo** firmar App Groups y cambió a Keychain Sharing para compartir datos con el widget — [GitHub destromoose/plantry PR #23](https://github.com/destromoose/plantry/pull/23). Aparte, hay un hilo del foro de Apple sobre fallos de firma automática con App Groups en Xcode 16.4 (macOS), relacionado con la armonización de App Groups entre macOS e iOS — [Apple Developer Forums 795444](https://developer.apple.com/forums/thread/795444)
- **Error típico:** "Personal development teams … do not support the Push Notifications capability". Apple DTS remite al cuadro de capacidades — [Apple Developer Forums 718388](https://developer.apple.com/forums/thread/718388); [Gordon Beeming, oct 2025](https://gordonbeeming.com/blog/2025-10-15/solving-xcode-provisioning-profile-and-capability-errors)
- **Límite de apps en Xcode con cuenta gratuita** — [Apple Developer Forums 745359](https://developer.apple.com/forums/thread/745359)

### Inferences
- **Push, CloudKit/iCloud y Critical Alerts** casi seguro no están disponibles; diseñar sin ellos. No hace falta backend, porque todo funciona con notificaciones locales, almacenamiento local y AlarmKit.
- **Time Sensitive Notifications** aparece en la lista de capacidades, pero no pude leer su columna. Probarlo en Xcode.
- **Siri y HealthKit:** no pude leer sus columnas. App Shortcuts no necesita la capacidad "Siri" (ver B3).
- **Plan B si App Groups falla:**
  1. Que el widget sea dueño de sus datos (datos estáticos en el bundle, o configurados con `AppIntentConfiguration` / `WidgetConfigurationIntent`).
  2. Que los botones del widget abran la app (`openAppWhenRun` o URL profunda) para que la lógica corra en el proceso de la app.
  3. Keychain Sharing, como hizo el proyecto plantry.
- **Cómo verificar en Xcode (2 min):**
  1. Seleccionar Target → Signing & Capabilities → Team: "(Personal Team)".
  2. Pulsar "+ Capability" → App Groups (y Time Sensitive Notifications, Siri, HealthKit).
  3. Si aparece "Personal development teams … do not support…", no está disponible.
  4. Compilar en el iPhone para confirmar que el perfil se genera.
  5. Hacerlo también para el target del widget.

### Gaps
- No se pudo leer la matriz de checkmarks del cuadro oficial: la página se renderiza con JavaScript y el extractor no capturó las celdas. Ver la tabla directamente en el navegador.
- Hay conflicto entre fuentes sobre App Groups con Personal Team. Puede depender de la versión de Xcode (16.x vs. 26.x) o de si el App Group se registra automáticamente.
- No verifiqué en la documentación de Apple que Critical Alerts requiera solicitud especial (conocimiento previo).

---

## B2. Widgets interactivos, Lock Screen, Control Center (ControlWidget) y botón de Acción, con o sin App Groups

### Takeaway
Por defecto, el `perform()` de un AppIntent lanzado desde un widget corre en el **proceso de la extensión del widget**, no en la app. Así que compartir estado con la app normalmente requiere App Groups. Hay dos formas de evitarlo: (1) `openAppWhenRun = true`, o (2) protocolos que fuerzan la ejecución en el proceso de la app (`AudioPlaybackIntent` o `LiveActivityIntent`). Con cualquiera de las dos, la lógica corre en la app y usa su almacenamiento propio.

### Cited Findings
- **Documentación de WidgetKit:** "by default, the system runs the app intent in the same process as the widget extension". Corre en el proceso de la app si `openAppWhenRun` es true o si el intent adopta `AudioPlaybackIntent` o `PushToTalkTransmissionIntent`. Con `LiveActivityIntent` o `AudioPlaybackIntent`, el sistema también lo ejecuta en el proceso de la app — [Apple, Adding interactivity to widgets and Live Activities](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
- **Foros de Apple, técnica del doble archivo:** un desarrollador definió el mismo intent en el target del widget (vacío) y en el de la app (con la lógica real). Otro reporta que un framework compartido mediante `AppIntentsPackage` funciona en iOS 17+. Otro advierte que, si los protocolos difieren entre targets, la copia del widget puede ejecutarse cuando la app no está corriendo — [Apple Developer Forums 731852](https://developer.apple.com/forums/thread/731852)
- `ForegroundContinuableIntent` hace que el intent continúe en la app, en primer plano (fuente secundaria) — [Kodeco/RW, Interactive Widgets With SwiftUI](https://raywenderlich.com/43771410-interactive-widgets-with-swiftui?page=2)
- Las guías de terceros asumen que las extensiones de widget requieren App Groups para compartir datos. No encontré una alternativa oficial sin App Groups — [Swiftjectivec, Interactive Widget con App Intents](https://swiftjectivec.com/snip-create-a-basic-interactive-widget-using-app-intent-button)
- iOS 26 trae novedades en widgets y controles (fuente secundaria) — [Blake Crosley, iOS 26 widget and control surface](https://blakecrosley.com/blog/ios-26-widget-and-control-surface)

### Inferences
- **Arquitectura viable sin App Groups** para un widget tipo "botón de pánico/llamar a mijo":
  - El widget muestra datos estáticos o configurables por intent (nombre y foto del contacto, elegidos al configurar el widget).
  - El botón ejecuta un intent con `openAppWhenRun = true`, que abre la app y la deja hacer la llamada, el mensaje o la grabación.
  - Alternativa: `Link(destination: URL("tel://…"))` en el widget, que no necesita la app (no re-verificado).
  - Un `ControlWidget` (iOS 18) y el botón de Acción pueden lanzar el mismo AppIntent.
- Para que el widget refleje cambios hechos en la app sin App Groups, no hay mecanismo oficial. Aceptar widgets "sin estado" para la demo.

### Gaps
- No se re-verificó en esta sesión si `ControlWidget` y el botón de Acción tienen requisitos adicionales de entitlement. Comprobar en la documentación de `ControlWidget` (https://developer.apple.com/documentation/widgetkit/controlwidget) y probar en el dispositivo.
- No se confirmó si `Link` con `tel://` dentro de un widget marca directamente o pide confirmación. Probar en el iPhone.

---

## B3. App Intents + App Shortcuts: invocación por voz con Siri, pantalla bloqueada, español y entitlement

### Takeaway
App Shortcuts se declaran en código (`AppShortcutsProvider`) y están disponibles en cuanto se instala la app, sin configuración del usuario. Siri, Spotlight y la app Atajos los descubren solos. Los foros muestran fallos recurrentes de reconocimiento en idiomas distintos del inglés. Hay que probar las frases en español (México) en el dispositivo desde el primer día.

### Cited Findings
- Los App Shortcuts "are available as soon as someone installs your app, and you don't have to register them yourself". Se definen con `AppShortcutsProvider` en la app, una extensión, un paquete o una librería. `SiriTipView` muestra al usuario la frase para invocarlos — [Apple, App Shortcuts (AppIntents)](https://developer.apple.com/documentation/appintents/app-shortcuts)
- Solo puede haber un `AppShortcutsProvider` por app, y las frases son lo que Siri hace coincidir — [WWDC23 "Spotlight your app with App Shortcuts"](https://developer.apple.com/wwdc23/10102)
- **Localización:** las frases se extraen a un String Catalog `AppShortcuts.xcstrings` tras compilar. Un bug reportado hace que solo se traduzca la primera frase de cada atajo. El límite de 1,000 frases es por idioma — [Apple Developer Forums 803490](https://www.developer.apple.com/forums/thread/803490); [Forums 797784](https://developer.apple.com/forums/thread/797784); [Forums 807411](https://developer.apple.com/forums/thread/807411)
- **Problemas en otros idiomas:**
  - En italiano, una frase de App Shortcut con `applicationName` falla en la beta de iOS 27.2, mientras que un atajo personal con nombre ejecuta el mismo intent.
  - En holandés, Siri identifica el atajo pero redirige a Notas o Intercom.
  - Pregunta en los foros: "¿se puede activar un atajo de app con Siri en otro idioma que no sea inglés?"

  — [Forums 849678](https://developer.apple.com/forums/thread/849678); [Forums 850345](https://developer.apple.com/forums/thread/850345); [Forums 737272](https://developer.apple.com/forums/thread/737272)
- Hay frases de Siri que no se reconocen con `AppShortcutsProvider` — [Forums 712095](https://developer.apple.com/forums/thread/712095)

### Inferences
- Los App Shortcuts **no requieren la capacidad "Siri"** (`com.apple.developer.siri`); esa capacidad es para el antiguo SiriKit/Intents. Es un dato muy citado, pero no lo confirmé en la documentación fetcheada en esta sesión. Para verificarlo: crear el `AppShortcutsProvider` sin agregar la capacidad Siri, instalar con el Personal Team y decir "Oye Siri, [frase con el nombre de la app]".
- **Nombre de la app:** las frases deben incluir `\(.applicationName)`. Un nombre como "Oye Mijo" puede chocar con el "Oye Siri" en español. Conviene probar frases como "Oye Siri, llama a mijo con Oye Mijo" y considerar sinónimos de nombre de app (`INAlternativeAppNames` en Info.plist; no re-verificado).
- **Pantalla bloqueada:** `authenticationPolicy` (`.alwaysAllowed` / `.requiresAuthentication` / `.requiresLocalDeviceAuthentication`) controla si el intent corre bloqueado. No re-verificado; ver la documentación de `AppIntent.authenticationPolicy`.

### Gaps
- No se confirmó en la documentación oficial que App Shortcuts esté soportado en es-MX ni su tasa de reconocimiento. No encontré pruebas públicas de App Shortcuts en español.
- No se confirmó el comportamiento con el iPhone bloqueado.

---

## B4. Reconocimiento y síntesis de voz: SFSpeechRecognizer, AVSpeechSynthesizer, SpeechAnalyzer (iOS 26)

### Takeaway
No re-verificado en esta sesión por límite de búsquedas. Lo que sigue es conocimiento previo y debe comprobarse en la documentación o en el dispositivo.

### Cited Findings
- No se recuperaron fuentes en esta sesión para este punto.

### Inferences
- **`SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))`** ofrece `supportsOnDeviceRecognition`; cuando es true, se puede forzar el reconocimiento local con `requiresOnDeviceRecognition = true`. Requiere permisos `NSSpeechRecognitionUsageDescription` y `NSMicrophoneUsageDescription` y no necesita entitlement. Docs: https://developer.apple.com/documentation/speech/sfspeechrecognizer
- **`SpeechAnalyzer` / `SpeechTranscriber`** (iOS 26, WWDC25) es la nueva API de transcripción en el dispositivo, con modelos que se descargan por idioma. Verificar si es-MX está en `SpeechTranscriber.supportedLocales`. Docs: https://developer.apple.com/documentation/speech/speechanalyzer
- **`AVSpeechSynthesizer`** con `AVSpeechSynthesisVoice(language: "es-MX")`: el usuario puede descargar voces "Mejoradas/Premium" en Ajustes → Accesibilidad → Contenido leído. Docs: https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer
- **Prueba rápida:** imprimir `SFSpeechRecognizer.supportedLocales()` y `AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("es") }` en el dispositivo.

### Gaps
- Todo B4 requiere verificación. Tampoco hay evidencia sobre la precisión de estas APIs con voces de adultos mayores en español.

---

## B5. Foundation Models framework (iOS 26)

### Takeaway
Funciona solo en dispositivos compatibles con Apple Intelligence (iPhone 15 Pro o posterior), con Apple Intelligence activado y con el **idioma del sistema** en uno soportado. El español está soportado. En el simulador se usa el Apple Intelligence del Mac (macOS Tahoe). La función debe ser opcional y degradarse si no está disponible.

### Cited Findings
- Requiere un dispositivo compatible con Apple Intelligence — [Apple, Foundation Models framework](https://developer.apple.com/foundation-models-framework/)
- Soporta los mismos idiomas que Apple Intelligence. El español está en la lista inicial; después se agregaron danés, holandés, noruego, portugués (Portugal), sueco, turco, chino tradicional y vietnamita. Se puede consultar en tiempo de ejecución con `SystemLanguageModel.default.supportedLanguages` — [Apple Developer Forums 791086 (resumen del Group Lab WWDC25)](https://developer.apple.com/forums/thread/791086); [Rudrank, Supported Languages](https://rudrank-ai.pages.dev/foundation-models/supported-languages-and-internationalization)
- El idioma del sistema del dispositivo debe ser uno soportado: si no, aparece el error "unsupported language or locale". Hay una queja de que esto excluye a millones de usuarios y se pide un override por app — [Forums 805378](https://developer.apple.com/forums/thread/805378); [Forums 797271](https://developer.apple.com/forums/thread/797271)
- **iPhone 15 Pro o posterior** (más iPad y Mac con Apple silicon), según guías de terceros — [Natasha the Robot](https://www.natashatherobot.com/p/apple-foundation-models)
- **Simulador:** usa el Apple Intelligence del Mac anfitrión, requiere macOS Tahoe y versiones alineadas de Xcode y el simulador — [Forums 791086](https://developer.apple.com/forums/thread/791086); [Natasha the Robot](https://www.natashatherobot.com/p/apple-foundation-models)

### Inferences
- Para la demo, comprobar `SystemLanguageModel.default.availability`. Si el valor no es `.available`, usar respuestas con plantillas. El iPhone de la demo debe estar en español y tener Apple Intelligence activo.

### Gaps
- No se leyó la lista oficial actual de idiomas en la página de Apple; usar `supportedLanguages` en el dispositivo.

---

## B6. Comunicación, ubicación, notificaciones, alarmas y datos (Contacts, tel://, FaceTime, MessageUI, WhatsApp, CoreLocation, MapKit, UserNotifications, AlarmKit, SwiftData, AVAudioRecorder, Live Activities)

### Takeaway
AlarmKit (iOS 26) permite alarmas fuertes programadas por la app, solo con permiso del usuario y la clave `NSAlarmKitUsageDescription`. Según fuentes de terceros, se salta el modo silencio y Focus. MapKit funciona con cuenta gratuita pero **sin rutas**. El resto de las APIs listadas no requiere capacidades de pago (conocimiento previo, ver Inferences).

### Cited Findings
- **AlarmKit:**
  - Sin la clave `NSAlarmKitUsageDescription` en Info.plist (o con el valor vacío), la app no puede programar alarmas.
  - Si la app no pide autorización, AlarmKit la pide automáticamente al crear la primera alarma.
  - `AlarmManager` expone `requestAuthorization()` y `authorizationState`.

  — [Apple, Scheduling an alarm with AlarmKit](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit); [Apple, AlarmManager](https://developer.apple.com/documentation/alarmkit/alarmmanager); [WWDC25 sesión 230](https://developer.apple.com/videos/play/wwdc2025/230/)
- Las alarmas de AlarmKit se saltan Focus y el modo silencio en iOS/iPadOS 26+. La fuente es de terceros; no lo vi en la página de Apple fetcheada — [skills.sh AlarmKit](https://skills.sh/dpearson2699/swift-ios-skills/alarmkit)
- AlarmKit requiere iOS 26 o posterior — [Apple, Scheduling an alarm with AlarmKit](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit)
- MapKit sí está disponible con cuenta gratuita, pero no las rutas — [Apple, Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios)

### Inferences
Conocimiento previo, no re-verificado en esta sesión. Verificar en las URLs indicadas:

| API | Notas | Verificar en |
|---|---|---|
| UserNotifications | Máximo **64 notificaciones locales pendientes** por app (el sistema conserva las 64 más próximas) | `UNUserNotificationCenter` (https://developer.apple.com/documentation/usernotifications/unusernotificationcenter) |
| Llamadas | `tel://` y `facetime://` / `facetime-audio://` mediante `UIApplication.open`; iOS muestra confirmación antes de llamar con `tel:` | https://developer.apple.com/documentation/uikit/uiapplication/open(_:options:completionhandler:) |
| MessageUI | `MFMessageComposeViewController` exige que el usuario pulse "Enviar"; no se pueden enviar SMS en silencio | https://developer.apple.com/documentation/messageui/mfmessagecomposeviewcontroller |
| WhatsApp | `https://wa.me/<número>?text=…` (universal link, no requiere `LSApplicationQueriesSchemes`); `whatsapp://send?phone=` requiere declararlo en `LSApplicationQueriesSchemes` | Documentación de WhatsApp |
| Contacts / ContactsUI | Permiso `NSContactsUsageDescription`; desde iOS 18 existe acceso limitado a contactos; `CNContactPickerViewController` no requiere permiso | https://developer.apple.com/documentation/contacts |
| CoreLocation | Funciona con cuenta gratuita; la localización en segundo plano requiere el Background Mode "Location", que según B1 está disponible | — |
| MapKit | `MKLocalSearch` (búsqueda de lugares, p. ej. "farmacia") debería funcionar sin rutas; abrir Apple Maps con `MKMapItem.openInMaps` para dar indicaciones con la app de Mapas | — |
| SwiftData y AVAudioRecorder | Sin entitlement; AVAudioRecorder necesita el permiso de micrófono | — |
| Live Activities | Se pueden iniciar y actualizar localmente con ActivityKit sin push (requiere `NSSupportsLiveActivities`) | — |

Riesgo de Live Activities: el target del widget puede necesitar compartir datos (ver B2).

### Gaps
- Ninguna fila de la tabla anterior se verificó con una fuente fetcheada en esta sesión.
- Falta confirmar en la documentación oficial que AlarmKit ignore Silencio y Focus, y si requiere alguna capacidad en Signing (se cree que no).

---

## B7. Funciones de seguridad nativas de iOS y enlaces profundos a sus ajustes

### Takeaway
No re-verificado en esta sesión. Según conocimiento previo, una app de terceros **no puede** abrir de forma soportada las pantallas de Ajustes de Emergencia SOS, Check In, Detección de choques, Live Voicemail, Silenciar desconocidos, Call Screening, Voz Personal, Live Speech ni Assistive Access. Solo puede abrir los ajustes de la propia app y los de sus notificaciones. Lo realista es guiar al usuario con instrucciones paso a paso, habladas o con capturas.

### Cited Findings
- No se recuperaron fuentes en esta sesión para este punto.
- Relacionado: dentro de Assistive Access, las tareas básicas (instalar apps, Wi-Fi) requieren salir del modo — [Yahoo News](https://malaysia.news.yahoo.com/tried-apple-alternative-iphone-interface-120135229.html)

### Inferences
- **APIs públicas:** `UIApplication.openSettingsURLString` abre los ajustes de la app y `UIApplication.openNotificationSettingsURLString` (iOS 16+) abre sus notificaciones. Las URLs `App-Prefs:` / `prefs:` son privadas y no están documentadas: pueden fallar o causar rechazo en el App Store. Esto último importa poco aquí porque la app no se publica. Docs: https://developer.apple.com/documentation/uikit/uiapplication/opensettingsurlstring
- **Funciones a "activar con mijo" como parte del onboarding guiado** (disponibilidad de memoria, no re-verificada):
  - Emergencia SOS
  - Check In (Mensajes, iOS 17)
  - Detección de choques (iPhone 14+)
  - Detección de caídas (Apple Watch)
  - Live Voicemail (iOS 17)
  - Silenciar llamadas desconocidas
  - Call Screening (iOS 26)
  - Voz Personal y Live Speech (iOS 17)
  - Assistive Access (iOS 17)
- **Ficha de soporte de Apple** para guiar la configuración de cada función: https://support.apple.com/es-mx/guide/iphone/

### Gaps
- No se verificó la disponibilidad en es-MX de Live Voicemail y Call Screening (algunas funciones se lanzan primero solo en ciertas regiones e idiomas).
- No se confirmó que no exista ningún deep link soportado.
- Verificación rápida: probar `UIApplication.shared.open(URL(string: "App-Prefs:root=…")!)` en el dispositivo; si devuelve false o abre la raíz de Ajustes, no es viable.
