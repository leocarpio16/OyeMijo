//
//  RootView.swift
//  hackAthon
//
//  Primera pantalla: el registro por voz si todavía no hay perfil;
//  si ya lo hay, Inicio.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var ajustes: [Ajustes]

    var body: some View {
        Group {
            if ajustes.isEmpty {
                OnboardingView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: ajustes.isEmpty)
    }
}

#Preview {
    RootView()
        .modelContainer(SampleData.previewContainer)
}
