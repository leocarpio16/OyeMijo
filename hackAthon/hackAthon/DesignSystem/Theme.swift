//
//  Theme.swift
//  hackAthon
//
//  Tokens de diseño: todo color, tipografía, espaciado y tamaño sale de aquí.
//  Letra: DM Sans (la eligió Leo; archivos en DesignSystem/Fonts/, se
//  registra en Fuentes.swift). Títulos con la versión "36pt", hecha para
//  tamaños grandes.
//  Vienen del diseño del equipo "Oye Mijito – Pantallas": fondo crema,
//  panel ámbar con Mijo, texto café, pastillas blancas y rojo solo para ayuda.
//  Todo el texto tiene contraste ≥ 4.5:1.
//

import SwiftUI

enum Theme {

    // MARK: Colores
    enum Palette {
        /// Fondo crema de todas las pantallas.
        static let cream = Color(hex: 0xFFF7E8)
        /// Texto principal café oscuro (14:1 sobre crema).
        static let cafe = Color(hex: 0x3B1F18)
        /// Texto de apoyo (6.7:1 sobre crema).
        static let cafeSoft = Color(hex: 0x6E5148)
        /// Ámbar de la marca: botón de hablar.
        static let brandAmber = Color(hex: 0xFAB432)
        /// Color de arriba del fondo del logo: el panel de Mijo usa este para
        /// que no se note dónde empieza la imagen.
        static let brandAmberTop = Color(hex: 0xFFC63A)
        /// Café del pelo de Mijo: ícono del micrófono (5.8:1 sobre ámbar).
        static let brandBrown = Color(hex: 0x5D352B)
        /// Rojo de ayuda (4.6:1 sobre blanco). Solo para emergencia.
        static let help = Color(hex: 0xD93A26)
        /// Pastillas blancas y su sombra cálida.
        static let surface = Color.white
        static let shadow = Color(hex: 0x5D352B)
        /// Arriba del degradado de "Mijo le contesta" (baja a crema).
        static let answerGlow = Color(hex: 0xFFE8B5)
        /// Borde del código QR en el registro.
        static let cardBack = Color(hex: 0xFEEBC1)
        /// Brillo naranja debajo del botón ámbar del micrófono.
        static let amberGlow = Color(hex: 0xF59D1D)
        /// Arriba del degradado de "¿Está bien?" (rosa que baja a crema).
        static let helpGlow = Color(hex: 0xFDDDD5)
        /// Verde de "Tomada" (6.4:1 sobre blanco).
        static let taken = Color(hex: 0x1B6E31)
        /// Círculo con la inicial de la persona de confianza.
        static let contactAvatar = Color(hex: 0xFEBF93)
        /// Puntos de avance del registro que todavía no se hacen.
        static let stepPending = Color(hex: 0x5D352B).opacity(0.20)
        /// Hoja clara de la ilustración de caída (la oscura usa `brandBrown`).
        static let leafLight = Color(hex: 0xE9A53A)
        /// Fondo del anillo de la cuenta regresiva.
        static let helpTrack = Color(hex: 0xF8DCD5)
    }

    // MARK: Tipografía
    // DM Sans. Todas respetan Dynamic Type: crecen junto con el estilo de
    // texto de Apple que se indica (title3, title2…).
    enum Typography {
        private static func dm(_ peso: String, _ tamano: CGFloat, _ estilo: Font.TextStyle) -> Font {
            .custom("DMSans-\(peso)", size: tamano, relativeTo: estilo)
        }
        /// "Buenos días,"
        static let greeting = dm("Regular", 20, .title3)
        /// "Doña Mari".
        static let name = Font.custom("DMSans36pt-Bold", size: 34, relativeTo: .largeTitle)
        /// Texto de las pastillas blancas y del botón de hablar.
        static let pill = dm("SemiBold", 20, .title3)
        /// "Ayuda" en la pastilla de arriba.
        static let helpPill = dm("Bold", 19, .headline)
        /// "Le escucho, Doña Mari".
        static let listening = dm("SemiBold", 22, .title2)
        /// Texto de apoyo: "Usted preguntó por su pastilla", "Faltan 20 minutos".
        static let support = dm("Regular", 22, .title2)
        /// "Mijo" en la tarjeta y "Su nieto en el teléfono" debajo.
        static let cardName = dm("Bold", 22, .title2)
        static let cardRole = dm("Regular", 20, .title3)
        /// Etiquetas de la tarjeta: "Losartán 50 mg".
        static let chip = dm("SemiBold", 20, .title3)
        /// Botón café grande: "Ya terminé", "Ya me la tomé".
        static let primaryButton = dm("Bold", 24, .title2)
        /// Pastilla "Escuchar".
        static let pillBold = dm("Bold", 21, .title3)

