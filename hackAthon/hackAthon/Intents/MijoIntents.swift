//
//  MijoIntents.swift
//  hackAthon
//
//  Atajos de Siri (App Intents):
//    "Oye Siri, habla con Mijo"            → abre a Mijo escuchando
//    "Oye Siri, Mijo, me caí"              → protocolo de caída (aviso + llamada)
//    "Oye Siri, pregúntale a Mijo si ya me tomé la pastilla" → Siri contesta sin abrir la app
//

import AppIntents
import SwiftData

struct HablarConMijoIntent: AppIntent {
    static let title: LocalizedStringResource = "Hablar con Mijo"
    static let description = IntentDescription("Abre a Mijo escuchando.")
    static let openAppWhenRun = true

    @MainActor func perform() async throws -> some IntentResult {
        AppRouter.shared.pendiente = .conversacion
        return .result()
    }
}

struct MeCaiIntent: AppIntent {
    static let title: LocalizedStringResource = "Me caí"
    static let description = IntentDescription("Avisa a la familia y le marca a la persona de confianza.")
    static let openAppWhenRun = true

    @MainActor func perform() async throws -> some IntentResult {
        AppRouter.shared.pendiente = .caida
        return .result()
    }
}

struct YaMeTomeLaPastillaIntent: AppIntent {
    static let title: LocalizedStringResource = "¿Ya me tomé la pastilla?"
    static let description = IntentDescription("Siri le dice si ya se tomó sus pastillas de hoy.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let texto = await Self.estado()
        return .result(dialog: IntentDialog(stringLiteral: texto))
    }

    /// "Sí, ya se tomó la pastilla de la presión de las 9:00 a.m."
    /// Va en el hilo principal: ahí vive la base de datos.
    @MainActor static func estado() -> String {
        let context = Persistence.container.mainContext
        let medicinas = (try? context.fetch(FetchDescriptor<Medicina>())) ?? []
        guard !medicinas.isEmpty else { return "No tiene pastillas guardadas todavía." }
        let ahora = Horario(de: .now).minutosDelDia
        return medicinas.compactMap { medicina -> String? in
            let horarios = medicina.horarios.sorted()
            let nombre = medicina.nombreParaMostrar.lowercased()
            guard let ultima = horarios.last(where: { $0.minutosDelDia <= ahora }) else {
                return horarios.first.map { "La \(nombre) le toca hasta las \($0.texto)." }
            }
            return medicina.tomadaHoy(ultima)
                ? "Sí, ya se tomó la \(nombre) de las \(ultima.texto)."
                : "Todavía no se toma la \(nombre) de las \(ultima.texto)."
        }
        .joined(separator: " ")
    }
}

struct MijoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: HablarConMijoIntent(),
                    phrases: ["Habla con \(.applicationName)",
                              "Hablar con \(.applicationName)",
                              "Oye \(.applicationName)"],
                    shortTitle: "Hablar con Mijo",
                    systemImageName: "mic")
        AppShortcut(intent: MeCaiIntent(),
                    phrases: ["\(.applicationName), me caí",
                              "Me caí, \(.applicationName)",
                              "\(.applicationName), ayuda"],
                    shortTitle: "Me caí",
                    systemImageName: "exclamationmark.triangle")
        AppShortcut(intent: YaMeTomeLaPastillaIntent(),
                    phrases: ["Pregúntale a \(.applicationName) si ya me tomé la pastilla",
                              "\(.applicationName), ¿ya me tomé la pastilla?"],
                    shortTitle: "¿Ya me tomé la pastilla?",
                    systemImageName: "pills")
    }
}
