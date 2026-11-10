//
//  HelpView.swift
//  hackAthon
//
//  "¿Está bien?", según el diseño del equipo: cuenta de 30 segundos y
//  botones gigantes. Después del aviso muestra a quién se llamó y la
//  ficha médica para quien llegue a ayudar.
//  Regla de marca: Mijo no aparece junto a una alerta de emergencia.
//

import SwiftUI
import SwiftData

struct HelpView: View {
    @State private var modelo: HelpModel
    @Environment(\.dismiss) private var dismiss

    /// - Parameter frase: lo que dijo con Mijo ("me caí"); nil si tocó el botón Ayuda.
    init(context: ModelContext, nombre: String, motivo: Emergencia, frase: String? = nil) {
        _modelo = State(initialValue: HelpModel(context: context, nombre: nombre, motivo: motivo, frase: frase))
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.l + 2) {
            encabezado
                .padding(.horizontal, margen)

            // El margen va dentro del scroll para que la sombra de la tarjeta no se corte.
            ScrollView {
                VStack(spacing: Theme.Spacing.l + 2) {
                    titulo
                    if case .avisado = modelo.fase {
                        if let ficha = modelo.ficha { FichaCard(ficha: ficha) }
                    } else {
                        CountdownRing(segundos: modelo.segundos, total: HelpModel.segundosParaContestar)
                    }
                }
                .padding(.horizontal, margen)
                .padding(.bottom, Theme.Spacing.xl)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)

            botones
                .padding(.horizontal, margen)
        }
        .padding(.top, Theme.Spacing.xs)
        .padding(.bottom, Theme.Spacing.s)
        .background {
            LinearGradient(stops: [.init(color: Theme.Palette.helpGlow, location: 0),
                                   .init(color: Theme.Palette.cream, location: 0.58)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
        .task { await modelo.empezar() }
        .task { await modelo.contar() }
        .onChange(of: modelo.voz.textoEscuchado) { _, texto in modelo.revisar(texto) }
        .onChange(of: modelo.fase) { _, fase in
            if fase == .bien { dismiss() }
        }
        .onDisappear { modelo.cerrar() }
    }

    // MARK: Partes

    private let margen = Theme.Spacing.screen - Theme.Spacing.xs

    private var avisado: Bool {
        if case .avisado = modelo.fase { true } else { false }
    }

    /// Pastilla roja centrada; después del aviso, con flecha para cerrar.
    private var encabezado: some View {
        ZStack {
            HStack(spacing: 6) {
                Image(systemName: avisado ? "checkmark" : "exclamationmark.triangle")
                    .font(.system(size: 20, weight: .bold))
                Text(avisado ? "Aviso enviado" : modelo.etiqueta)
                    .font(Theme.Typography.alertPill)
            }
            .foregroundStyle(Theme.Palette.help)
            .padding(.horizontal, Theme.Spacing.l)
            .frame(minHeight: Theme.Size.chip)
            .background(Theme.Palette.surface, in: .capsule)

            if avisado {
                RoundIconButton(systemImage: "xmark", label: "Cerrar") { dismiss() }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minHeight: Theme.Size.roundButton)
    }

    private var titulo: some View {
        VStack(spacing: Theme.Spacing.s) {
            Text(textoTitulo)
                .serif(Theme.Typography.titleSize)
                .foregroundStyle(Theme.Palette.cafe)
            Text(textoSubtitulo)
                .font(Theme.Typography.support)
                .foregroundStyle(Theme.Palette.cafeSoft)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, Theme.Spacing.xs)
    }

    private var textoTitulo: String {
        switch modelo.fase {
        case .avisado(let enviado): enviado ? "Ya le avisé a su familia" : "No pude mandar el aviso"
        case .avisando: "Avisando a su familia…"
        default: "\(modelo.nombre), ¿está bien?"
        }
    }

    private var textoSubtitulo: String {
        guard avisado else { return "Toque un botón para contestarme" }
        if let familiar = modelo.familiar { return "Le estoy marcando a \(familiar.nombre)" }
        return "Si es urgente, llame al 911"
    }

    @ViewBuilder private var botones: some View {
        VStack(spacing: Theme.Spacing.s + 2) {
            if avisado {
                if let familiar = modelo.familiar {
                    PrimaryButton(title: "Llamar a \(familiar.nombre)", systemImage: "phone",
                                  color: Theme.Palette.help) { modelo.llamar(familiar) }
                }
            } else {
                PrimaryButton(title: "Sí, estoy bien", systemImage: "checkmark") {
                    Task { await modelo.estoyBien() }
                }
                PrimaryButton(title: "Necesito ayuda", systemImage: "exclamationmark.triangle",
                              color: Theme.Palette.help) {
                    Task { await modelo.pedirAyuda() }
                }
            }
            Button("Llamar al 911", action: modelo.llamarAl911)
                .font(Theme.Typography.textButton)
                .foregroundStyle(Theme.Palette.help)
                .frame(maxWidth: .infinity, minHeight: Theme.Size.textButton)
        }
        .disabled(modelo.fase == .avisando)
    }
}

/// Anillo rojo que se va vaciando, con los segundos en medio.
private struct CountdownRing: View {
    let segundos: Int
    let total: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.Palette.surface)
            Circle()
                .stroke(Theme.Palette.helpTrack, lineWidth: Theme.Size.countdownStroke)
            Circle()
                .trim(from: 0, to: CGFloat(segundos) / CGFloat(total))
                .stroke(Theme.Palette.help,
                        style: StrokeStyle(lineWidth: Theme.Size.countdownStroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: segundos)
            VStack(spacing: 0) {
                Text("\(segundos)")
                    .serif(Theme.Typography.countdownSize, weight: .semibold)
                    .foregroundStyle(Theme.Palette.cafe)
                    .contentTransition(.numericText(countsDown: true))
                Text("segundos")
                    .font(Theme.Typography.cardRole)
                    .foregroundStyle(Theme.Palette.cafeSoft)
            }
        }
        .padding(Theme.Size.countdownStroke / 2)
        .frame(width: Theme.Size.countdown, height: Theme.Size.countdown)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quedan \(segundos) segundos")
    }
}

/// Ficha médica para quien llegue a ayudar (familia, paramédicos).
private struct FichaCard: View {
    let ficha: FichaMedica

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Para quien venga a ayudar")
                    .font(Theme.Typography.cardRowBold)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                Text(ficha.nombreCompleto)
                    .font(Theme.Typography.cardName)
                    .foregroundStyle(Theme.Palette.cafe)
                Text("\(ficha.edad) años · Sangre \(ficha.tipoDeSangre)")
                    .font(Theme.Typography.cardRow)
                    .foregroundStyle(Theme.Palette.cafe)
            }
            renglon("Alergias", ficha.alergias)
            renglon("Padecimientos", ficha.padecimientos)
            if !ficha.notas.isEmpty { renglon("Notas", ficha.notas) }
        }
        .padding(Theme.Spacing.section)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.card))
        .shadow(color: Theme.Palette.shadow.opacity(0.10), radius: 20, y: 18)
    }

    private func renglon(_ etiqueta: String, _ valor: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(etiqueta)
                .font(Theme.Typography.cardRowBold)
                .foregroundStyle(Theme.Palette.cafeSoft)
            Text(valor)
                .font(Theme.Typography.cardRow)
                .foregroundStyle(Theme.Palette.cafe)
        }
    }
}

#Preview {
    let container = SampleData.previewContainer
    HelpView(context: container.mainContext, nombre: "Doña Mari", motivo: .caida)
        .modelContainer(container)
}