        /// Tamaños de los títulos grandes. Se usan con `.display(_:)`.
        static let quoteSize: CGFloat = 34   // lo que dijo la persona
        static let titleSize: CGFloat = 40   // "Mijo le contesta"
        static let answerSize: CGFloat = 36  // la respuesta de Mijo
        static let countdownSize: CGFloat = 66 // segundos de la cuenta regresiva
        static let welcomeSize: CGFloat = 56   // "Oye Mijo."
        static let doneSize: CGFloat = 48      // "¡Listo, Doña Mari!"
        static let inputSize: CGFloat = 34     // lo que escribe en el registro
        /// Texto de apoyo grande en Bienvenida y ¡Listo!
        static let lead = dm("Regular", 24, .title2)
        /// "Paso 1 de 4", "Su nombre".
        static let stepLabel = dm("SemiBold", 20, .title3)
        static let fieldLabel = dm("SemiBold", 21, .title3)
        /// Nombre de la persona de confianza.
        static let contactName = dm("Bold", 28, .title)
        /// Renglones de permisos: "Micrófono".
        static let rowTitle = dm("Bold", 23, .title2)
        /// "Posible caída" en la pastilla roja de arriba.
        static let alertPill = dm("Bold", 20, .title3)
        /// Botón de texto "Llamar al 911".
        static let textButton = dm("Bold", 22, .title2)
        /// Estado de cada pastilla: "Tomada", "Ahora".
        static let status = dm("Bold", 22, .title2)
        static let statusSoft = dm("SemiBold", 22, .title2)
        /// Segundos de la cuenta regresiva de ayuda, junto a su barra.
        static let countdown = Font.custom("DMSans36pt-Bold", size: 30, relativeTo: .title)
        /// Renglones de la ficha médica.
        static let cardRow = dm("Regular", 20, .title3)
        static let cardRowBold = dm("SemiBold", 20, .title3)
    }

    // MARK: Espaciado
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        /// Margen lateral de pantalla.
        static let screen: CGFloat = 24
        static let xl: CGFloat = 24
        /// Separación entre bloques en "Mijo le contesta" y relleno de la tarjeta.
        static let section: CGFloat = 22
    }

    // MARK: Radios de esquina
    enum Radius {
        /// Esquinas de abajo del panel ámbar de Mijo.
        static let header: CGFloat = 56
        /// Tarjeta de la respuesta de Mijo.
        static let card: CGFloat = 34
        /// Campo de texto y marco del código QR.
        static let input: CGFloat = 22
    }

    // MARK: Tamaños
    enum Size {
        /// Panel ámbar de Mijo en Inicio y la imagen de Mijo dentro.
        static let header: CGFloat = 400
        static let headerMijo: CGFloat = 440
        /// Botón redondo de hablar y el grosor de cada halo.
        static let talkButton: CGFloat = 108
        static let talkHalo: CGFloat = 14
        /// Pastilla blanca de la medicina y pastilla de "Ayuda".
        static let infoPill: CGFloat = 72
        static let helpPill: CGFloat = 52
        /// Avatar de Mijo en otras pantallas (nunca menos de 29 pt).
        static let mijoAvatar: CGFloat = 88
        /// Botón redondo blanco (regresar) y pastilla "Escuchar".
        static let roundButton: CGFloat = 64
        /// Botón café grande y botón ámbar pequeño del micrófono.
        static let actionButton: CGFloat = 76
        /// Mijo en la tarjeta de respuesta y alto de sus etiquetas.
        static let cardAvatar: CGFloat = 54
        static let chip: CGFloat = 46
        /// Barras que se mueven mientras Mijo escucha.
        static let waveBar: CGFloat = 6
        /// Anillo de la cuenta regresiva y su grosor.
        static let countdown: CGFloat = 180
        static let countdownStroke: CGFloat = 12
        /// Panel de Mijo en Bienvenida y en ¡Listo! (más alto que en Inicio).
        static let welcomeHeader: CGFloat = 470
        static let welcomeMijo: CGFloat = 490
        static let doneHeader: CGFloat = 440
        static let doneMijo: CGFloat = 470
        /// Campo de texto del registro y su borde ámbar.
        static let input: CGFloat = 80
        static let inputBorder: CGFloat = 3
        /// Círculo con la inicial del contacto; ícono de cada permiso.
        static let contactAvatar: CGFloat = 76
        static let rowIcon: CGFloat = 56
        /// Botón secundario dentro de una tarjeta ("Elegir otra persona").
        static let cardButton: CGFloat = 68
        /// Código QR para conectar a la familia.
        static let qr: CGFloat = 210
        /// Puntos de avance del registro.
        static let stepDot: CGFloat = 10
        static let stepDotActive: CGFloat = 26
        /// Renglón de cada pastilla en "Sus pastillas de hoy".
        static let pillRow: CGFloat = 64
        /// Etiqueta ámbar "Ahora".
        static let nowTag: CGFloat = 44
        /// Botón de solo texto ("Llamar al 911").
        static let textButton: CGFloat = 52
        /// Pantalla de caída: alto de la mancha y tamaño de la ilustración encima.
        static let blob: CGFloat = 230
        static let illustration: CGFloat = 104
        /// Barra de avance de los pasos y de la cuenta regresiva.
        static let progressBar: CGFloat = 6
        /// Escena de la pantalla de caída: alto total, hoja grande y sol.
        static let scene: CGFloat = 250
        static let leaf: CGFloat = 96
        static let sun: CGFloat = 64
    }
}

/// Título grande en DM Sans (versión 36pt) que crece con Dynamic Type, igual que el resto.
private struct DisplayFont: ViewModifier {
    @ScaledMetric private var size: CGFloat
    let weight: Font.Weight

    init(size: CGFloat, weight: Font.Weight) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: .largeTitle)
        self.weight = weight
    }

    func body(content: Content) -> some View {
        // Solo hay dos grosores para títulos: negrita y seminegrita.
        let nombre = switch weight {
        case .bold, .heavy, .black: "DMSans36pt-Bold"
        default: "DMSans36pt-SemiBold"
        }
        content.font(.custom(nombre, fixedSize: size))
    }
}

extension View {
    /// `.display(Theme.Typography.answerSize, weight: .semibold)`
    func display(_ size: CGFloat, weight: Font.Weight = .bold) -> some View {
        modifier(DisplayFont(size: size, weight: weight))
    }
}

extension Color {
    /// Color a partir de un hexadecimal, como en CSS: Color(hex: 0xFAB432).
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}
