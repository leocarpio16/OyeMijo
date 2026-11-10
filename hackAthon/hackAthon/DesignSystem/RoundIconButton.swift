//
//  RoundIconButton.swift
//  hackAthon
//
//  Botón redondo con un ícono. Blanco para regresar; ámbar para el
//  micrófono pequeño de "Mijo le contesta".
//

import SwiftUI

struct RoundIconButton: View {
    let systemImage: String
    let label: String
    var size: CGFloat = Theme.Size.roundButton
    var background: Color = Theme.Palette.surface
    var iconColor: Color = Theme.Palette.cafe
    var shadow: Color = Theme.Palette.shadow.opacity(0.12)
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: size, height: size)
                .background(background, in: .circle)
                .shadow(color: shadow, radius: 9, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    HStack(spacing: 24) {
        RoundIconButton(systemImage: "arrow.left", label: "Regresar") {}
        RoundIconButton(systemImage: "mic", label: "Hablar con Mijo",
                        size: Theme.Size.actionButton, background: Theme.Palette.brandAmber,
                        iconColor: Theme.Palette.brandBrown,
                        shadow: Theme.Palette.amberGlow.opacity(0.4)) {}
    }
    .padding(40)
    .background(Theme.Palette.cream)
}
