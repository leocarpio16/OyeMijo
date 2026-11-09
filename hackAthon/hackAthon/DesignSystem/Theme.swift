//
//  Theme.swift
//  hackAthon
//
//  Tokens de diseño: todo color, tipografía, espaciado y tamaño sale de aquí.
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
        /// Tarjeta de atrás, inclinada, en la respuesta de Mijo.
        static let cardBack = Color(hex: 0xFEEBC1)
        /// Brillo naranja debajo del botón ámbar del micrófono.
        static let amberGlow = Color(hex: 0xF59D1D)
    }

    // MARK: Tipografía
    // El diseño usa Figtree y Newsreader; aquí van sus equivalentes que ya
    // vienen en el iPhone: Avenir Next y New York (la serifa de Apple).
    // Todas respetan Dynamic Type.
    enum Typography {
        private static func avenir(_ peso: String, _ tamano: CGFloat, _ estilo: Font.TextStyle) -> Font {
            .custom("AvenirNext-\(peso)", size: tamano, relativeTo: estilo)
        }
        /// "Buenos días,"
        static let greeting = avenir("Regular", 20, .title3)
        /// "Doña Mari" en serifa.
        static let name = Font.system(.largeTitle, design: .serif, weight: .medium)
        /// Texto de las pastillas blancas y del botón de hablar.
        static let pill = avenir("DemiBold", 20, .title3)
        /// "Ayuda" en la pastilla de arriba.
        static let helpPill = avenir("Bold", 19, .headline)
        /// "Le escucho, Doña Mari".
        static let listening = avenir("DemiBold", 22, .title2)
        /// Texto de apoyo: "Usted preguntó por su pastilla", "Faltan 20 minutos".
        static let support = avenir("Regular", 22, .title2)
        /// "Mijo" en la tarjeta y "Su nieto en el teléfono" debajo.
        static let cardName = avenir("Bold", 22, .title2)
        static let cardRole = avenir("Regular", 20, .title3)
        /// Etiquetas de la tarjeta: "Losartán 50 mg".
        static let chip = avenir("DemiBold", 20, .title3)
        /// Botón café grande: "Ya terminé", "Ya me la tomé".
        static let primaryButton = avenir("Bold", 24, .title2)
        /// Pastilla "Escuchar".
        static let pillBold = avenir("Bold", 21, .title3)

        /// Tamaños de la letra con serifa (New York). Se usan con `.serif(_:)`.
        static let quoteSize: CGFloat = 34   // lo que dijo la persona
        static let titleSize: CGFloat = 40   // "Mijo le contesta"
        static let answerSize: CGFloat = 36  // la respuesta de Mijo
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
    }
}

/// Letra con serifa (New York) que crece con Dynamic Type, igual que el resto.
private struct SerifFont: ViewModifier {
    @ScaledMetric private var size: CGFloat

    init(size: CGFloat) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: .largeTitle)
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: .medium, design: .serif))
    }
}

extension View {
    /// `.serif(Theme.Typography.answerSize)`
    func serif(_ size: CGFloat) -> some View {
        modifier(SerifFont(size: size))
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
