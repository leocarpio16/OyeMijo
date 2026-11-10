//
//  PillsView.swift
//  hackAthon
//
//  "Sus pastillas de hoy", según el diseño del equipo: cada toma del día
//  con su estado (Tomada / Ahora / Después) y "Ya me la tomé" abajo.
//

import SwiftUI
import SwiftData

struct PillsView: View {
    @Query private var medicinas: [Medicina]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var voz = VoiceService()
    /// Para pasar a la plática con Mijo desde el micrófono.
    let onTalk: () -> Void

    /// Una toma del día: qué pastilla y a qué hora.
    private struct Dosis: Identifiable {
        let medicina: Medicina
        let horario: Horario
        var id: String { "\(medicina.persistentModelID.hashValue)-\(horario.minutosDelDia)" }
    }

    private enum Estado {
        /// `sinConfirmar`: ya pasó su hora y no dijo que se la tomó.
        case tomada, ahora, sinConfirmar, despues
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.section) {
            HStack {
                RoundIconButton(systemImage: "arrow.left", label: "Inicio") { dismiss() }
                Spacer()
                WhitePill(title: "Escuchar", systemImage: "speaker.wave.2",
                          iconColor: Theme.Palette.cafe, font: Theme.Typography.pillBold,
                          height: Theme.Size.roundButton, fullWidth: false,
                          shadowOpacity: 0.12) { Task { await voz.hablar(resumen) } }
            }
            .padding(.horizontal, margen)

            ScrollView {
                VStack(spacing: Theme.Spacing.section) {
                    VStack(spacing: Theme.Spacing.s) {
                        Text("Sus pastillas de hoy")
                            .serif(Theme.Typography.titleSize)
                            .foregroundStyle(Theme.Palette.cafe)
                        Text(subtitulo)
                            .font(Theme.Typography.support)
                            .foregroundStyle(Theme.Palette.cafeSoft)
                    }
                    .multilineTextAlignment(.center)

                    if !dosis.isEmpty {
                        TiltedCard(spacing: 0) {
                            ForEach(dosis) { una in
                                renglon(una)
                                if una.id != dosis.last?.id {
                                    Rectangle().fill(Theme.Palette.cream).frame(height: 2)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, margen)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)

            HStack(spacing: Theme.Spacing.m) {
                if let actual = porTomar {
                    PrimaryButton(title: "Ya me la tomé", systemImage: "checkmark") { marcar(actual) }
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
        .onDisappear { voz.callar() }
    }

    private let margen = Theme.Spacing.screen - Theme.Spacing.xs

    // MARK: Datos

    /// Todas las tomas de hoy, por hora.
    private var dosis: [Dosis] {
        medicinas
            .flatMap { med in med.horarios.map { Dosis(medicina: med, horario: $0) } }
            .sorted { $0.horario < $1.horario }
    }

    private func estado(_ una: Dosis) -> Estado {
        if una.medicina.tomadaHoy(una.horario) { return .tomada }
        if una.id == porTomar?.id { return .ahora }
        return una.horario.minutosDelDia <= Horario(de: .now).minutosDelDia ? .sinConfirmar : .despues
    }

    /// La toma que marca "Ya me la tomé" (la misma regla que la pastilla de Inicio).
    private var porTomar: Dosis? {
        dosis.last { $0.medicina.horarioPorConfirmar() == $0.horario }
    }

    private var faltan: Int {
        dosis.filter { estado($0) != .tomada }.count
    }

    private var subtitulo: String {
        if dosis.isEmpty { return "Hoy no tiene pastillas" }
        switch faltan {
        case 0: return "Ya se tomó todas. ¡Muy bien!"
        case 1: return "Le falta 1"
        default: return "Le faltan \(faltan)"
        }
    }

    /// Lo que dice Mijo al tocar "Escuchar".
    private var resumen: String {
        let pendientes = dosis.filter { estado($0) != .tomada }
        guard !pendientes.isEmpty else { return "Ya se tomó todas sus pastillas de hoy. ¡Muy bien!" }
        let lista = pendientes.map { "la \($0.medicina.nombreParaMostrar.lowercased()) a las \($0.horario.texto)" }
        return "Hoy le \(pendientes.count == 1 ? "falta" : "faltan"): " + lista.joined(separator: ", ") + "."
    }

    private func marcar(_ una: Dosis) {
        context.insert(Toma(medicina: una.medicina, programada: una.horario.fechaDeHoy,
                            estado: .tomada, respondida: .now))
        try? context.save()
        Task { await voz.hablar("Muy bien, ya lo anoté.") }
    }

    // MARK: Partes

    private func renglon(_ una: Dosis) -> some View {
        HStack(spacing: Theme.Spacing.s + 2) {
            let nombre = una.medicina.nombre == "Pastilla" ? una.medicina.nombreParaMostrar : una.medicina.nombre
            // En un renglón si cabe; si no, la hora arriba y el nombre abajo.
            ViewThatFits(in: .horizontal) {
                Text("\(una.horario.texto) · \(nombre)").lineLimit(1)
                VStack(alignment: .leading, spacing: 0) {
                    Text(una.horario.texto)
                    Text(nombre)
                }
            }
            .font(Theme.Typography.support)
            .foregroundStyle(Theme.Palette.cafeSoft)
            .frame(maxWidth: .infinity, alignment: .leading)
            switch estado(una) {
            case .tomada:
                Label("Tomada", systemImage: "checkmark")
                    .font(Theme.Typography.status)
                    .foregroundStyle(Theme.Palette.taken)
            case .ahora:
                Text("Ahora")
                    .font(Theme.Typography.status)
                    .foregroundStyle(Theme.Palette.cafe)
                    .padding(.horizontal, Theme.Spacing.l)
                    .frame(minHeight: Theme.Size.nowTag)
                    .background(Theme.Palette.brandAmber, in: .capsule)
            case .sinConfirmar:
                Text("Sin confirmar")
                    .font(Theme.Typography.statusSoft)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                    .multilineTextAlignment(.trailing)
            case .despues:
                Text("Después")
                    .font(Theme.Typography.statusSoft)
                    .foregroundStyle(Theme.Palette.cafeSoft)
            }
        }
        .padding(.vertical, Theme.Spacing.s)
        .frame(minHeight: Theme.Size.pillRow)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PillsView(onTalk: {})
        .modelContainer(SampleData.previewContainer)
}
