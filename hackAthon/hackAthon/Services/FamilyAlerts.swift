//
//  FamilyAlerts.swift
//  hackAthon
//
//  Si una pastilla o una comida se queda sin confirmar más de 30 minutos,
//  avisa a la familia por ntfy (PRD F2 y F4). Una sola vez por toma.
//  Límite de iOS: una app cerrada no puede correr código a cierta hora, así
//  que se revisa al abrir la app y cada minuto mientras está abierta.
//

import Foundation
import SwiftData

enum FamilyAlerts {
    /// Minutos de espera antes de avisar.
    private static let espera = 30
    /// Solo se avisa de lo que pasó en las últimas 3 horas (no de lo de la mañana).
    private static let ventana = 180

    static func revisar(_ context: ModelContext) async {
        guard let ajustes = try? context.fetch(FetchDescriptor<Ajustes>()).first else { return }
        let ahora = Horario(de: .now).minutosDelDia
        let toco = { (horario: Horario) in
            (ahora - ventana...ahora - espera).contains(horario.minutosDelDia)
        }

        // Pastillas: la marca de "ya se avisó" es una Toma "sin confirmar".
        for medicina in (try? context.fetch(FetchDescriptor<Medicina>())) ?? [] {
            for horario in medicina.horarios where toco(horario) && !medicina.tomadaHoy(horario) {
                let yaAvisado = medicina.tomas.contains {
                    $0.estado == .sinConfirmar && Calendar.current.isDateInToday($0.programada)
                        && Horario(de: $0.programada) == horario
                }
                guard !yaAvisado else { continue }
                context.insert(Toma(medicina: medicina, programada: horario.fechaDeHoy, estado: .sinConfirmar))
                try? context.save()
                await NtfyService.avisar(
                    tema: ajustes.temaNtfy,
                    titulo: "\(ajustes.comoLlamarla) no ha confirmado su pastilla",
                    mensaje: "Le tocaba su \(medicina.nombreParaMostrar.lowercased()) a las \(horario.texto) y no ha dicho que se la tomó.",
                    prioridad: .alta, etiquetas: ["pill"])
            }
        }

        // Comidas: la marca de "ya se avisó" se guarda por día.
        let comidasDeHoy = ((try? context.fetch(FetchDescriptor<Comida>())) ?? [])
            .filter { Calendar.current.isDateInToday($0.fecha) && $0.yaComio }
        let comidas: [(TipoComida, Horario)] = [(.desayuno, ajustes.desayuno),
                                                (.comida, ajustes.comida),
                                                (.cena, ajustes.cena)]
        for (tipo, horario) in comidas where toco(horario) && !comidasDeHoy.contains(where: { $0.tipo == tipo }) {
            let marca = "avisoComida.\(tipo.rawValue).\(Date.now.formatted(.iso8601.year().month().day()))"
            guard !UserDefaults.standard.bool(forKey: marca) else { continue }
            UserDefaults.standard.set(true, forKey: marca)
            await NtfyService.avisar(
                tema: ajustes.temaNtfy,
                titulo: "\(ajustes.comoLlamarla) no ha confirmado su \(tipo.rawValue)",
                mensaje: "Era a las \(horario.texto) y todavía no le contesta a Mijo.",
                prioridad: .normal, etiquetas: ["fork_and_knife"])
        }
    }

    /// "Ya se tomó su pastilla": aviso tranquilo a la familia cada vez que la marca
    /// (por voz, en "Sus pastillas de hoy" o con el botón de la notificación).
    static func avisarTomada(_ medicina: Medicina, context: ModelContext) async {
        guard let ajustes = try? context.fetch(FetchDescriptor<Ajustes>()).first, !ajustes.temaNtfy.isEmpty else { return }
        let hora = Date.now.formatted(.dateTime.hour().minute().locale(Locale(identifier: "es_MX")))
        await NtfyService.avisar(
            tema: ajustes.temaNtfy,
            titulo: "\(ajustes.comoLlamarla) ya se tomó su pastilla",
            mensaje: "Se tomó su \(medicina.nombreParaMostrar.lowercased()) a las \(hora).",
            prioridad: .normal, etiquetas: ["white_check_mark", "pill"])
    }
}
