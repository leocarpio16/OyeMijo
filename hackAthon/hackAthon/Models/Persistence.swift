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
            // Ya no se cargan datos de ejemplo solos: el registro por voz crea el perfil.
            // (Para la demo: mantener presionado a Mijo en Bienvenida carga a doña Mari.)
            return try ModelContainer(for: Schema(SampleData.modelos))
        } catch {
            fatalError("No se pudo crear la base de datos: \(error)")
        }
    }()
}
