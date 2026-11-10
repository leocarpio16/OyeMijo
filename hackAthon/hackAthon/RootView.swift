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
    /// true si este teléfono es el de un familiar ("Soy familiar" en Bienvenida).
    /// Va en UserDefaults (como un archivo de configuración), no en la base de datos.
    /// nil = nunca se eligió (la versión anterior solo guardaba el código: si lo hay, es familia).
    @AppStorage("modoFamilia") private var modoFamilia: Bool?
    @AppStorage("temaFamilia") private var temaFamilia = ""

    var body: some View {
        Group {
            if modoFamilia ?? !temaFamilia.isEmpty {
                FamilyRoot()
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
        .animation(.easeInOut(duration: 0.35), value: modoFamilia)
    }
}

#Preview {
    RootView()
        .modelContainer(SampleData.previewContainer)
}
