//
//  ContentView.swift
//  hackAthon
//
//  Created by Leo Carpio on 09/11/26.
//
//  Pantalla raíz: barra de pestañas. Las pestañas se renombran
//  y se llenan cuando se defina la idea.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PlaceholderScreen(title: "Inicio")
                .tabItem { Label("Inicio", systemImage: "house") }
            PlaceholderScreen(title: "Explorar")
                .tabItem { Label("Explorar", systemImage: "magnifyingglass") }
            PlaceholderScreen(title: "Perfil")
                .tabItem { Label("Perfil", systemImage: "person") }
        }
        .tint(Theme.Palette.accent)
    }
}

/// Pantalla temporal mientras se define el contenido real.
private struct PlaceholderScreen: View {
    let title: String

    var body: some View {
        NavigationStack {
            Text("Pendiente")
                .foregroundStyle(Theme.Palette.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.Palette.background)
                .navigationTitle(title)
        }
    }
}

#Preview {
    ContentView()
}
