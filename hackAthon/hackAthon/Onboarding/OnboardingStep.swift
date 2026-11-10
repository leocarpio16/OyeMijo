//
//  OnboardingStep.swift
//  hackAthon
//
//  Marco de cada paso del registro, según el diseño del equipo: regresar,
//  puntitos de avance, bocina para repetir la pregunta, pregunta grande con
//  serifa, tarjeta inclinada y botón café abajo (con micrófono si aplica).
//

import SwiftUI

struct OnboardingStep<Content: View>: View {
    let paso: Int
    let titulo: String
    let subtitulo: String
    let boton: String
    var botonIcono: String?
    var botonActivo = true
    let onBack: () -> Void
    let onRepeat: () -> Void
    let onNext: () -> Void
    /// Micrófono a la derecha del botón; nil si el paso no se contesta con la voz.
    var onMic: (() -> Void)?
    var escuchando = false
    @ViewBuilder let content: Content

    private let margen = Theme.Spacing.screen - Theme.Spacing.xs

    var body: some View {
        VStack(spacing: Theme.Spacing.section) {
            HStack(alignment: .top) {
                RoundIconButton(systemImage: "arrow.left", label: "Regresar", action: onBack)
                Spacer()
                StepDots(current: paso, total: PasoDeRegistro.total)
                Spacer()
                RoundIconButton(systemImage: "speaker.wave.2", label: "Escuchar la pregunta", action: onRepeat)
            }
            .padding(.horizontal, margen)

            ScrollView {
                VStack(spacing: Theme.Spacing.section) {
                    VStack(spacing: Theme.Spacing.s) {
                        Text(titulo)
                            .serif(Theme.Typography.titleSize)
                            .foregroundStyle(Theme.Palette.cafe)
                        Text(subtitulo)
                            .font(Theme.Typography.support)
                            .foregroundStyle(Theme.Palette.cafeSoft)
                    }
                    .multilineTextAlignment(.center)

                    TiltedCard { content }
                }
                .padding(.horizontal, margen)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            HStack(spacing: Theme.Spacing.m) {
                PrimaryButton(title: boton, systemImage: botonIcono, action: onNext)
                    .disabled(!botonActivo)
                    .opacity(botonActivo ? 1 : 0.4)
                if let onMic {
                    RoundIconButton(systemImage: escuchando ? "stop.fill" : "mic",
                                    label: escuchando ? "Ya terminé" : "Contestar con la voz",
                                    size: Theme.Size.actionButton,
                                    background: escuchando ? Theme.Palette.brandBrown : Theme.Palette.brandAmber,
                                    iconColor: escuchando ? Theme.Palette.surface : Theme.Palette.brandBrown,
                                    shadow: Theme.Palette.amberGlow.opacity(0.4), action: onMic)
                }
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
}

/// Bienvenida y ¡Listo!: Mijo grande arriba, título, texto y un botón.
struct OnboardingHero: View {
    let titulo: String
    let texto: String
    let boton: String
    var height: CGFloat = Theme.Size.welcomeHeader
    var mijoSize: CGFloat = Theme.Size.welcomeMijo
    var titleSize: CGFloat = Theme.Typography.welcomeSize
    let action: () -> Void
    /// Mantener presionado a Mijo (solo Bienvenida: cargar datos de ejemplo).
    var onLongPress: (() -> Void)?

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                MijoHeader(height: height, mijoSize: mijoSize)
                    .onLongPressGesture { onLongPress?() }

                VStack(spacing: Theme.Spacing.s + 2) {
                    Text(titulo)
                        .serif(titleSize)
                        .foregroundStyle(Theme.Palette.cafe)
                        .minimumScaleFactor(0.7)
                    Text(texto)
                        .font(Theme.Typography.lead)
                        .foregroundStyle(Theme.Palette.cafeSoft)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.screen)
                .padding(.top, Theme.Spacing.xl + 2)

                Spacer(minLength: Theme.Spacing.l)

                PrimaryButton(title: boton, action: action)
                    .padding(.horizontal, Theme.Spacing.screen - Theme.Spacing.xs)
                    .padding(.bottom, geo.safeAreaInsets.bottom + Theme.Spacing.s)
            }
            .ignoresSafeArea()
        }
        .background(Theme.Palette.cream)
    }
}

#Preview("Paso") {
    OnboardingStep(paso: 1, titulo: "¿Cómo le gusta que le diga?", subtitulo: "Dígamelo o escríbalo",
                   boton: "Siguiente", onBack: {}, onRepeat: {}, onNext: {}, onMic: {}) {
        Text("Contenido")
    }
}

#Preview("Bienvenida") {
    OnboardingHero(titulo: "Oye Mijo.", texto: "Soy su nieto en el teléfono. Solo hábleme y yo le ayudo.",
                   boton: "Empezar") {}
}
