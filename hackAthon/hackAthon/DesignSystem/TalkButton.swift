//
//  TalkButton.swift
//  hackAthon
//
//  Botón redondo ámbar con el micrófono y dos halos alrededor, y abajo
//  "Toque y dígame qué necesita". Es la acción principal de Inicio.
//

import SwiftUI

struct TalkButton: View {
    let action: () -> Void

    var body: some View {
        let halo = Theme.Size.talkHalo
        Button(action: action) {
            VStack(spacing: Theme.Spacing.l + halo) {
                Circle()
                    .fill(Theme.Palette.brandAmber)
                    .frame(width: Theme.Size.talkButton, height: Theme.Size.talkButton)
                    .overlay {
                        Image(systemName: "mic")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(Theme.Palette.brandBrown)
                    }
                    // Dos halos que se desvanecen: invitan a tocar.
                    .background(Circle().fill(Theme.Palette.brandAmber.opacity(0.22)).padding(-halo))
                    .background(Circle().fill(Theme.Palette.brandAmber.opacity(0.10)).padding(-2 * halo))

                Text("Toque y dígame qué necesita")
                    .font(Theme.Typography.pill)
                    .foregroundStyle(Theme.Palette.cafe)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Hablar con Mijo")
    }
}

#Preview {
    TalkButton {}.padding(40).background(Theme.Palette.cream)
}
