//
//  FichaMedica.swift
//  hackAthon
//
//  Datos que se muestran en la pantalla de emergencia para quien llegue
//  a ayudar (familia, paramédicos).
//

import Foundation
import SwiftData

@Model
final class FichaMedica {
    var nombreCompleto: String
    var edad: Int
    var tipoDeSangre: String
    var alergias: String
    var padecimientos: String
    var notas: String

    init(nombreCompleto: String, edad: Int, tipoDeSangre: String,
         alergias: String, padecimientos: String, notas: String = "") {
        self.nombreCompleto = nombreCompleto
        self.edad = edad
        self.tipoDeSangre = tipoDeSangre
        self.alergias = alergias
        self.padecimientos = padecimientos
        self.notas = notas
    }
}
