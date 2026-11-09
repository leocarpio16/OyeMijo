//
//  ContentView.swift
//  hackAthon
//
//  Created by Leo Carpio on 09/11/26.
//
//  Inicio de Mijo, según el diseño "Oye Mijito – Pantallas" del equipo:
//  - arriba, un panel ámbar con Mijo grande y la pastilla "Ayuda",
//  - el saludo centrado ("Buenos días," + nombre en letra con serifa),
//  - la siguiente medicina en una pastilla blanca,
//  - abajo, el botón redondo para hablar con Mijo.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var ajustes: [Ajustes]
    @Query private var medicinas: [Medicina]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                MijoHeader()
                    .overlay(alignment: .topTrailing) {
                        WhitePill(title: "Ayuda", systemImage: "exclamationmark.triangle",
                                  color: Theme.Palette.help, iconColor: Theme.Palette.help,
                                  font: Theme.Typography.helpPill, height: Theme.Size.helpPill,
                                  fullWidth: false, shadowOpacity: 0.14) {
                            // Bloque 4: protocolo de caída / emergencia (sin IA).
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

                if let texto = proximaMedicina {
                    WhitePill(title: texto, systemImage: "clock") {
                        // Bloque 2: pantalla de medicinas.
                    }
                    .padding(.horizontal, Theme.Spacing.screen)
                    .padding(.top, Theme.Spacing.l + 2)
                }

                Spacer(minLength: Theme.Spacing.l)

                TalkButton {
                    // Bloque 1: abre la conversación por voz con Mijo.
                }
                .padding(.bottom, geo.safeAreaInsets.bottom + Theme.Spacing.s)
            }
            .ignoresSafeArea()
        }
        .background(Theme.Palette.cream)
    }

    /// "Buenos días," / "Buenas tardes," / "Buenas noches," según la hora.
    private var saludo: String {
        let hora = Calendar.current.component(.hour, from: .now)
        return hora < 12 ? "Buenos días," : hora < 19 ? "Buenas tardes," : "Buenas noches,"
    }

    /// "9:00 p.m. · Pastilla de la presión" (la siguiente de hoy o, si ya pasaron, la primera de mañana).
    private var proximaMedicina: String? {
        let hoy = medicinas.compactMap { med in med.siguienteHorario().map { (med, $0) } }
        let manana = medicinas.compactMap { med in med.horarios.min().map { (med, $0) } }
        guard let (med, horario) = (hoy.isEmpty ? manana : hoy).min(by: { $0.1 < $1.1 }) else { return nil }
        return "\(horario.texto) · Pastilla de \(med.paraQue)"
    }
}

/// Panel ámbar con las esquinas de abajo redondeadas y Mijo grande adentro.
private struct MijoHeader: View {
    var body: some View {
        // El panel tiene el color de arriba de la imagen: así no se nota dónde empieza.
        Theme.Palette.brandAmberTop
            .frame(height: Theme.Size.header)
            // Mijo va como capa encima: es más ancho que la pantalla y se recorta,
            // pero como capa no empuja ni cambia el ancho de lo demás.
            .overlay(alignment: .top) {
                Image("Mijo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: Theme.Size.headerMijo, height: Theme.Size.headerMijo)
                    .offset(y: 30) // Mijo un poco abajo, como en el diseño
            }
            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: Theme.Radius.header,
                                              bottomTrailingRadius: Theme.Radius.header))
            .accessibilityElement()
            .accessibilityLabel("Mijo, su nieto virtual")
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.previewContainer)
}
