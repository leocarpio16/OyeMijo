//
//  AnswerView.swift
//  hackAthon
//
//  "Mijo le contesta", según el diseño del equipo: la respuesta en una
//  tarjeta blanca un poco inclinada, "Escuchar" para repetirla y, abajo,
//  el botón de la acción y el micrófono para seguir platicando.
//

import SwiftUI

struct AnswerView: View {
    /// Lo que dijo la persona.
    let frase: String
    let respuesta: RespuestaDeMijo
    let onBack: () -> Void
    let onRepeat: () -> Void
    let onAction: (AccionDeMijo) -> Void
    let onTalk: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.section) {
            HStack {
                RoundIconButton(systemImage: "arrow.left", label: "Inicio", action: onBack)
                Spacer()
                WhitePill(title: "Escuchar", systemImage: "speaker.wave.2",
                          iconColor: Theme.Palette.cafe, font: Theme.Typography.pillBold,
                          height: Theme.Size.roundButton, fullWidth: false,
                          shadowOpacity: 0.12, action: onRepeat)
            }
            .padding(.horizontal, margen)

            // El margen va dentro del scroll para que la tarjeta inclinada y su sombra no se corten.
            ScrollView {
                VStack(spacing: Theme.Spacing.section) {
                    VStack(spacing: Theme.Spacing.s) {
                        Text("Mijo le contesta")
                            .serif(Theme.Typography.titleSize)
                            .foregroundStyle(Theme.Palette.cafe)
                        if !frase.isEmpty {
                            Text("Usted dijo: “\(frase)”")
                                .font(Theme.Typography.support)
                                .foregroundStyle(Theme.Palette.cafeSoft)
                                .lineLimit(2)
                        }
                    }
                    .multilineTextAlignment(.center)

                    card
                }
                .padding(.horizontal, margen)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)

            HStack(spacing: Theme.Spacing.m) {
                if let accion = respuesta.accion {
                    switch accion {
                    case .llamar(let familiar):
                        PrimaryButton(title: "Llamar a \(familiar.nombre)", systemImage: "phone") { onAction(accion) }
                    case .marcarTomada:
                        PrimaryButton(title: "Ya me la tomé", systemImage: "checkmark") { onAction(accion) }
                    }
                } else {
                    Spacer()
                }
                RoundIconButton(systemImage: "mic", label: "Hablar con Mijo",
                                size: Theme.Size.actionButton, background: Theme.Palette.brandAmber,
                                iconColor: Theme.Palette.brandBrown,
                                shadow: Theme.Palette.amberGlow.opacity(0.4), action: onTalk)
            }
            .padding(.horizontal, margen)
        }
        .padding(.top, Theme.Spacing.xs)
        .padding(.bottom, Theme.Spacing.s)
        .background {
            LinearGradient(stops: [.init(color: Theme.Palette.answerGlow, location: 0),
                                   .init(color: Theme.Palette.cream, location: 0.58)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }

    private let margen = Theme.Spacing.screen - Theme.Spacing.xs

    private var card: some View {
        TiltedCard {
            HStack(spacing: Theme.Spacing.m) {
                MijoAvatar(size: Theme.Size.cardAvatar)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Mijo")
                        .font(Theme.Typography.cardName)
                        .foregroundStyle(Theme.Palette.cafe)
                    Text("Su nieto en el teléfono")
                        .font(Theme.Typography.cardRole)
                        .foregroundStyle(Theme.Palette.cafeSoft)
                }
                Spacer(minLength: 0)
            }

            Text(respuesta.texto)
                .serif(Theme.Typography.answerSize)
                .foregroundStyle(Theme.Palette.cafe)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)

            if let detalle = respuesta.detalle {
                Text(detalle)
                    .font(Theme.Typography.support)
                    .foregroundStyle(Theme.Palette.cafeSoft)
            }

            if !respuesta.etiquetas.isEmpty {
                // En una fila si caben; si no, una debajo de otra.
                ViewThatFits {
                    HStack(spacing: Theme.Spacing.s) { chips }
                    VStack(spacing: Theme.Spacing.s) { chips }
                }
            }
        }
    }

    private var chips: some View {
        ForEach(respuesta.etiquetas, id: \.self) { etiqueta in
            Text(etiqueta)
                .font(Theme.Typography.chip)
                .foregroundStyle(Theme.Palette.cafe)
                .lineLimit(1)
                .padding(.horizontal, Theme.Spacing.l)
                .frame(minHeight: Theme.Size.chip)
                .background(Theme.Palette.cream, in: .capsule)
        }
    }
}

#Preview {
    AnswerView(frase: "¿A qué hora me tomo la pastilla de la presión?",
               respuesta: RespuestaDeMijo(texto: "Su pastilla de la presión le toca a las 9:00.",
                                          detalle: "Faltan 20 minutos",
                                          etiquetas: ["Losartán 50 mg", "1 pastilla"]),
               onBack: {}, onRepeat: {}, onAction: { _ in }, onTalk: {})
}
