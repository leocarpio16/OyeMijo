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
    }

    // MARK: Radios de esquina
    enum Radius {
        /// Esquinas de abajo del panel ámbar de Mijo.
        static let header: CGFloat = 56
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
