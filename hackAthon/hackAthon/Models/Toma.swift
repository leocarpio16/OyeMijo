//
//  Toma.swift
//  hackAthon
//
//  Cada vez que tocaba tomar una medicina y qué pasó.
//  Con esto Mijo responde "¿ya me la tomé?".
//

import Foundation
import SwiftData

nonisolated enum EstadoToma: String, Codable {
    case tomada
    case pospuesta
    case sinConfirmar
}

@Model
final class Toma {
    var medicina: Medicina?
    /// Hora en que tocaba.
    var programada: Date
    /// Hora en que respondió (botón o voz); nil si no ha respondido.
    var respondida: Date?
    var estado: EstadoToma

    init(medicina: Medicina, programada: Date, estado: EstadoToma = .sinConfirmar, respondida: Date? = nil) {
        self.medicina = medicina
        self.programada = programada
        self.estado = estado
        self.respondida = respondida
    }
}
