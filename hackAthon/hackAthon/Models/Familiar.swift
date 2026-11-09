//
//  Familiar.swift
//  hackAthon
//
//  Persona de la familia a quien Mijo puede llamar o avisar.
//

import Foundation
import SwiftData

@Model
final class Familiar {
    var nombre: String
    var parentesco: String      // "hijo", "hija", "nieta"…
    var telefono: String
    /// El primero al que se llama y se avisa en una emergencia.
    var esPrincipal: Bool

    init(nombre: String, parentesco: String, telefono: String, esPrincipal: Bool = false) {
        self.nombre = nombre
        self.parentesco = parentesco
        self.telefono = telefono
        self.esPrincipal = esPrincipal
    }
}
