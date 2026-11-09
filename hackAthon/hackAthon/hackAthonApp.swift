//
//  hackAthonApp.swift
//  hackAthon
//
//  Created by Leo Carpio on 09/11/26.
//
//  Punto de entrada: crea la base de datos (SwiftData), carga los datos
//  de ejemplo la primera vez y muestra la pantalla principal.
//

import SwiftUI
import SwiftData

@main
struct hackAthonApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Schema(SampleData.modelos))
        } catch {
            fatalError("No se pudo crear la base de datos: \(error)")
        }
        SampleData.cargarSiEstaVacia(container.mainContext)
        // Para probar los avisos: la familia se suscribe a este tema en la app ntfy.
        // (En el registro por voz, Bloque 1b, se comparte con un código QR.)
        if let tema = try? container.mainContext.fetch(FetchDescriptor<Ajustes>()).first?.temaNtfy {
            print("🔔 Tema de ntfy de la familia: \(tema)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // El diseño del equipo ya usa letra grande (20–40 pt). Se permite crecer
                // hasta XXXL para que el Inicio siga cabiendo sin deslizar.
                .dynamicTypeSize(.large ... .xxxLarge)
        }
        .modelContainer(container)
    }
}
