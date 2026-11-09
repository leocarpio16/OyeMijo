//
//  ListeningView.swift
//  hackAthon
//
//  "Mijo escuchando", según el diseño del equipo: Mijo arriba, lo que va
//  entendiendo en letra grande, las barritas de la voz y "Ya terminé".
//

import SwiftUI

struct ListeningView: View {
    let nombre: String
    /// Lo que se va entendiendo.
    let texto: String
    let nivel: Double
    /// true mientras la IA decide qué contestar.
    let pensando: Bool
    let onBack: () -> Void
    let onDone: () -> Void

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                MijoHeader()
                    .overlay(alignment: .topLeading) {
                        RoundIconButton(systemImage: "arrow.left", label: "Cancelar", action: onBack)
                            .padding(.top, geo.safeAreaInsets.top + Theme.Spacing.xs)
                            .padding(.leading, Theme.Spacing.screen - Theme.Spacing.xs)
                    }

                VStack(spacing: Theme.Spacing.s + 2) {
                    Text(pensando ? "Déjeme ver…" : "Le escucho, \(nombre)")
                        .font(Theme.Typography.listening)
                        .foregroundStyle(Theme.Palette.cafeSoft)
                    if !texto.isEmpty {
                        Text("“\(texto)”")
                            .serif(Theme.Typography.quoteSize)
                            .foregroundStyle(Theme.Palette.cafe)
                            .lineLimit(4)
                            .truncationMode(.head) // si es larga, se ve lo último que dijo
                            .minimumScaleFactor(0.6)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.screen - Theme.Spacing.xs)
                .padding(.top, Theme.Spacing.xl)

                Spacer(minLength: Theme.Spacing.s)
                WaveBars(level: pensando ? 0 : nivel)
                Spacer(minLength: Theme.Spacing.s)

                PrimaryButton(title: "Ya terminé", action: onDone)
                    .opacity(pensando ? 0 : 1)
                    .disabled(pensando)
                    .padding(.horizontal, Theme.Spacing.screen - Theme.Spacing.xs)
                    .padding(.bottom, geo.safeAreaInsets.bottom + Theme.Spacing.s)
            }
            .ignoresSafeArea()
        }
        .background(Theme.Palette.cream)
    }
}

#Preview {
    ListeningView(nombre: "Doña Mari", texto: "¿A qué hora me tomo la pastilla de la presión?",
                  nivel: 0.8, pensando: false, onBack: {}, onDone: {})
}
