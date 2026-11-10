//
//  TiltedCard.swift
//  hackAthon
//
//  Tarjeta blanca un poco inclinada, con otra color crema asomándose
//  atrás. La usan "Mijo le contesta" y "Sus pastillas de hoy".
//

import SwiftUI

struct TiltedCard<Content: View>: View {
    /// Inclinación de la tarjeta. Lo que no deba verse inclinado (una caja de
    /// texto) se gira al revés con `.rotationEffect(.degrees(-TiltedCard.tilt))`.
    static var tilt: Double { -1.2 }

    /// Espacio entre lo que va dentro de la tarjeta.
    var spacing: CGFloat = Theme.Spacing.l
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: spacing) { content }
            .padding(Theme.Spacing.section)
            .frame(maxWidth: .infinity)
            .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.card))
            .shadow(color: Theme.Palette.shadow.opacity(0.10), radius: 20, y: 18)
            .rotationEffect(.degrees(Self.tilt))
            .background {
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .fill(Theme.Palette.cardBack)
                    .padding(.horizontal, Theme.Spacing.l + 2)
                    .offset(y: Theme.Spacing.m + 2)
                    .rotationEffect(.degrees(3.5))
            }
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.top, Theme.Spacing.xs + 2)
            .padding(.bottom, Theme.Spacing.xl)
    }
}

#Preview {
    TiltedCard {
        Text("Su pastilla de la presión le toca a las 9:00.")
            .serif(Theme.Typography.answerSize)
            .multilineTextAlignment(.center)
    }
    .padding(20)
    .background(Theme.Palette.cream)
}
