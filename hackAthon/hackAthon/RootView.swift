//
//  RootView.swift
//  hackAthon
//
//  Primera pantalla: el registro por voz si todavía no hay perfil;
//  si ya lo hay, Inicio. Si este teléfono es el de un familiar ("Soy familiar"
//  en Bienvenida), la pantalla de avisos.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var ajustes: [Ajustes]
    /// Tema de ntfy que escucha este teléfono en modo familia; vacío = modo abuela.
    /// Va en UserDefaults (como un archivo de configuración), no en la base de datos.
    @AppStorage("temaFamilia") private var temaFamilia = ""

    var body: some View {
        Group {
            if !temaFamilia.isEmpty {
                FamilyView(tema: temaFamilia) { temaFamilia = "" }
                    .transition(.opacity)
            } else if ajustes.isEmpty {
                OnboardingView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: ajustes.isEmpty)
        .animation(.easeInOut(duration: 0.35), value: temaFamilia)
    }
}

#Preview {
    RootView()
        .modelContainer(SampleData.previewContainer)
}
