//
//  Medicina.swift
//  hackAthon
//
//  Una medicina que la persona toma a horas fijas.
//

import Foundation
import SwiftData

@Model
final class Medicina {
    var nombre: String          // "Losartán"
    var dosis: String           // "50 mg"
    var paraQue: String         // "la presión" → Mijo dice "la pastilla de la presión"
    var horarios: [Horario]
    /// Si es crítica, el recordatorio usa AlarmKit (suena aunque esté en silencio).
    var esCritica: Bool
    /// Foto de la pastilla; se guarda fuera de la base de datos por su tamaño.
    @Attribute(.externalStorage) var foto: Data?

    /// Registro de cada vez que tocaba tomarla. Si se borra la medicina, se borran sus tomas.
    @Relationship(deleteRule: .cascade, inverse: \Toma.medicina)
    var tomas: [Toma] = []

    init(nombre: String, dosis: String, paraQue: String, horarios: [Horario], esCritica: Bool = false) {
        self.nombre = nombre
        self.dosis = dosis
        self.paraQue = paraQue
        self.horarios = horarios
        self.esCritica = esCritica
    }

    /// "Pastilla de la presión": así le dice Mijo.
    var nombreParaMostrar: String {
        paraQue.isEmpty ? nombre : "Pastilla de \(paraQue)"
    }

    /// true si hoy ya confirmó la toma de esa hora.
    func tomadaHoy(_ horario: Horario) -> Bool {
        tomas.contains {
            $0.estado == .tomada && Calendar.current.isDateInToday($0.programada)
                && Horario(de: $0.programada) == horario
        }
    }

    /// La toma que toca "ahora": sin tomar, de hace menos de 2 horas o de la
    /// próxima hora. Las más viejas sin tomar quedan "sin confirmar".
    func horarioPorConfirmar(ahora: Date = .now) -> Horario? {
        let minuto = Horario(de: ahora).minutosDelDia
        return horarios.sorted().last {
            (minuto - 120...minuto + 60).contains($0.minutosDelDia) && !tomadaHoy($0)
        }
    }

    /// Siguiente hora de hoy en que toca; nil si ya pasaron todas.
    func siguienteHorario(despuesDe ahora: Date = .now) -> Horario? {
        let partes = Calendar.current.dateComponents([.hour, .minute], from: ahora)
        let minutosAhora = (partes.hour ?? 0) * 60 + (partes.minute ?? 0)
        return horarios.sorted().first { $0.minutosDelDia > minutosAhora }
    }
}
