//
//  Horario.swift
//  hackAthon
//
//  Una hora del día (sin fecha): "9:00", "21:00".
//  Lo usan las medicinas y los horarios de comida.
//

import Foundation

nonisolated struct Horario: Codable, Hashable, Comparable {
    var hora: Int    // 0–23
    var minuto: Int  // 0–59

    init(hora: Int, minuto: Int) {
        self.hora = hora
        self.minuto = minuto
    }

    /// La hora de una fecha: 21:05 del lunes → Horario(21, 5).
    init(de fecha: Date) {
        let partes = Calendar.current.dateComponents([.hour, .minute], from: fecha)
        self.init(hora: partes.hour ?? 0, minuto: partes.minute ?? 0)
    }

    /// Hoy a esta hora.
    var fechaDeHoy: Date {
        Calendar.current.date(bySettingHour: hora, minute: minuto, second: 0, of: .now) ?? .now
    }

    /// Minutos desde la medianoche; sirve para ordenar y comparar.
    var minutosDelDia: Int { hora * 60 + minuto }

    static func < (a: Horario, b: Horario) -> Bool {
        a.minutosDelDia < b.minutosDelDia
    }

    /// Texto para mostrar, siempre en español de México: "9:00 p.m.".
    var texto: String {
        fechaDeHoy.formatted(.dateTime.hour().minute().locale(Locale(identifier: "es_MX")))
    }
}
