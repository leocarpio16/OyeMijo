//
//  SampleData.swift
//  hackAthon
//
//  Datos de ejemplo de doña Mari. Se usan en los #Preview y en la demo
//  (mantener presionado a Mijo en Bienvenida).
//  Los teléfonos son ficticios: la familia los cambia en la configuración.
//

import Foundation
import SwiftData

enum SampleData {

    /// Todos los modelos de la app; se usa al crear la base de datos.
    static let modelos: [any PersistentModel.Type] = [
        Familiar.self, Medicina.self, Toma.self, Comida.self, FichaMedica.self, Ajustes.self
    ]

    /// Inserta los datos de ejemplo solo si todavía no hay ajustes guardados.
    static func cargarSiEstaVacia(_ context: ModelContext) {
        let yaHayDatos = (try? context.fetchCount(FetchDescriptor<Ajustes>())) ?? 0 > 0
        guard !yaHayDatos else { return }

        context.insert(Ajustes(comoLlamarla: "Doña Mari",
                               desayuno: Horario(hora: 8, minuto: 30),
                               comida: Horario(hora: 14, minuto: 30),
                               cena: Horario(hora: 20, minuto: 0)))

        context.insert(Familiar(nombre: "Leo", parentesco: "hijo",
                                telefono: "55 0000 0001", esPrincipal: true))
        context.insert(Familiar(nombre: "Carmen", parentesco: "hija",
                                telefono: "55 0000 0002"))

        context.insert(Medicina(nombre: "Losartán", dosis: "50 mg", paraQue: "la presión",
                                horarios: [Horario(hora: 9, minuto: 0), Horario(hora: 21, minuto: 0)],
                                esCritica: true))
        context.insert(Medicina(nombre: "Metformina", dosis: "850 mg", paraQue: "el azúcar",
                                horarios: [Horario(hora: 14, minuto: 30)]))

        context.insert(FichaMedica(nombreCompleto: "María Guadalupe Hernández López",
                                   edad: 76,
                                   tipoDeSangre: "O+",
                                   alergias: "Penicilina",
                                   padecimientos: "Hipertensión, diabetes tipo 2",
                                   notas: "Usa lentes para leer. Vive sola en planta baja."))
        try? context.save()
    }

    /// Base de datos en memoria, ya con los datos de ejemplo, para los #Preview.
    static var previewContainer: ModelContainer {
        let schema = Schema(modelos)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        cargarSiEstaVacia(container.mainContext)
        return container
    }
}
