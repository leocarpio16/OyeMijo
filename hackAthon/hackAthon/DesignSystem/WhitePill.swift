//
//  WhitePill.swift
//  hackAthon
//
//  Pastilla blanca con sombra cálida: ícono + texto. Se usa para el botón
//  "Ayuda" de arriba y para el aviso de la siguiente medicina.
//

import SwiftUI

struct WhitePill: View {
    let title: String
    let systemImage: String
    var color: Color = Theme.Palette.cafe
    var iconColor: Color = Theme.Palette.brandBrown
    var font: Font = Theme.Typography.pill
    var height: CGFloat = Theme.Size.infoPill
    /// true = ocupa todo el ancho (medicina); false = se ajusta al texto (Ayuda).
    var fullWidth = true
    var shadowOpacity: Double = 0.08
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: Theme.Spacing.s) {
                Image(systemName: systemImage)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(font)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, Theme.Spacing.l + 2)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: height)
            .background(Theme.Palette.surface, in: .capsule)
            .shadow(color: Theme.Palette.shadow.opacity(shadowOpacity), radius: 9, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 24) {
        WhitePill(title: "Ayuda", systemImage: "exclamationmark.triangle",
                  color: Theme.Palette.help, iconColor: Theme.Palette.help,
                  font: Theme.Typography.helpPill, height: Theme.Size.helpPill,
                  fullWidth: false, shadowOpacity: 0.14) {}
        WhitePill(title: "9:00 p.m. · Pastilla de la presión", systemImage: "clock") {}
    }
    .padding(24)
    .background(Theme.Palette.cream)
}
