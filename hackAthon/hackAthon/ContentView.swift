//
//  ContentView.swift
//  hackAthon
//
//  Created by Leo Carpio on 09/11/26.
//
//  Inicio de Mijo, según el diseño "Oye Mijito – Pantallas" del equipo:
//  - arriba, un panel ámbar con Mijo grande y la pastilla "Ayuda",
//  - el saludo centrado ("Buenos días," + nombre en letra grande),
//  - la siguiente medicina en una pastilla blanca,
//  - abajo, el botón redondo para hablar con Mijo.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var ajustes: [Ajustes]
    @Query private var medicinas: [Medicina]
    @Environment(\.modelContext) private var context
    @State private var pantalla: Pantalla?

    /// Pantallas que se abren encima de Inicio.
    private enum Pantalla: Identifiable {
        case conversacion
        case ayuda
        case pastillas
        /// "Oye Siri, Mijo, me caí": avisa y marca sin preguntar.
        case caida
        var id: Self { self }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                MijoHeader()
                    // Para la demo: mantener presionado a Mijo manda la pregunta
                    // de la pastilla en 5 segundos (bloquear el teléfono para verla).
                    .onLongPressGesture {
                        Task { await NotificationService.probarAhora(context) }
                    }
                    .overlay(alignment: .topTrailing) {
                        WhitePill(title: "Ayuda", systemImage: "exclamationmark.triangle",
                                  color: Theme.Palette.help, iconColor: Theme.Palette.help,
                                  font: Theme.Typography.helpPill, height: Theme.Size.helpPill,
                                  fullWidth: false, shadowOpacity: 0.14) {
                            pantalla = .ayuda
                        }
                        .padding(.top, geo.safeAreaInsets.top + Theme.Spacing.xs)
                        .padding(.trailing, Theme.Spacing.screen - Theme.Spacing.xs)
                    }

                VStack(spacing: 2) {
                    Text(saludo)
                        .font(Theme.Typography.greeting)
                        .foregroundStyle(Theme.Palette.cafeSoft)
                    Text(ajustes.first?.comoLlamarla ?? "")
                        .font(Theme.Typography.name)
                        .foregroundStyle(Theme.Palette.cafe)
                }
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.l + 2)

                // La siguiente pastilla; si todavía no tiene, cómo agregarla.
                if let texto = proximaMedicina ?? (medicinas.isEmpty ? "Agregar mis pastillas" : nil) {
                    WhitePill(title: texto, systemImage: medicinas.isEmpty ? "plus" : "clock") {
                        pantalla = .pastillas
                    }
                    .padding(.horizontal, Theme.Spacing.screen)
                    .padding(.top, Theme.Spacing.l + 2)
                }

                Spacer(minLength: Theme.Spacing.l)

                TalkButton {
                    pantalla = .conversacion
                }
                .padding(.bottom, geo.safeAreaInsets.bottom + Theme.Spacing.s)
            }
            .ignoresSafeArea()
        }
        .background(Theme.Palette.cream)
        .task {
            // Mijo pregunta por ti: programa las preguntas de pastillas y comidas.
            if await NotificationService.pedirPermiso() {
                await NotificationService.reprogramar(context)
            }
        }
        .task {
            // Mientras la app está abierta, revisa cada minuto si algo se quedó sin confirmar.
            while !Task.isCancelled {
                await FamilyAlerts.revisar(context)
                try? await Task.sleep(for: .seconds(60))
            }
        }
        // Recado de Siri ("Habla con Mijo", "Mijo, me caí").
        .onChange(of: AppRouter.shared.pendiente, initial: true) { _, destino in
            guard let destino else { return }
            AppRouter.shared.pendiente = nil
            pantalla = destino == .caida ? .caida : .conversacion
        }
        .fullScreenCover(item: $pantalla) { pantalla in
            let nombre = ajustes.first?.comoLlamarla ?? ""
            switch pantalla {
            case .conversacion: ConversationView(context: context, nombre: nombre)
            case .ayuda: HelpView(context: context, nombre: nombre, motivo: .ayuda)
            case .pastillas: PillsView { self.pantalla = .conversacion }
            case .caida: HelpView(context: context, nombre: nombre, motivo: .caida, frase: "me caí")
            }
        }
    }

    /// "Buenos días," / "Buenas tardes," / "Buenas noches," según la hora.
    private var saludo: String {
        let hora = Calendar.current.component(.hour, from: .now)
        return hora < 12 ? "Buenos días," : hora < 19 ? "Buenas tardes," : "Buenas noches,"
    }

    /// "9:00 p.m. · Pastilla de la presión" (la siguiente de hoy o, si ya pasaron, la primera de mañana).
    private var proximaMedicina: String? {
        let hoy = medicinas.compactMap { med in
            (med.horarioPorConfirmar() ?? med.siguienteHorario()).map { (med, $0) }
        }
        let manana = medicinas.compactMap { med in med.horarios.min().map { (med, $0) } }
        guard let (med, horario) = (hoy.isEmpty ? manana : hoy).min(by: { $0.1 < $1.1 }) else { return nil }
        return "\(horario.texto) · \(med.nombreParaMostrar)"
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.previewContainer)
}
