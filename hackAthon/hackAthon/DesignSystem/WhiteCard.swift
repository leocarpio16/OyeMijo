//
//  WhiteCard.swift
//  hackAthon
//
//  Tarjeta blanca derecha con sombra suave. La usan "Mijo le contesta",
//  "Sus pastillas de hoy" y los pasos del registro.
//

import SwiftUI

struct WhiteCard<Content: View>: View {
    /// Espacio entre lo que va dentro de la tarjeta.
    var spacing: CGFloat = Theme.Spacing.l
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: spacing) { content }
            .padding(Theme.Spacing.section)
            .frame(maxWidth: .infinity)
            .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.card))
            .shadow(color: Theme.Palette.shadow.opacity(0.10), radius: 20, y: 18)
            .padding(.bottom, Theme.Spacing.l)
    }
}

#Preview {
    WhiteCard {
        Text("Su pastilla de la presión le toca a las 9:00.")
            .display(Theme.Typography.answerSize, weight: .semibold)
            .multilineTextAlignment(.center)
    }
    .padding(20)
    .background(Theme.Palette.cream)
}
