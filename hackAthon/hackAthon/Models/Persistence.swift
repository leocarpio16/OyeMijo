//
//  Persistence.swift
//  hackAthon
//
//  La base de datos de la app, una sola para todos: las pantallas y las
//  respuestas a las notificaciones (que pueden llegar con la app cerrada).
//

import Foundation
import SwiftData

enum Persistence {
    static let container: ModelContainer = {
        do {
            let container = try ModelContainer(for: Schema(SampleData.modelos))
            SampleData.cargarSiEstaVacia(container.mainContext)
            return container
        } catch {
            fatalError("No se pudo crear la base de datos: \(error)")
        }
    }()
}
