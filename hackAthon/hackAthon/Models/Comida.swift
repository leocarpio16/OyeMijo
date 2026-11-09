//
//  Comida.swift
//  hackAthon
//
//  Registro de cada comida del día: Mijo pregunta "¿Ya cenó?" y aquí
//  queda la respuesta.
//

import Foundation
import SwiftData

nonisolated enum TipoComida: String, Codable, CaseIterable {
    case desayuno
    case comida
    case cena
}

@Model
final class Comida {
    var tipo: TipoComida
    var fecha: Date
    /// true = "Sí", false = "Todavía no".
    var yaComio: Bool

    init(tipo: TipoComida, fecha: Date = .now, yaComio: Bool) {
        self.tipo = tipo
        self.fecha = fecha
        self.yaComio = yaComio
    }
}
