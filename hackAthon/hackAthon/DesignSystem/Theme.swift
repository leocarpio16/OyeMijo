//
//  Theme.swift
//  hackAthon
//
//  Tokens de diseño: todo color, espaciado y radio de la app sale de aquí.
//  Valores provisionales; se ajustan cuando se defina el tema.
//

import SwiftUI

enum Theme {

    // MARK: Colores
    enum Palette {
        /// Color de acento de la app (botones, selección). Provisional: verde petróleo.
        static let accent = Color(light: .init(red: 0.05, green: 0.42, blue: 0.40),
                                  dark: .init(red: 0.35, green: 0.78, blue: 0.74))
        /// Fondo de pantalla.
        static let background = Color(uiColor: .systemGroupedBackground)
        /// Fondo de secciones sobre el fondo de pantalla.
        static let surface = Color(uiColor: .secondarySystemGroupedBackground)
        /// Texto principal y secundario.
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
    }

    // MARK: Espaciado (escala fija)
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: Radios de esquina
    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
    }
}

extension Color {
    /// Color que cambia entre modo claro y oscuro.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
