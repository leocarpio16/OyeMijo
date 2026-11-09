//
//  Ajustes.swift
//  hackAthon
//
//  Configuración que hace la familia (una sola fila en la base de datos).
//

import Foundation
import SwiftData

@Model
final class Ajustes {
    /// Cómo le habla Mijo: "Doña Mari".
    var comoLlamarla: String
    /// Tema de ntfy.sh al que se suscribe la familia. Largo y aleatorio:
    /// funciona como contraseña, por eso se genera en el teléfono y no va en el código.
    var temaNtfy: String
    var desayuno: Horario
    var comida: Horario
    var cena: Horario

    init(comoLlamarla: String, desayuno: Horario, comida: Horario, cena: Horario,
         temaNtfy: String = "mijo-" + UUID().uuidString.lowercased()) {
        self.comoLlamarla = comoLlamarla
        self.temaNtfy = temaNtfy
        self.desayuno = desayuno
        self.comida = comida
        self.cena = cena
    }
}
