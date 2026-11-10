//
//  hackAthonApp.swift
//  hackAthon
//
//  Created by Leo Carpio on 09/11/26.
//
//  Punto de entrada: usa la base de datos compartida (Persistence), conecta
//  las respuestas de las notificaciones (AppDelegate) y abre RootView
//  (registro por voz la primera vez; después, Inicio).
//

import SwiftUI
import SwiftData

@main
struct hackAthonApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    let container = Persistence.container

    init() {
        // Para probar los avisos: la familia se suscribe a este tema en la app ntfy
        // (en el registro por voz se comparte con un código QR).
        if let tema = try? container.mainContext.fetch(FetchDescriptor<Ajustes>()).first?.temaNtfy {
            print("🔔 Tema de ntfy de la familia: \(tema)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                // El diseño del equipo ya usa letra grande (20–40 pt). Se permite crecer
                // hasta XXXL para que el Inicio siga cabiendo sin deslizar.
                .dynamicTypeSize(.large ... .xxxLarge)
                // Los colores del diseño son claros: en modo oscuro la hora y la
                // batería saldrían blancas sobre crema.
                .preferredColorScheme(.light)
        }
        .modelContainer(container)
    }
}
